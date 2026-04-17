# GitOps - Entrega Contínua com ArgoCD

## Visão Geral

O diretório `gitops/` contém todos os manifestos Kubernetes que são sincronizados automaticamente pelo **ArgoCD** a partir do repositório Git. Isso garante que o estado desejado no cluster sempre corresponda ao estado definido no código.

## Estrutura de Diretórios

```
gitops/
├── argocd/
│   ├── namespaces.yaml              # Namespaces (argocd, togglemaster, togglemaster-secrets)
│   ├── secrets.yaml                 # Secrets para ArgoCD (repo credentials)
│   ├── applications.yaml            # ArgoCD Applications (5 serviços)
│   └── README.md
├── applications/
│   ├── auth-service/
│   │   └── deployment.yaml          # Deployment + Service + ServiceAccount + Secrets
│   ├── flag-service/
│   │   └── deployment.yaml
│   ├── targeting-service/
│   │   └── deployment.yaml
│   ├── evaluation-service/
│   │   └── deployment.yaml
│   └── analytics-service/
│       └── deployment.yaml
└── README.md                         # Este arquivo
```

## Fluxo GitOps

```
┌────────────────────────┐
│  Developer faz Push    │
│    em Main Branch      │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────────────────────┐
│ GitHub Actions CI/CD                   │
│ · Build & Test                         │
│ · Docker Build & Push                  │
│ · Update image tag em gitops/          │
│ · Create PR em GitOps repo             │
└───────────┬────────────────────────────┘
            │
            ▼
┌────────────────────────────────────────┐
│     GitOps PR Merged to Main            │
│     (deployment.yaml atualizado)        │
└───────────┬────────────────────────────┘
            │
            ▼
┌────────────────────────────────────────┐
│      ArgoCD Detecta Mudança             │
│      (monitora repositório a cada 3min) │
└───────────┬────────────────────────────┘
            │
            ▼
┌────────────────────────────────────────┐
│   ArgoCD Sincroniza o Cluster          │
│   · Aplica novos manifestos            │
│   · Substitui pod antigos              │
│   · Valida saúde da aplicação          │
└───────────┬────────────────────────────┘
            │
            ▼
┌────────────────────────────────────────┐
│  Novo Serviço em Produção!             │
│  · Rolling update (zero downtime)      │
│  · Liveness/readiness probes validam   │
│  · Métricas coletadas automaticamente  │
└────────────────────────────────────────┘
```

## Instalação do ArgoCD

### 1. Criar Namespace

```bash
# Aplicar namespaces
kubectl apply -f gitops/argocd/namespaces.yaml

# Verificar
kubectl get ns | grep argocd
```

### 2. Instalar ArgoCD via Helm

```bash
# Adicionar repositório Helm
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Instalar ArgoCD
helm install argocd argo/argo-cd \
  --namespace argocd \
  --version 5.35.1 \
  --values - <<EOF
server:
  insecure: true  # Apenas para demo! Use TLS em produção
  service:
    type: LoadBalancer
repoServer:
  replicas: 2
redis:
  enabled: true
EOF

# Verificar status
kubectl wait --for=condition=available --timeout=300s \
  deployment/argocd-server -n argocd
```

### 3. Acessar UI do ArgoCD

```bash
# Port-forward local
kubectl port-forward -n argocd svc/argocd-server 8080:443 &

# Obter senha padrão
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Acesse: https://localhost:8080
# Usuário: admin
# Senha: (output do comando anterior)
```

### 4. Configurar Repositório GitHub (Secrets)

```bash
# Aplicar secrets do ArgoCD
kubectl apply -f gitops/argocd/secrets.yaml

# Substituir valores (IMPORTANTE!)
kubectl -n argocd patch secret argocd-repo-creds-github \
  -p '{"stringData":{"url":"https://github.com/SEU_USUARIO/SEU_REPO.git","password":"YOUR_GITHUB_PERSONAL_TOKEN"}}'
```

### 5. Criar Aplicações ArgoCD

```bash
# Aplicar as aplicações
kubectl apply -f gitops/argocd/applications.yaml

# Verificar status
kubectl get applications -n argocd

# Aguardar sincronização
kubectl -n argocd wait --for=condition=Synced \
  application/togglemaster-auth-service timeout=300s
```

## Monitorando Sincronização

### Via CLI

```bash
# Listar aplicações
kubectl get applications -n argocd

# Ver detalhes de uma aplicação
kubectl describe app togglemaster-auth-service -n argocd

# Ver logs do ArgoCD
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server -f

# Sincronizar manualmente (se necessário)
argocd app sync togglemaster-auth-service --namespace argocd
```

### Via UI

1. Acesse https://localhost:8080
2. Clique em **Applications** no menu esquerdo
3. Veja status de sincronização de cada serviço
4. Clique para ver detalhes (pods, eventos, etc)

