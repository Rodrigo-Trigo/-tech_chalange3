# Roteiro Técnico - Ejecutar Demonstração Completa

## 🎯 Objetivo
Executar o pipeline completo de IaC, CI/CD e GitOps do ToggleMaster para demonstrar a Phase 3.

## ⏱️ Tempo Total Estimado: 2-3 horas (execução + ajustes)

---

## 📋 PRÉ-REQUISITOS

### 1. Ambiente Local
```bash
# Ferramentas necessárias
brew install terraform kubectl aws-cli helm

# Versões mínimas
terraform version      # >= 1.0
kubectl version --client  # >= 1.24
aws --version         # >= 2.0
helm version          # >= 3.0
```

### 2. Credenciais AWS
```bash
# AWS Academy
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."

# OU Conta Pessoal
aws configure
```

### 3. GitHub
```bash
# Personal Token com permissões:
# - repo (completo)
# - workflow
# - gist

export GITHUB_TOKEN="ghp_..."
```

---

## 🚀 PASSO 1: PROVISIONAR INFRAESTRUTURA COM TERRAFORM (30 min)

### 1.1 Workspace Terraform
```bash
cd terraform/

# Copiar exemplo de variáveis
cp terraform.tfvars.example terraform.tfvars

# Editar com seus valores (optional - use defaults)
vim terraform.tfvars
```

### 1.2 Inicializar Terraform
```bash
# Primeira vez
terraform init

# Validar
terraform validate                    # ✅ Sem erros
terraform fmt -recursive              # Formatar código
```

### 1.3 Criar Infraestrutura
```bash
# Ver plano
terraform plan -out=tfplan

# Contar recursos que serão criados
terraform show tfplan | grep "resource" | wc -l

# Aplicar - vai criar:
# ✅ VPC + Subnets (públicas/privadas)
# ✅ EKS Cluster + Node Groups
# ✅ 3x RDS PostgreSQL
# ✅ ElastiCache Redis
# ✅ DynamoDB Analytics
# ✅ SQS Queues
# ✅ 5x ECR Repositories
# ✅ S3 Backend + DynamoDB Locks

terraform apply tfplan
```

### 1.4 Capturar Outputs
```bash
# Guardar outputs - necessários más tarde
terraform output > ../terraform-outputs.txt

# Salvar de forma segura
terraform output -json > ../terraform-outputs.json
```

### 1.5 Conectar ao EKS
```bash
# Atualizar kubeconfig
aws eks update-kubeconfig \
  --name togglemaster-cluster \
  --region us-east-1

# Verificar conexão
kubectl get nodes                     # Esperar status: Ready
kubectl get pods -n kube-system       # Serviços padrão do K8s
```

**Capturas de tela:**
- Terminal: `terraform apply` executando
- AWS Console: Resources criados (EKS, RDS, DynamoDB, etc)
- Terminal: `kubectl get nodes` mostrando 2+ nodes

---

## 🔒 PASSO 2: INSTALAR E CONFIGURAR ARGOCD (15 min)

### 2.1 Aplicar Namespaces
```bash
cd gitops/argocd/

# Criar namespaces
kubectl apply -f namespaces.yaml

# Verificar
kubectl get namespace
```

### 2.2 Instalar ArgoCD via Helm
```bash
# Adicionar repo
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Instalar
helm install argocd argo/argo-cd \
  --namespace argocd \
  --set server.insecure=true \
  --set server.service.type=LoadBalancer
```

### 2.3 Aguardar ArgoCD estar pronto
```bash
# Monitorar até tudo estar Running
kubectl get deployment -n argocd -w

# Quando todos estiverem "1/1 Ready":
# Pressione Ctrl+C
```

### 2.4 Acessar UI ArgoCD
```bash
# Port-forward
kubectl port-forward -n argocd svc/argocd-server 8080:443 &

# Obter senha admin
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo ""

# Abrir no navegador: https://localhost:8080
# Usuário: admin
# Senha: (output anterior)
```

