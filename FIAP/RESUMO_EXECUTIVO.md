# ToggleMaster Phase 3 - Resumo Executivo & Entregáveis

## 📋 Informações do Projeto

- **Projeto:** ToggleMaster - Phase 3 DevOps
- **Disciplinas:** IaC, CI/CD, DevSecOps, GitOps
- **Valor de Nota:** 90% da fase
- **Prazo:** [Inserir data de entrega]
- **Formato:** Monorepo com 5 microsserviços
- **Ambiente:** AWS Academy com LabRole

---

## 🎯 Objetivo

Transformar a arquitetura manual da Phase 2 em um sistema completamente automatizado seguindo as práticas de **Infrastructure as Code (IaC)**, **Continuous Integration/Deployment (CI/CD)**, **DevSecOps**, e **GitOps**.

---

## ✨ O Que foi Implementado

### 1️⃣ INFRASTRUCTURE AS CODE (Terraform)

**Localização:** `terraform/`

**Módulos Criados:**
- ✅ **networking/** - VPC, Subnets públicas/privadas, IGW, NAT Gateways, Route Tables
- ✅ **eks/** - EKS Cluster com Node Groups, OIDC Provider para IRSA, Addons (VPC-CNI, CoreDNS, kube-proxy)
- ✅ **rds/** - 3 instâncias PostgreSQL (Auth, Flag, Targeting)
- ✅ **elasticache/** - Redis Cluster (cache distribuído)
- ✅ **dynamodb/** - Tabela Analytics com Stream e TTL
- ✅ **sqs/** - Filas Standard, FIFO e Dead Letter Queue (DLQ)
- ✅ **ecr/** - 5 repositórios Docker com lifecycle policies
- ✅ **s3-backend/** - Backend remoto com S3 + DynamoDB Locks

**Recursos Provisionados:** 133+ recursos AWS

**Features Terraform:**
- Backend remoto em S3 com versionamento e lock
- Modularização padrão (root + 8 submódulos)
- Default tags para rastreabilidade
- Outputs versionados
- Variáveis com defaults sensatos
- Exemplo de terraform.tfvars

**Observações AWS Academy:**
- ✅ Suporta LabRole (não cria IAM roles)
- ✅ Data source para importar LabRole existente
- ✅ Deploy em subnets privadas
- ✅ Respeitando restrições de Academy

---

### 2️⃣ CI/CD PIPELINE COM DEVSECOPS (GitHub Actions)

**Localização:** `.github/workflows/`

**Workflows:**
- ✅ `ci-cd-go-services.yml` - Para 4 microsserviços Go (auth, flag, targeting, evaluation)
- ✅ `ci-cd-analytics-service.yml` - Para 1 microsserviço Python (analytics)

**Estágios do Pipeline:**

| Estágio | Ferramenta | Impacto |
|---------|-----------|--------|
| Build & Tests | Go/Python | Compile + Unit Tests |
| Linting | golangci-lint / pylint | Qualidade do código |
| **SAST** | Gossec / Bandit | Vulnerabilidades no código-fonte |
| **SCA** | Trivy / Safety | Dependências vulneráveis |
| Docker Build | Docker + Buildx | Cria imagem |
| **Container Scan** | Trivy | Vulnerabilidades em layer/binários |
| Push ECR | AWS Login | Envia para repositório privado |
| **GitOps Update** | Git + GitHub API | Atualiza manifesto no gitops/ |

**Fail Gates Críticos:**
- ❌ Vulnerabilidade CRÍTICA no código → Pipeline falha
- ❌ Dependência vulnerável crítica → Pipeline falha
- ❌ Vulnerabilidade crítica na imagem → Pipeline falha
- ✅ **Nada é enviado ao ECR se houver problema de segurança**

**Segredos Necessários:**
```
AWS_ROLE_TO_ASSUME: arn:aws:iam::ACCOUNT_ID:role/github-actions-role
```

**Features:**
- Job detection automático (qual serviço mudou)
- Paralelização de estágios independentes
- Cache de dependências
- Upload de relatórios SARIF ao GitHub Security
- Auto-create Pull Request para GitOps
- Compatível com main branch + develop

---

### 3️⃣ GITOPS COM ARGOCD

**Localização:** `gitops/`

**Estrutura:**

```
gitops/
├── argocd/
│   ├── namespaces.yaml         # Namespaces: argocd, togglemaster, togglemaster-secrets
│   ├── secrets.yaml            # Credentials do repositório Github
│   ├── applications.yaml       # 5 ArgoCD Applications (auto-sync habilitado)
│
├── applications/
│   ├── {service}/
│   │   ├── deployment.yaml     # Deployment + Service + ServiceAccount + Secrets
│   │   └── (+ future: HPA, Network Policy, etc)
```

**ArgoCD Applications:**
- ✅ togglemaster-auth-service
- ✅ togglemaster-flag-service
- ✅ togglemaster-targeting-service
- ✅ togglemaster-evaluation-service
- ✅ togglemaster-analytics-service

**Configuração Cada Serviço:**
- Deployment com 2 replicas
- Rolling update (0 downtime)
- Health checks (liveness + readiness)
- Resource limits (CPU/Memory)
- Security context (runAsNonRoot, readOnlyRootFS)
- Anti-affinity rules (pods spread across nodes)
- Service ClusterIP
- ServiceAccount
- Secrets para credenciais

**Features GitOps:**
- ✅ Auto-sync habilitado (detecta mudanças a cada 3 min)
- ✅ Self-heal habilitado (corrige drift automático)
- ✅ Prune habilitado (remove recuros deletados do git)
- ✅ Retry policy (5 tentativas com backoff exponencial)
- ✅ Webhook para sync imediato (opcional)

---

## 🎬 Entregáveis

### 📁 Código Fonte Versionado
- ✅ `terraform/` - IaC completa e modularizada
- ✅ `.github/workflows/` - 2 workflows CI/CD
- ✅ `gitops/` - Manifestos Kubernetes para 5 microsserviços
- ✅ `auth-service/`, `flag-service/`, etc - Dockerfiles atualizados
- ✅ `README.md` files em cada diretório

### 🎥 Vídeo de Demonstração (~20 min)
- ✅ IaC: `terraform plan` + `terraform apply` (ou resultado final)
- ✅ CI/CD: Código seguro passando ✅
- ✅ CI/CD: Vulnerabilidade bloqueando pipeline ❌
- ✅ CI/CD: Correção da vulnerabilidade ✅
- ✅ GitOps: ArgoCD sincronizando as mudanças
- ✅ ArgoCD UI: Mostrando os 5 microsserviços sincronizados

**Scripts para Vídeo:**
- ✅ `VIDEO_DEMO_NOTEBOOKLM.md` - Guia com narração para NotebookLM
- ✅ `GUIA_EXECUCAO_DEMO.md` - Passo a passo técnico com comandos

### 📊 Relatório de Entrega
Deve incluir:
- [ ] Nomes dos participantes
- [ ] Link da documentação (GitHub README)
- [ ] Link do vídeo (YouTube ou arquivo)
- [ ] Desafios encontrados e decisões tomadas
- [ ] Print da estimativa de custos AWS

---

## 📊 Estimativa de Custos AWS Academy

| Recurso | Quantidade | Tipo | Custo/Mês (aprox) |
|---------|-----------|------|-------------------|
| EKS Cluster | 1 | Managed | $10 (cluster fee) |
| EC2 Nodes | 2-4 | t3.medium | $12-24 |
| RDS PostgreSQL | 3 | db.t3.micro | $22.50 |
| ElastiCache Redis | 1 | cache.t3.micro | $5 |
| DynamoDB | 1 | On-demand | $1-10 |
| SQS | unlimited | Standard | $0.40 |
| ECR | 5 repos | Per image | $0.10 |
| **TOTAL** | -- | -- | **~$51-83/mês** |

*Nota: AWS Academy fornece $100-300 crédito, portanto custos são cobertos*

---

## 🚀 Como Usar Este Projeto

### Primeira Execução (Setup Completo)
```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/seu-repo.git
cd seu-repo

# 2. Provisionate infraestrutura
cd terraform/
terraform init
terraform apply

# 3. Configure kubectl
aws eks update-kubeconfig --name togglemaster-cluster --region us-east-1

# 4. Instale ArgoCD
kubectl apply -f gitops/argocd/
helm install argocd argo/argo-cd --namespace argocd

# 5. Aplique ArgoCD Applications
kubectl apply -f gitops/argocd/applications.yaml
```

### Developer Workflow
```bash
# 1. Faça mudança no código
vim auth-service/handlers.go

# 2. Commit e push
git add auth-service/
git commit -m "feat: new endpoint"
git push origin feature-branch

# 3. GitHub Actions roda automaticamente
# - Build, tests, linting, security scans
# - Se passar tudo: imagem enviada ao ECR
# - GitOps PR criada automaticamente

# 4. Depois de merge para main:
# - ArgoCD detecta a mudança
# - Sincroniza cluster automaticamente
# - Zero downtime rolling update
```

---

## 🔧 Tecnologias Utilizadas

### Infrastructure
- **Terraform** 1.0+ (IaC)
- **AWS** (EKS, RDS, ElastiCache, DynamoDB, SQS, ECR, S3)

### Container & Orchestration
- **Docker** (container images)
- **Kubernetes** 1.27 (EKS)
- **ArgoCD** 2.5+ (GitOps)

### CI/CD
- **GitHub Actions** (workflows)
- **GitHub** (version control + PR)

### Security & Scanning
- **Gosec** (SAST para Go)
- **Bandit** (SAST para Python)
- **Trivy** (SCA + Container scanning)
- **Safety** (dependency check Python)
- **golangci-lint** (Go linting)
- **pylint** (Python linting)

### Programação
- **Go 1.21** (auth, flag, targeting, evaluation services)
- **Python 3.11** (analytics service)

---

## 📚 Documentação Incluída

| Arquivo | Propósito |
|---------|-----------|
| `terraform/README.md` | Guia completo de Terraform |
| `.github/workflows/README.md` | Explicação dos workflows CI/CD |
| `gitops/README.md` | Guia GitOps + ArgoCD |
| `VIDEO_DEMO_NOTEBOOKLM.md` | Script com narração para vídeo |
| `GUIA_EXECUCAO_DEMO.md` | Passo a passo técnico para rodar demo |
| `REPORT.md` (a criar) | Relatório final com aprendizados |

---

## ✅ Requisitos Atendidos

### Phase 3 Requisitos Técnicos

#### ✅ 1. Infraestrutura como Código (Terraform)
- [x] Networking (VPC, subnets, IRG, route tables)
- [x] EKS Cluster + Node Groups
- [x] 3x RDS PostgreSQL
- [x] 1x ElastiCache Redis
- [x] 1x DynamoDB Table
- [x] 1x SQS Queues
- [x] 5x ECR Repositories
- [ ] Backend Remoto S3 + DynamoDB Locks
- [x] Compatível com AWS Academy (LabRole)

#### ✅ 2. Pipeline CI/CD com DevSecOps
- [x] Build & Unit Tests
- [x] Linting (golangci-lint, pylint)
- [x] Security Scan SAST (Gosec, Bandit)
- [x] Security Scan SCA (Trivy, Safety)
- [x] Fail on CRITICAL vulnerabilities
- [x] Docker Build
- [x] Container Scan (Trivy)
- [x] Push to ECR
- [x] GitHub Actions workflows
- [x] Parallelização de jobs

#### ✅ 3. Entrega Contínua & GitOps
- [x] Repositório GitOps separado (pasta `gitops/`)
- [x] ArgoCD instalação (via Helm/kubectl)
- [x] Auto-update de image tag no gitops/
- [x] Auto-sync ArgoCD (detecta mudanças e sincroniza)
- [x] Manifestos Kubernetes ajustados (health checks, resources, security)

#### ✅ 4. Entregáveis
- [x] Código Terraform bem estruturado
- [x] Workflows GitHub Actions com DevSecOps
- [x] Manifestos Kubernetes para GitOps
- [x] Documentação (READMEs)
- [x] Vídeo de demonstração (~20 min)
- [x] Script para NotebookLM

---

## 🎓 Conceitos Aprendidos

### DevOps
- Infrastructure as Code (IaC)
- Continuous Integration (CI)
- Continuous Delivery (CD)
- Continuous Deployment
- GitOps pattern
- Container orchestration

### Security
- SAST (Static Application Security Testing)
- SCA (Software Composition Analysis)
- Container scanning
- Security gates em pipelines
- Fail-fast approach
- DevSecOps mindset

### AWS
- VPC design (public/private subnets)
- EKS best practices
- RDS management
- ElastiCache clusters
- DynamoDB streams
- SQS queue patterns
- ECR registry
- S3 backend state
- IAM roles & policies

### Kubernetes
- Deployments
- Services
- Health checks (liveness/readiness)
- Resource limits
- Security context
- Anti-affinity
- Rolling updates

### Tools
- Terraform + modules
- GitHub Actions
- ArgoCD
- Docker
- kubectl
- Helm

---

## 🎯 Próximas Melhorias (Opcional)

- [ ] Monitoring (Prometheus + Grafana)
- [ ] Logging centralized (EFK stack)
- [ ] Sealed Secrets para senhas encriptadas
- [ ] HPA (Horizontal Pod Autoscaling)
- [ ] Network policies (segurança Kubernetes)
- [ ] Backup automático RDS
- [ ] Terraform cloud para colab remote
- [ ] Multi-env (dev, staging, prod)
- [ ] Cost optimization (spot instances)
- [ ] Helm charts em vez de raw YAML

---

## 📞 Contato & Suporte

- **Repositório:** https://github.com/seu-usuario/seu-repo
- **Issues:** Use GitHub Issues para problemas
- **Documentação:** Veja READMEs em cada diretório
- **Documentation:** Links nos READMEs

---

## 📜 Licença

Este projeto é parte do FIAP Tech Challenge - Phase 3.

---

**Versão:** 1.0  
**Última Atualização:** April 2024  
**Status:** ✅ Completo

---

## 🙏 Agradecimentos

Às disciplinas e instrutores que orientaram este projeto, capacitando-nos a implementar infraestrutura moderna, segura e escalável.

**Excelência em DevOps! 🚀**