## Atualizando Manifestos

### Scenario 1: Atualizar imagem manualmente

```bash
# Editar deployment
kubectl -n togglemaster edit deployment auth-service

# Ou via kubectl patch
kubectl set image deployment/auth-service \
  auth-service=12345.dkr.ecr.us-east-1.amazonaws.com/togglemaster/auth-service:abc123 \
  -n togglemaster
```

**Nota:** ArgoCD vai retaliar se detectar drift! Use GitOps:

### Scenario 2: Atualizar via GitOps (recomendado)

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/seu-repo.git
cd seu-repo

# 2. Edite o manifesto
vim gitops/applications/auth-service/deployment.yaml

# 3. Commit e push
git add gitops/
git commit -m "chore(gitops): update auth-service image"
git push origin main

# 4. ArgoCD detecta em ~3min e sincroniza automaticamente
# Ou sincronize manualmente:
kubectl patch app togglemaster-auth-service -n argocd \
  -p '{"metadata":{"annotations":{"argocd.argoproj.io/compare-result":"Unknown"}}}'
```

## Configuração de Segredos

### Problema: Senhas em txt puro no repo? 😱

**Solução 1: ArgoCD + Sealed Secrets**

```bash
# Instalar Sealed Secrets controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.18.0/controller.yaml

# Criar secret selado
echo -n mypassword | kubectl create secret generic mysecret \
  --dry-run=client --from-file=password=/dev/stdin -o yaml | \
  kubeseal -f - > gitops/applications/auth-service/sealed-secret.yaml

# No deployment, referenciar:
# valueFrom:
#   secretKeyRef:
#     name: mysecret
#     key: password
```

**Solução 2: AWS Secrets Manager**

```bash
# No EKS, use:
# - External Secrets Operator (ESO)
# - AWS Secrets Manager IAM Policy
# - Sincroniza automaticamente
```

**Solução 3: HashiCorp Vault**

```bash
# Integration com ArgoCD para secrets seguros
# https://argoproj.github.io/argo-cd/user-guide/secret-management/
```

## Health Checks & Liveness Probes

Cada deployment inclui:

```yaml
livenessProbe:
  httpGet:
    path: /health      # Endpoint deve responder OK
    port: 8001
  initialDelaySeconds: 30
  periodSeconds: 10
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /ready       # Pronto para aceitar tráfego?
    port: 8001
  initialDelaySeconds: 10
  periodSeconds: 5
  failureThreshold: 2
```

**Implementar nos serviços:**

```go
// Auth Service (Go)
http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
  w.WriteHeader(http.StatusOK)
  w.Write([]byte("OK"))
})

http.HandleFunc("/ready", func(w http.ResponseWriter, r *http.Request) {
  if dbConnected && cacheReady {
    w.WriteHeader(http.StatusOK)
  } else {
    w.WriteHeader(http.StatusServiceUnavailable)
  }
})
```

## Troubleshooting

### ❌ "Application OutOfSync"

**Causa:** Cluster está diferente do Git

**Solução:**
```bash
# Ver diff
kubectl argocd app diff togglemaster-auth-service

# Sincronizar
kubectl -n argocd patch app togglemaster-auth-service \
  -p '[{"op":"replace","path":"/spec/syncPolicy/syncOptions","value":["Prune=true","SelfHeal=true"]}]' \
  --type merge
```

### ❌ "ImagePullBackOff"

**Causa:** ECR credentials não configurados

**Solução:**
```bash
# Criar imagePullSecrets
kubectl create secret docker-registry aws-ecr \
  --docker-server=12345.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-1) \
  -n togglemaster

# Adicionar ao deployment:
# imagePullSecrets:
# - name: aws-ecr
```

### ❌ "Pod Not Starting"

**Debug:**
```bash
# Logs do pod
kubectl logs auth-service-abc123 -n togglemaster

# Descrever pod
kubectl describe pod auth-service-abc123 -n togglemaster

# Próximos eventos
kubectl get events -n togglemaster --sort-by='.lastTimestamp'
```

## Rollback Automático

Se uma versão quebrar, ArgoCD permite reverter rapidinho:

```bash
# Ver histórico de sincronizações
argocd app history togglemaster-auth-service

# Rollback para versão anterior
argocd app rollback togglemaster-auth-service 0
```

## Próximos Passos

1. ✅ ArgoCD instalado
2. ✅ Aplicações sincronizadas
3. ⏭️ Configurar Monitoring (Prometheus + Grafana)
4. ⏭️ Configurar Ingress para acesso externo
5. ⏭️ Configurar Secrets Manager

---

**Documentação:**
- [ArgoCD Documentation](https://argoproj.github.io/argo-cd/)
- [GitOps Best Practices](https://www.gitops.tech/)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