### 2.5 Configurar Repositório GitHub
```bash
# Editar secrets com suas credenciais
# IMPORTANTE: Atualizar a URL e token

kubectl -n argocd patch secret argocd-repo-creds-github \
  -p '{"stringData":{"url":"https://github.com/SEU_USUARIO/SEU_REPO.git","password":"YOUR_GITHUB_TOKEN"}}'
```

### 2.6 Criar ArgoCD Applications
```bash
# Aplicar manifestos (5 aplicações)
kubectl apply -f applications.yaml

# Aguardar sincronização inicial (pode demorar 3-5 min)
kubectl wait --for=condition=Synced \
  application/togglemaster-auth-service \
  -n argocd --timeout=300s

# Verificar status
kubectl get applications -n argocd
```

**Capturas de tela:**
- Terminal: Helm installation progredindo
- ArgoCD UI: Página de login
- ArgoCD UI: Applications dashboard com 5 serviços
- Terminal: `kubectl get pods -n togglemaster` mostrando pods rodando

---

## 📝 PASSO 3: DEMONSTRAR CI/CD - CÓDIGO SEGURO (15 min)

### 3.1 Preparar Branch de Teste
```bash
# Clonar repositório (se não estiver em workspace)
git clone https://github.com/SEU_USUARIO/SEU_REPO.git
cd seu-repo

# Criar branch de teste
git checkout -b demo/pipeline-normal
```

### 3.2 Fazer Mudança Simples (Segura)
```bash
# Editar um arquivo Python ou Go (mudança inócua)
# Exemplo: atualizar comentário, mudar log message, etc

# Auth Service (Go)
vim auth-service/handlers.go
# Mudar uma string de log

# OU Analytics Service (Python)
vim analytics-service/app.py
# Mudar um comentário
```

### 3.3 Fazer Commit e Push
```bash
# Adicionar mudança
git add auth-service/
git commit -m "feat: update log message for better debugging"

# Push
git push origin demo/pipeline-normal
```

### 3.4 Criar PR
```bash
# GitHub CLI (se instalado)
gh pr create --title "Demo: Normal CI/CD Flow" \
  --body "Testing successful CI pipeline"

# OU via navegador: https://github.com/SEU_USUARIO/SEU_REPO/pulls
```

### 3.5 Monitorar Pipeline
```bash
# Ver actions em tempo real
# https://github.com/SEU_USUARIO/SEU_REPO/actions

# Ou via CLI
gh run list --workflow=ci-cd-go-services.yml

# Assistir em tempo real
gh run watch <RUN_ID>

# Ver logs
gh run view <RUN_ID> --log
```

### 3.6 Verificar Sucesso
```bash
# ✅ Build passed
# ✅ Lint passed
# ✅ SAST passed
# ✅ SCA passed
# ✅ Docker Build passed
# ✅ Container Scan passed
# ✅ Push to ECR passed
# ✅ GitOps Update PR created

# Verificar imagem no ECR
aws ecr describe-images \
  --repository-name togglemaster/auth-service \
  --region us-east-1 | jq '.imageDetails[0].imageTags'
```

**Capturas de tela:**
- GitHub PR criada
- GitHub Actions: Todos os jobs rodando em paralelo
- GitHub Actions: Todos os jobs com checkmark ✅
- GitHub terminal mostrando ECR image URI
- ArgoCD detectando mudança e sincronizando

---

## 🚨 PASSO 4: DEMONSTRAR SEGURANÇA - VULNERABILIDADE BLOQUEADA (20 min)

### 4.1 Criar Branch com Vulnerabilidade
```bash
git checkout -b demo/vulnerable-code
```

### 4.2 Adicionar Vulnerabilidade

#### Opção A: Go
```bash
# Editar go.mod para adicionar dependência vulnerável
vim auth-service/go.mod

# Adicionar linha (exemplo):
require (
    github.com/some-malicious-lib/vulnerable v0.0.1  # Known CVE
)

# Go mod tidy
cd auth-service
go mod tidy
```

#### Opção B: Python
```bash
# Editar requirements.txt
vim analytics-service/requirements.txt

# Adicionar:
urllib3==1.26.5    # Known vulnerability
requests==2.27.0   # Known vulnerability
```

