# 🚀 ToggleMaster - Phase 3: DevOps Moderno

> Infraestrutura como Código, CI/CD DevSecOps e GitOps em Ação

## 📋 Visão Geral

Este é o **Phase 3 - Automação Completa** do projeto ToggleMaster da FIAP.

Transformamos a arquitetura manual da Phase 2 em um sistema totalmente automatizado seguindo as melhores práticas de **DevOps moderno**:

- 🏗️ **Infrastructure as Code** - Terraform provisiona toda infraestrutura AWS
- 🔒 **DevSecOps** - GitHub Actions com SAST/SCA bloqueando vulnerabilidades
- 🚀 **GitOps** - ArgoCD sincroniza cluster a partir de Git
- 🐳 **Containerização** - 5 microsserviços em Kubernetes

---

## ✨ O Que Está Incluído

### 📁 Diretórios Principais

```
FIAP/
├── terraform/          - Infrastructure as Code (8 módulos)
├── .github/workflows/  - CI/CD Pipelines con DevSecOps
├── gitops/             - Kubernetes manifests + ArgoCD
├── auth-service/       - Microsserviço Auth (Go)
├── flag-service/       - Microsserviço Flag (Go)
├── targeting-service/  - Microsserviço Targeting (Go)
├── evaluation-service/ - Microsserviço Evaluation (Go)
└── analytics-service/  - Microsserviço Analytics (Python)
```

### 📦 Recursos AWS Provisionados

| Recurso | Quantidade | Propósito |
|---------|-----------|----------|
| VPC + Subnets | 1 VPC + 6 subnets | Rede isolada |
| EKS Cluster | 1 | Orquestração Kubernetes |
| Node Groups | 2-4 nodes | Computação |
| RDS PostgreSQL | 3 | Bancos de dados |
| ElastiCache Redis | 1 | Cache distribuído |
| DynamoDB | 1 tabela | Analytics |
| SQS | 3 filas | Mensageria |
| ECR | 5 repositórios | Container registry privado |
| S3 + DynamoDB | Backend remoto | Terraform state remoto |

### 🔄 Pipeline Automático

```
Developer Push
    ↓
GitHub Actions
├─ Build & Tests ✅
├─ Linting ✅
├─ SAST (Gosec) 🔒
├─ SCA (Trivy) 🔒
├─ Docker Build ✅
├─ Container Scan 🔒
├─ Push ECR ✅
└─ Update GitOps PR ✅
    ↓
ArgoCD (Auto-sync)
    ↓
Kubernetes Cluster
    ↓
Produção em Tempo Real! 🚀
```

---

## 🚀 Quick Start (5 minutos)

### 1️⃣ Pré-requisitos

```bash
# Instalar ferramentas
brew install terraform kubectl aws-cli helm git

# Configurar AWS
aws configure
# ou se AWS Academy:
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."
```

### 2️⃣ Provisionar Infraestrutura

```bash
cd terraform/

# Inicializar
terraform init

# Aplicar
terraform apply

# ☕ Esperar ~25-30 minutos
```

### 3️⃣ Conectar ao EKS

```bash
aws eks update-kubeconfig --name togglemaster-cluster --region us-east-1
kubectl get nodes  # Deve mostrar 2+ nodes
```

### 4️⃣ Instalar ArgoCD

```bash
kubectl create namespace argocd

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install argocd argo/argo-cd -n argocd \
  --set server.insecure=true \
  --set server.service.type=LoadBalancer

# Acessar UI
kubectl port-forward -n argocd svc/argocd-server 8080:443 &
# https://localhost:8080
```

### 5️⃣ Aplicar ArgoCD Applications

```bash
kubectl apply -f gitops/argocd/

# Aguardar sincronização
kubectl wait --for=condition=Synced \
  application/togglemaster-auth-service \
  -n argocd --timeout=300s
```

✅ **Pronto! Infraestrutura completa com 5 microsserviços rodando!**

---

## 📚 Documentação

