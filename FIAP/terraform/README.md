# Infraestrutura como Código com Terraform

## Visão Geral

Este diretório contém toda a infraestrutura do **ToggleMaster** definida como código usando **Terraform**.

### Recursos Provisionados

- ✅ **Networking**: VPC com subnets públicas e privadas
- ✅ **EKS**: Cluster Kubernetes com Node Groups
- ✅ **RDS**: 3 instâncias PostgreSQL (Auth, Flag, Targeting)
- ✅ **ElastiCache**: Cluster Redis
- ✅ **DynamoDB**: Tabela Analytics com Stream
- ✅ **SQS**: Filas de mensagem (Standard + FIFO + DLQ)
- ✅ **ECR**: Repositórios Docker para 5 microsserviços
- ✅ **S3**: Backend remoto para terraform.tfstate

## Estrutura de Diretórios

```
terraform/
├── main.tf                    # Root module - usa todos os submódulos
├── variables.tf               # Variáveis root
├── outputs.tf                 # Outputs root
├── terraform.tfvars.example   # Exemplo de variáveis
├── backend.tf                 # Configuração de backend (comentada)
├── modules/
│   ├── s3-backend/            # Backend remoto (S3 + DynamoDB)
│   ├── networking/            # VPC, Subnets, IGW, NAT
│   ├── eks/                   # EKS Cluster + Node Groups + OIDC
│   ├── rds/                   # 3 instâncias RDS PostgreSQL
│   ├── elasticache/           # ElastiCache Redis
│   ├── dynamodb/              # DynamoDB Analytics
│   ├── sqs/                   # SQS Queues + DLQ
│   └── ecr/                   # ECR Repositories (5 serviços)
└── README.md                  # Este arquivo
```

## Pré-requisitos

### 1. Ferramentas Necessárias
```bash
# Terraform
terraform --version  # >= 1.0

# AWS CLI v2
aws --version        # >= 2.0

# kubectl
kubectl version      # >= 1.24

# Helm (para ArgoCD)
helm version         # >= 3.0
```

### 2. Credenciais AWS

Configure suas credenciais usando uma das opções:

**Option A: AWS Academy (com LabRole)**
```bash
# Via AWS CLI com token de sessão
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."
```

**Option B: Conta Pessoal**
```bash
aws configure
# Insira: Access Key, Secret Key, região (us-east-1)
```

## Passos de Execução

### Passo 1: Criar o Backend Remoto (S3 + DynamoDB)

```bash
cd terraform/

# Crie um arquivo local com backend vazio
cat > backend-local.tf <<EOF
# Backend remoto será criado após primeiro init
EOF

# Initialize Terraform (com backend local temporário)
terraform init

# Crie o S3 bucket e DynamoDB table
terraform plan -target=module.s3_backend
terraform apply -target=module.s3_backend
```

**Output esperado:**
```
Outputs:

s3_backend_bucket_id = "togglemaster-terraform-state-123456789"
terraform_lock_table = "togglemaster-terraform-locks"
```

### Passo 2: Configurar Backend Remoto

Edite o arquivo `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "togglemaster-terraform-state-123456789"  # Use o output do Passo 1
    key            = "toolkit/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "togglemaster-terraform-locks"
  }
}
```

Então execute:

```bash
terraform init
# Quando perguntado, responda: yes
# Isso vai migrar o estado para S3
```

### Passo 3: Validar Configuração

```bash
# Validar sintaxe
terraform validate

# Verificar formato
terraform fmt -recursive

# Planejar mudanças
terraform plan
```

### Passo 4: Criar a Infraestrutura

```bash
# Aplicar configuração
terraform apply

# Revisar o plano e digitar 'yes' quando solicitado
```

**Tempo aproximado: 20-30 minutos**

### Passo 5: Configurar kubectl

```bash
# Atualizar kubeconfig
aws eks update-kubeconfig \
  --name togglemaster-cluster \
  --region us-east-1

# Verificar conexão
kubectl get nodes
```

### Passo 6: Instalar ArgoCD

```bash
# Criar namespace
kubectl create namespace argocd

# Instalar ArgoCD via Helm
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd \
  --namespace argocd \
  --values argocd-values.yaml

# Acessar UI (port-forward)
kubectl port-forward -n argocd svc/argocd-server 8080:443
# Acesse: https://localhost:8080
```

## Variáveis Personalizáveis

Crie um arquivo `terraform.tfvars`:

```hcl
aws_region            = "us-east-1"
environment           = "production"
desired_size          = 2
rds_instance_class    = "db.t3.micro"
kubernetes_version    = "1.27"
```

Veja `terraform.tfvars.example` para todas as variáveis disponíveis.

## Destruir a Infraestrutura

⚠️ **CUIDADO**: Isso vai deletar TUDO (incluindo dados em RDS e DynamoDB)

```bash
# Verificar recursos que serão deletados
terraform plan -destroy

# Destruir infraestrutura
terraform destroy

# Se houver erros, destrua o S3 backend manualmente:
aws s3 rb s3://togglemaster-terraform-state-123456789 --force
```

## Troubleshooting

### Erro: "LabRole not found"

**Solução**: Verifique que você está usando AWS Academy e a LabRole existe:
```bash
aws iam get-role --role-name LabRole
```

### Erro: "no subnets found"

**Solução**: Verifique que os subnets foram criados:
```bash
terraform state list | grep subnet
```

### Erro: "InvalidParameterValue" em RDS

**Solução**: Use instância class compatível (db.t3.micro, db.t2.small)

### Estado Corrompido

**Reset completo:**
```bash
# Remove estado local
rm -rf .terraform terraform.tfstate*

# Remove backend S3 (se necessário)
aws s3 rb s3://togglemaster-terraform-state-XXX --force

# Reinicialize
terraform init
```

## Próximos Passos

1. ✅ Infraestrutura provisionada
2. ⏭️ Configurar **GitHub Actions Workflows** para CI/CD
3. ⏭️ Deploy de **ArgoCD** para GitOps
4. ⏭️ Atualizar secretos em **Kubernetes Secrets**

## Documentação

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EKS Best Practices](https://aws.amazon.com/eks/best-practices/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/recommended-practices)

---

**Autor**: ToggleMaster DevOps Team  
**Última Atualização**: 2024