### 4.3 Fazer Commit e Push
```bash
git add auth-service/go.mod analytics-service/requirements.txt
git commit -m "test: add vulnerable dependencies to test security gates"
git push origin demo/vulnerable-code
```

### 4.4 Criar PR
```bash
gh pr create --title "Demo: Vulnerable Code (Should Fail)" \
  --body "This should fail security checks"
```

### 4.5 Observar Falha

```bash
# Monitorar Actions - vai FALHAR ❌
# Aguardar o job de SAST/SCA terminar

gh run list --workflow=ci-cd-go-services.yml
gh run watch <RUN_ID>

# Ver logs de falha
gh run view <RUN_ID> --log | grep -A10 "trivy\|gosec\|bandit\|CRITICAL"
```

### 4.6 Verificar Bloqueios
```bash
# ❌ Build passed
# ❌ Lint passed
# ✅ SAST FAILED - Vulnerabilidade encontrada
# ✅ SCA FAILED - Dependência vulnerável
# ❌ Docker build não executou
# ❌ Push para ECR não executou
# ❌ GitOps update não executou

# Imagem NOT criada
aws ecr describe-images \
  --repository-name togglemaster/auth-service
  # Sem nova imagem!
```

### 4.7 Demonstrar Bloqueio de PR
```bash
# Ir no GitHub, mostrar que PR não pode ser mergeada
# "PR checks have failed"

# Terminal output
echo "❌ Pipeline bloqueado por vulnerabilidade crítica"
echo "Desenvolvedort deve corrigir antes de proceder"
```

**Capturas de tela:**
- GitHub Actions: SAST/SCA jobs com ❌
- Log mostrando: "CRITICAL vulnerability detected"
- GitHub PR: Status "Changes requested" (bloqueada)
- AWS ECR: Sem nova imagem enviada

---

## ✅ PASSO 5: CORRIGIR E REEXECUTA (10 min)

### 5.1 Remover Vulnerabilidade
```bash
# Remover dependência maliciosa
vim auth-service/go.mod
vim analytics-service/requirements.txt

# Remover as linhas adicionadas

# Go
cd auth-service && go mod tidy

# Python
pip install -r analytics-service/requirements.txt
```

### 5.2 Testar Localmente
```bash
# Go
cd auth-service
go test ./...
go run main.go &  # Verificar se startup OK

# Python
cd analytics-service
pytest
python app.py &   # Verificar se startup OK
```

### 5.3 Commit e Push
```bash
git add auth-service/ analytics-service/
git commit -m "fix: remove vulnerable dependencies"
git push origin demo/vulnerable-code  # Atualiza a PR
```

### 5.4 Observar Sucesso
```bash
# Monitorar Actions - agora vai PASSAR ✅
gh run watch <NEW_RUN_ID>

# Todos os jobs vão passar
# GitOps PR será criada
# Imagem será enviada ao ECR
```

### 5.5 Verificar ArgoCD sincronizando
```bash
# No ArgoCD UI, ver:
# - PR detectada
# - Sincronização iniciada
# - Pods sendo atualizados

# No terminal
kubectl get pods -n togglemaster -w
# Ver: Pods antigos terminando, novos pods começando
```

**Capturas de tela:**
- GitHub Actions: Todos os jobs ✅
- ArgoCD UI: Sincronização em progresso
- Terminal: Rolling update de pods
- ECR: Nova imagem com tag do commit

---

## 📊 PASSO 6: DEMONSTRAR ARGOCD EM AÇÃO (10 min)

### 6.1 Acessar ArgoCD UI
```bash
# https://localhost:8080
# Login: admin / (senha obtida anteriormente)
```

### 6.2 Explorar Applications
```bash
# Mostrar 5 aplicações em SYNC
# Clicar em togglemaster-auth-service

# Ver:
# - Deployment
# - Service
# - ServiceAccount
# - Secret
# - Pods (2 replicas)
```

### 6.3 Ver Pods com Health
```bash
# No ArgoCD, expandir "Pods"
# Ver probes passando:
# ✅ Liveness Probe OK
# ✅ Readiness Probe OK
```