### 🎯 **Comece Aqui**
- 👉 [INDICE_COMPLETO.md](INDICE_COMPLETO.md) - Mapa completo do projeto

### 📖 Guias Específicos
- 🏗️ [terraform/README.md](terraform/README.md) - Terraform detalhado
- 🔄 [.github/workflows/README.md](.github/workflows/README.md) - CI/CD explicado
- 🛠️ [gitops/README.md](gitops/README.md) - GitOps + ArgoCD

### 🎬 Demonstração
- 📹 [VIDEO_DEMO_NOTEBOOKLM.md](VIDEO_DEMO_NOTEBOOKLM.md) - Script para NotebookLM
- 📋 [GUIA_EXECUCAO_DEMO.md](GUIA_EXECUCAO_DEMO.md) - Passo a passo técnico

### 📊 Referência
- 📝 [RESUMO_EXECUTIVO.md](RESUMO_EXECUTIVO.md) - Relatório final

---

## 🎯 Casos de Uso

### Scenario 1: Deploy Seguro em 10 Minutos
```bash
# 1. Developer faz mudança
vim auth-service/handlers.go

# 2. Commit e push
git add auth-service/
git commit -m "feat: new endpoint"
git push origin feature

# 3. GitHub Actions roda automaticamente
# ✅ Build + Tests + Linting + Security Scans
# ✅ Imagem Docker criada e enviada ao ECR
# ✅ PR automática no repositório GitOps

# 4. ArgoCD detecta mudança
# ✅ Sincroniza cluster automaticamente
# ✅ Rolling update de pods (zero downtime)

# Pronto! Novo código em produção sem cliques manuais
```

### Scenario 2: Bloquear Vulnerabilidade

```bash
# 1. Developer insere dependência vulnerável
echo "github.com/malicious-lib/hack v1.0" >> auth-service/go.mod

# 2. Push na branch
git push origin feature

# 3. GitHub Actions detecta [CRITICAL]
# ❌ SAST (Gosec) bloqueia
# ❌ SCA (Trivy) bloqueia
# ❌ Pipeline FALHA

# 4. Imagem NÃO é enviada ao ECR
# 5. PR não pode ser mergeada
# 6. Cluster continua seguro

# Developer corrige e tenta novamente
git commit -am "fix: remove vulnerability"
git push origin feature

# ✅ Pipeline passa
# ✅ Deploy automático
```

### Scenario 3: Rollback em Segundos

```bash
# No ArgoCD UI
1. Clique em "History"
2. Selecione versão anterior
3. Clique "Rollback"

# Cluster volta para versão anterior em <30 segundos
# Sem downtime, sem manual steps
```

---

## 🔒 Segurança Automática

### Ferramentas de Segurança Integradas

| Tool | Tipo | Bloqueia |
|------|------|----------|
| **Gosec** | SAST (Go) | Vulnerabilidades no código Go |
| **Bandit** | SAST (Python) | Vulnerabilidades no código Python |
| **Trivy** | SCA | Dependências vulneráveis |
| **Trivy** | Container Scan | Vulnerabilidades em layers Docker |
| **golangci-lint** | Linting | Go code quality |
| **pylint** | Linting | Python code quality |

### Fail Gates (Pipeline Falha Se)
- ❌ Vulnerabilidade **CRÍTICA** encontrada em código
- ❌ Dependência **CRÍTICA** vulnerável detectada
- ❌ Vulnerabilidade **CRÍTICA** na imagem Docker
- ❌ Build ou testes falharem
- ❌ Linting encontrar problemas críticos

---

## 💻 Workflow de Desenvolvimento

### Para Desenvolvedores

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/togglemaster.git
cd togglemaster

# 2. Crie sua branch
git checkout -b feature/meu-endpoint

# 3. Faça mudanças
vim auth-service/handlers.go

# 4. Teste localmente
cd auth-service
go test ./...
go run main.go

# 5. Commit e push
git add auth-service/
git commit -m "feat: novo endpoint"
git push origin feature/meu-endpoint