### 6.4 Fazer Manual Sync (Demonstração)
```bash
# Editar deployment.yaml no git
vim gitops/applications/auth-service/deployment.yaml

# Mudar replicas de 2 para 3
# replicas: 3

git add gitops/
git commit -m "demo: scale to 3 replicas"
git push origin main

# No ArgoCD, clicar "Sync"
# Ver 3 pods sendo criados
```

### 6.5 Demonstrar Rollback
```bash
# No ArgoCD, clicar "History"
# Ver versão anterior
# Clicar "Rollback"

# Pods revertem para 2 replicas
```

**Capturas de tela:**
- ArgoCD Dashboard
- ArgoCD Applications sidebar
- ArgoCD Application Detail (auth-service)
- ArgoCD Network view (mostrando DaG de resources)
- ArgoCD Logs
- ArgoCD History & Rollback modal

---

## 🎯 PASSO 7: CAPTURAS FINAIS PARA VÍDEO (5 min)

### 7.1 Screenshot - Terraform
```bash
cd terraform/

# Estrutura
tree -L 3 -I 'modules*' .

# Output
terraform output | head -20

# State remoto
aws s3 ls s3://togglemaster-terraform-state-*/
```

### 7.2 Screenshot - GitHub
- Repositório file tree (terraform/ .github/ gitops/)
- GitHub Actions Workflows
- Successful run (todos os jobs ✅)
- Failed run (SAST/SCA bloqueado)
- PR GitOps automática

### 7.3 Screenshot - AWS
- EKS Cluster Dashboard
- Node Groups (2 nodes t3.medium)
- RDS Instances (3x)
- ElastiCache
- DynamoDB Table
- SQS Queues
- ECR Repositories (5x)
- S3 Backend bucket

### 7.4 Screenshot - ArgoCD
- Applications Dashboard (5 apps)
- Application Detail page
- Network graph
- Logs
- Resource tree

### 7.5 Screenshot - Kubernetes
```bash
# Namespaces
kubectl get ns | grep -E 'argocd|togglemaster|kube'

# Pods
kubectl get pods -n togglemaster -o wide

# Resources
kubectl get all -n togglemaster

# Describe pod
kubectl describe pod <AUTH_SERVICE_POD> -n togglemaster | tail -30

# Logs
kubectl logs -n togglemaster -l app=auth-service --tail=20
```

---

## 📝 CHECKLIST FINAL

Antes de gravação:
- [ ] ✅ Terraform terraform.tfstate no S3 (remoto)
- [ ] ✅ EKS Cluster rodando com 2+ nodes
- [ ] ✅ ArgoCD instalado e com 5 applications em SYNC
- [ ] ✅ GitHub Actions workflows configurados
- [ ] ✅ Microsserviços images no ECR
- [ ] ✅ Pods rodando no cluster
- [ ] ✅ ArgoCD UI acessível
- [ ] ✅ Exemplos de vulnerabilidade prontos para demo

---

## 🚨 Troubleshooting Rápido

| Problema | Solução |
|----------|---------|
| EKS node não pronto | `aws eks describe-nodegroup` |
| ArgoCD stuck | `kubectl restart deployment -n argocd` |
| Pod ImagePullBackOff | Criar image pull secret do ECR |
| SQS queue não criada | Verificar Terraform apply completo |
| GitHub Actions não rodando | Verificar secrets (AWS_ROLE_TO_ASSUME) |
| ArgoCD OutOfSync | `kubectl patch app` com syncPolicy |

---

## 💾 Backup & Limpeza

### Salvar Outputs
```bash
terraform output -json > backup-outputs.json
kubectl get all -n togglemaster -o yaml > backup-k8s.yaml
```

### Destruir Tudo (quando terminar demo)
```bash
# WARNING: Isso deleta TUDO

# 1. Deletar ArgoCD Applications
kubectl delete app -n argocd --all

# 2. Deletar Terraform
cd terraform/
terraform destroy

# 3. Deletar S3 backend
aws s3 rb s3://togglemaster-terraform-state-ACCOUNTID --force
```

---

**Pronto! Você pode agora executar a demonstração completa!** 🎉