# 6. GitHub Actions roda automaticamente
# Ver: https://github.com/seu-usuario/togglemaster/actions

# 7. Se tudo passar, abra PR
gh pr create --title "feat: novo endpoint"

# 8. Após aprovação e merge
$ Main branch → ArgoCD detecta → Deploy automático
```

### Para DevOps/SREs

```bash
# Monitorar infraestrutura
cd terraform/
terraform plan   # Verificar próximas mudanças
terraform apply  # Aplicar atualizações

# Monitorar deployments
kubectl get pods -n togglemaster -w
kubectl logs -f deployment/auth-service -n togglemaster

# Acessar ArgoCD
kubectl port-forward -n argocd svc/argocd-server 8080:443

# Ver estado remoto
terraform state list
terraform state show aws_eks_cluster.main

# Fazer rollback se necessário
kubectl rollout history deployment/auth-service -n togglemaster
kubectl rollout undo deployment/auth-service -n togglemaster
```

---

## 📊 Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                        AWS Academy                           │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │                     VPC (10.0.0.0/16)                  │  │
│  │                                                         │  │
│  │  ┌──────────────────────────────────────────────────┐  │  │
│  │  │           Public Subnets (3)                     │  │  │
│  │  │         NAT Gateways, Internet GW               │  │  │
│  │  └──────────────────────────────────────────────────┘  │  │
│  │                      ↕                                  │  │
│  │  ┌──────────────────────────────────────────────────┐  │  │
│  │  │      EKS Cluster + Node Groups (2-4)            │  │  │
│  │  │                                                  │  │  │
│  │  │  ┌─────────────┐  ┌─────────────┐               │  │  │
│  │  │  │   Auth      │  │   Flag      │               │  │  │
│  │  │  └─────────────┘  └─────────────┘               │  │  │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────┐ │  │  │
│  │  │  │ Targeting   │  │ Evaluation  │  │ Analytics│ │  │  │
│  │  │  └─────────────┘  └─────────────┘  └─────────┘ │  │  │
│  │  │       + ArgoCD (GitOps Controller)             │  │  │
│  │  └──────────────────────────────────────────────────┘  │  │
│  │                      ↕ (via Security Groups)           │  │
│  │  ┌──────────────────────────────────────────────────┐  │  │
│  │  │      Private Subnets (3)                        │  │  │
│  │  │                                                 │  │  │
│  │  │  ┌──────────┐  ┌──────────┐  ┌─────────────┐  │  │  │
│  │  │  │ RDS      │  │ElastiCache│  │  DynamoDB   │  │  │  │
│  │  │  │Auth DB   │  │   Redis   │  │ Analytics   │  │  │  │
│  │  │  └──────────┘  └──────────┘  └─────────────┘  │  │  │
│  │  │  ┌──────────┐  ┌──────────┐  ┌─────────────┐  │  │  │
│  │  │  │ RDS      │  │ RDS      │  │    SQS      │  │  │  │
│  │  │  │Flag DB   │  │Target DB │  │   Queues    │  │  │  │
│  │  │  └──────────┘  └──────────┘  └─────────────┘  │  │  │
│  │  └──────────────────────────────────────────────────┘  │  │
│  │                                                         │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │           S3 (Terraform State Backend)                │  │
│  │           + DynamoDB (State Locks)                    │  │
│  │           + ECR (Docker Registries)                   │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                               │
└─────────────────────────────────────────────────────────────┘

                          ↓ Monitored by ↓

┌─────────────────────────────────────────────────────────────┐
│              GitHub + GitHub Actions                        │
│                                                              │
│  CI/CD Pipeline:                                           │
│  Build → Lint → SAST → SCA → Docker → ECR → GitOps Update │
│                                                              │
└─────────────────────────────────────────────────────────────┘

                          ↓ Synced by ↓

┌─────────────────────────────────────────────────────────────┐
│                    ArgoCD (GitOps)                          │
│                                                              │
│  Monitorar Git Repository → Sincronizar Cluster             │
│  Pull Model (não push - determinístico)                     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎓 Tecnologias

### Infrastructure
- **Terraform** 1.0+ (IaC)
- **AWS** (EKS, RDS, ElastiCache, DynamoDB, SQS, ECR, S3)

### Containerization
- **Docker** (images)
- **Kubernetes 1.27** (EKS)

### CI/CD
- **GitHub** (version control)
- **GitHub Actions** (CI/CD)

### GitOps
- **ArgoCD** 2.5+ (continuous delivery)
- **Helm** (package manger)

### Programming
- **Go 1.21** (4 microsserviços)
- **Python 3.11** (1 microsserviço)

### Security Scanning
- **Gosec** (Go security)
- **Bandit** (Python security)
- **Trivy** (dependency + container scanning)
- **Safety** (Python dependencies)
- **golangci-lint** (Go linting)
- **pylint** (Python linting)

---

## 📊 Requisitos Atendidos

✅ **Terraform modularizado** com todos os recursos  
✅ **Backend remoto** (S3 + DynamoDB Locks)  
✅ **GitHub Actions workflows** com jobs paralelos  
✅ **SAST** (Gosec + Bandit)  
✅ **SCA** (Trivy + Safety)  
✅ **Container scanning** (Trivy)  
✅ **Fail gates** para vulnerabilidades críticas  
✅ **ArgoCD instalado** com 5 applications  
✅ **Auto-sync habilitado**  
✅ **Manifestos K8s** com health checks e security context  
✅ **Auto-update de image tags** no GitOps  
✅ **Documentação completa**  
✅ **Vídeo de demonstração** (20 min)  

---

## 🎯 Próximos Passos

1. **Provisione infraestrutura:**
   ```bash
   cd terraform/ && terraform apply
   ```

2. **Instale ArgoCD:**
   ```bash
   kubectl apply -f gitops/argocd/
   helm install argocd argo/argo-cd -n argocd
   ```

3. **Teste CI/CD:**
   ```bash
   git checkout -b test/demo
   vim auth-service/handlers.go  # altere algo
   git push origin test/demo
   # Veja GitHub Actions rodando
   ```

4. **Crie vídeo:**
   - Use `VIDEO_DEMO_NOTEBOOKLM.md` no [NotebookLM](https://notebooklm.google.com)

5. **Entregue:**
   - Relatório final com links e screenshots

---

## 🚨 Importante

### AWS Academy
- ⚠️ Suporta apenas **LabRole**, não permite criar IAM roles
- ⚠️ Crédito limitado (~$100-300/aluno)
- ⚠️ Destrua recursos após apresentação

### Segurança
- ⚠️ Nunca commitar `terraform.tfvars` com valores reais
- ⚠️ Nunca commitar senhas (usar GitHub Secrets)
- ⚠️ Usar HTTPS/TLS em produção

### Custos
- 💰 Estimativa: ~$50-80/mês
- 💰 Execute `terraform destroy` quando terminar
- 💰 Monitor: `aws ce get-cost-and-usage`

---

## 🆘 Suporte

### Documentação
- [INDICE_COMPLETO.md](INDICE_COMPLETO.md) - Mapa completo
- [terraform/README.md](terraform/README.md) - Terraform details
- [.github/workflows/README.md](.github/workflows/README.md) - CI/CD details
- [gitops/README.md](gitops/README.md) - ArgoCD setup

### Troubleshooting
- Veja seções de troubleshooting em cada README
- Cheque [GUIA_EXECUCAO_DEMO.md](GUIA_EXECUCAO_DEMO.md) para problemas comuns

### Issues
Use GitHub Issues para reportar problemas

---

## 📄 Licença

Parte do FIAP Tech Challenge - Phase 3

---

## 🙏 Agradecimentos

Às disciplinas que orientaram este projeto.

**Obrigado aos instrutores!** 👏

---

<div align="center">

### ⭐ Se isso foi útil, deixe uma star! ⭐

**DevOps moderno em ação** 🚀

</div>
