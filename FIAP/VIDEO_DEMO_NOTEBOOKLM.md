# Script de Demonstração - ToggleMaster DevOps Phase 3
## Vídeo Gerado via Google NotebookLM

### ⏱️ Duração Total: ~20 minutos
### 🎬 Formato: Narração + Capturas de Tela + Terminal

---

## 📌 INSTRUÇÕES PARA USAR ESTE SCRIPT NO NOTEBOOKLM

1. **Acesse** https://notebooklm.google.com
2. **Crie um novo notebook**
3. **Cole o conteúdo das seções abaixo** (uma por uma)
4. **Clique em "Generate Audio"** para cada seção
5. **Download dos vídeos** e edite (opcional)
6. **Editar timeline** para adicionar capturas de tela/terminal

---

## 🎬 SEÇÃO 1: INTRODUÇÃO (2 min)

### Narração:

"Bem-vindo à demonstração do ToggleMaster - Fase 3 de DevOps.

Nesta fase, transformamos a infraestrutura manual da Fase 2 em uma arquitetura completamente automatizada, utilizando as melhores práticas de DevOps moderno.

Vamos demonstrar três pilares principais:

**1. Infrastructure as Code (IaC)** - Toda a infraestrutura AWS provisionada via Terraform, incluindo EKS, RDS, ElastiCache, DynamoDB e SQS. Nenhuma clique manual no console.

**2. CI/CD com DevSecOps** - GitHub Actions gerando pipelines que não apenas compilam e testam o código, mas também realizam análises de segurança automatizadas (SAST e SCA) que bloqueiam vulnerabilidades críticas.

**3. GitOps com ArgoCD** - Sincronização automática do cluster Kubernetes através de um repositório Git, garantindo que a realidade sempre corresponda ao estado desejado.

Vamos começar visualizando como toda essa orquestração funciona na prática."

### Capturas de Tela Recomendadas:
- Logo/Slides do ToggleMaster
- Diagrama de arquitetura (Terraform + CI/CD + ArgoCD)
- Mapa da estrutura de repositório

---

## 🎬 SEÇÃO 2: INFRAESTRUTURA COMO CÓDIGO - TERRAFORM (4 min)

### Narração:

"Começamos pela **Infrastructure as Code**, usando Terraform.

A estrutura que criamos é modularizada, seguindo o padrão de **root module** que orquestra cinco submódulos especializados:

**1. Networking** - Criamos uma VPC completa com subnets públicas e privadas, Internet Gateway para tráfego externo e NAT Gateways para tráfego sainte das instâncias privadas.

**2. EKS** - O cluster Kubernetes que executará nossos microsserviços. Como estamos usando AWS Academy, aproveitamos a **LabRole** existente, economizando custos de criação de IAM roles.

**3. Bancos de Dados** - Três instâncias PostgreSQL separadas para auth-service, flag-service e targeting-service. Cada uma em subnets privadas para segurança.

**4. ElastiCache Redis** - Para cache de dados críticos.

**5. DynamoDB** - Tabela analítica com stream habilitado para processamento de eventos.

**6. SQS** - Filas de mensagem padrão, FIFO e Dead Letter Queue (DLQ).

**7. ECR** - Repositórios Docker para cada um dos cinco microsserviços.

E crucialmente, o **S3 Backend remoto** - o terraform.tfstate não fica na máquina local. Usamos um bucket S3 com versionamento e uma tabela DynamoDB para lock, garantindo que múltiplos engenheiros possam trabalhar sem conflitos.

Vamos demonstrar o `terraform plan` para visualizar o que será criado."

### Ações no Terminal:

```bash
# 1. Navegar ao diretório terraform
cd terraform/

# 2. Mostrar estrutura
tree -L 2 -I node_modules

# 3. Inicializar Terraform
terraform init

# 4. Validar configuração
terraform validate

# 5. Formatar código
terraform fmt -recursive

# 6. Gerar plano de execução
terraform plan -out=tfplan

# 7. Mostrar saída do plan
terraform show tfplan | head -100
```

### Capturas de Tela Recomendadas:
- Arquivo `terraform/main.tf` - mostrando a estrutura modular
- Output do `terraform plan` - mostrando os recursos que serão criados
- Diagrama da arquitetura (Networking + EKS + RDS + DynamoDB + SQS)
- Estrutura de diretórios `terraform/modules/`

### Narrração Contínua:

"Como podem ver, o Terraform vai criar **133 recursos** de forma ordenada e idempotent. Se executarmos novamente, apenas diferenças serão aplicadas.

A configuração é completamente versionada em Git. Qualquer mudança precisa de revisão antes de aplicar em produção. Isso é IaC em ação - infraestrutura tratada como código."

---

## 🎬 SEÇÃO 3: PIPELINE CI/CD COM DEVSECOPS - COMPORTAMENTO NORMAL (3 min)

### Narração:

"Agora vamos à parte mais interessante: **CI/CD com DevSecOps**.

Criamos workflows no GitHub Actions para cada tipo de serviço - um para Go (auth, flag, targeting, evaluation) e outro para Python (analytics).

Vou demonstrar o fluxo normal quando o código é **seguro**:

Um desenvolvedor faz um push ou abre um Pull Request com alterações no código. Automaticamente, o GitHub Actions desencadeia uma série de jobs em paralelo:

**1. Build & Unit Tests** - Compila o código
**2. Linting** - Análise estática com golangci-lint (Go) ou pylint (Python)
**3. SAST (Static Application Security Testing)** - Gosec (Go) ou Bandit (Python) analisam se há vulnerabilidades de segurança no código fonte
**4. SCA (Software Composition Analysis)** - Trivy procura por dependências vulneráveis
**5. Docker Build** - Constrói a imagem Docker
**6. Container Scan** - Trivy varre a imagem Docker procurando por vulnerabilidades em layers/binários
**7. Push to ECR** - Se tudo passou, envia para o AWS ECR
**8. Update GitOps** - Atualiza o manifesto no repositório GitOps

Todo esse processo leva entre 5-10 minutos e é **completamente automatizado**."

### Ações para Demonstrar:

```bash
# 1. Mostrar o workflow file
cat .github/workflows/ci-cd-go-services.yml | head -50

# 2. Mostrar a estrutura dos jobs
grep "^  [a-z-]*:" .github/workflows/ci-cd-go-services.yml

# 3. Navegar para GitHub Actions (via navegador)
# https://github.com/seu-usuario/seu-repo/actions

# 4. Mostrar run bem-sucedido (captura de tela)
# - Todos os jobs em verde ✅
# - Duração total
# - Imagem enviada para ECR
```

### Capturas de Tela Recomendadas:
- GitHub Actions workflow rodando
- Todos os jobs em verde (Build ✅, Lint ✅, SAST ✅, SCA ✅, Docker ✅, Push ECR ✅)
- ECR mostrando a imagem enviada
- PR automática criada no repositório GitOps

### Narração Contínua:

"Vamos agora ver a falha de segurança - e isso é crítico. Quando uma vulnerabilidade é detectada, **o pipeline para**."

---

## 🎬 SEÇÃO 4: PIPELINE CI/CD - SIMULANDO VULNERABILIDADE (4 min)

### Narração:

"Agora vamos demonstrar o mais importante: **as proteções de segurança em ação**.

Simulamos uma vulnerabilidade inserindo uma dependência conhecida como vulnerável no código. Isso pode ser:
- Uma versão antiga de uma library
- Código com possível SQL injection
- Credenciais hardcoded
- Dependência com CVE crítico publicado

Vamos demonstrar:"

### Ações para Demonstrar:

```bash
# 1. Criar branch de teste
git checkout -b test/vulnerable-dependency

# 2. Editar arquivo do microsserviço para adicionar dependência vulnerável
# Exemplo para Go: adicionar import conhecido como vulnerável

# 3. Fazer commit
git add auth-service/go.mod
git commit -m "test: add vulnerable dependency to demonstrate security gates"

# 4. Push
git push origin test/vulnerable-dependency

# 5. Criar PR
# GitHub vai sugerir criar PR - aceitar

# 6. Observar GitHub Actions falhando
```

### Capturas de Tela Recomendadas:
- GitHub PR aberta
- GitHub Actions workflow rodando
- **SAST job falhando** (Gosec detecta vulnerabilidade) ❌
- **SCA job falhando** (Trivy detecta dependência vulnerável) ❌
- Log mostrando o erro crítico
- **PR bloqueada** - não pode fazer merge sem corrigir
- ECR **não recebeu** a imagem

### Narração Contínua:

"Como veem, a segurança não é uma verificação manual opcional. É um **fail-gate automático**.

Se há uma vulnerabilidade CRÍTICA:
- ❌ O build falha
- ❌ A imagem não é criada
- ❌ Nada é enviado ao ECR
- ❌ O manifesto GitOps não é atualizado
- ❌ ArgoCD não faz deploy

O desenvolvedor é forçado a corrigir. Isso previne que código vulnerável chegue em produção."

---

## 🎬 SEÇÃO 5: CORRIGINDO A VULNERABILIDADE (2 min)

### Narração:

"Agora o desenvolvedor corrige a vulnerabilidade removendo a dependência insegura e fazendo commit da correção."

### Ações para Demonstrar:

```bash
# 1. Corrigir o código (remover dependência vulnerável)
vim auth-service/go.mod

# 2. Executar testes localmente
cd auth-service
go mod tidy
go test ./...

# 3. Fazer commit
git add auth-service/go.mod
git commit -m "fix: remove vulnerable dependency"

# 4. Push (atualiza a PR)
git push origin test/vulnerable-dependency

# 5. Observar GitHub Actions rodando novamente
```

### Capturas de Tela Recomendadas:
- GitHub Actions rodando novamente
- **Todos os jobs passando** ✅
- Build ✅
- Lint ✅
- SAST ✅
- SCA ✅
- Docker Build ✅
- Push ECR ✅
- PR automática criada em GitOps
- ECR mostrando a nova imagem

### Narração Contínua:

"Excelente! Agora que o código é seguro, todo o pipeline passa:

✅ Build e testes unitários
✅ Linting
✅ SAST (sem vulnerabilidades no código)
✅ SCA (sem vulnerabilidades nas dependências)
✅ Docker build
✅ Container scan
✅ Push para ECR

E importante: uma PR foi criada **automaticamente** no repositório GitOps atualizando a tag da imagem no manifesto Kubernetes.

Isso é o próximo passo: **GitOps com ArgoCD**."

---

## 🎬 SEÇÃO 6: GITOPS - SINCRONIZAÇÃO AUTOMÁTICA (3 min)

### Narração:

"O paradigma GitOps é revolucionário. Não fazemos deploy imperativo ('aplicar isso agora'). Em vez disso, **tudo é declarativo e controlado via Git**.

O repositório GitOps contém os manifestos Kubernetes para todos os cinco microsserviços. Cada um tem:
- Deployment
- Service
- ServiceAccount
- Secrets
- Health checks (liveness/readiness probes)
- Resource limits
- Anti-affinity rules

O ArgoCD fica monitorando este repositório. Quando detecta uma mudança:

1️⃣ Compara o estado desejado (Git) com o estado atual (cluster)
2️⃣ Detecta o drift
3️⃣ Aplica as mudanças automaticamente
4️⃣ Realiza rolling update (zero downtime)
5️⃣ Valida health checks dos pods
6️⃣ Pronto! Nova versão em produção

Vamos demonstrar ArgoCD detectando a mudança e sincronizando:"

### Ações para Demonstrar:

```bash
# 1. Acessar ArgoCD UI (via kubectl port-forward)
kubectl port-forward -n argocd svc/argocd-server 8080:443 &

# 2. Abrir https://localhost:8080 (aceitar certificado auto-assinado)
# Username: admin
# Password: (obtido via: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# 3. Mostrar Applications
# - togglemaster-auth-service
# - togglemaster-flag-service
# - togglemaster-targeting-service
# - togglemaster-evaluation-service
# - togglemaster-analytics-service

# 4. Clicar em togglemaster-auth-service

# 5. Mostrar o estado "OutOfSync" ou "Syncing"

# 6. Clicar em "Sync" para sincroniza manualmente (ou esperar auto-sync)

# 7. Observar o sincronismo acontecendo em tempo real
```

### Capturas de Tela Recomendadas:
- ArgoCD UI mostrando as 5 aplicações
- Dashboard principal com status de sincronização
- Modal de uma aplicação mostrando:
  - Deployment
  - Service
  - StatefulSet (se houver)
  - Todos os recursos sincronizados
- Terminal mostrando `kubectl get pods -n togglemaster`
- Pods da nova versão sendo criados
- Pods antigos sendo removidos (rolling update)

### Narração Contínua:

"Vamos verificar os pods sendo criados no cluster em tempo real:"

```bash
# 1. Monitorar pods em tempo real
kubectl get pods -n togglemaster -w

# 2. Mostrar imagem atualizada
kubectl get pods auth-service-xyz -n togglemaster -o jsonpath='{.spec.containers[0].image}'

# 3. Verificar health
kubectl describe pod auth-service-xyz -n togglemaster | grep -A5 "Events"
```

### Narração Final:

"E está feito! O novo serviço está em produção sem qualquer intervenção manual.

O desenvolvedor não executou `kubectl apply`. O operador não fez login no console AWS. ArgoCD fez tudo automaticamente porque:

**Git is the source of truth** - O repositório Git contém exatamente o que deve estar em produção.
**Deterministic Deployment** - O mesmo cluster, mesmas versões, sempre.
**Auditoria Automática** - Cada deployer, hora e versão fica registrada no Git.
**Rollback Simples** - Se algo der errado, voltar é tão fácil quanto fazer revert no Git."

---

## 🎬 SEÇÃO 7: DEMONSTRANDO RECURSOS AWS VIA TERRAFORM (2 min)

### Narração:

"Antes de finalizar, vamos ver os recursos criados no AWS."

### Ações para Demonstrar:

```bash
# 1. Listar outputs do Terraform
cd terraform/
terraform output

# 2. Mostrar no console AWS (via navegador)
# - VPC identado no EC2 Dashboard
# - EKS Cluster em EKS Dashboard
# - RDS Instances
# - ElastiCache Cluster
# - DynamoDB Tables
# - SQS Queues
# - ECR Repositories

# 3. Verificar o state no S3
aws s3 ls s3://togglemaster-terraform-state-ACCOUNT_ID/

# 4. Montar o terraform state remotamente
terraform state list | head -20
```

### Capturas de Tela Recomendadas:
- AWS Console - EKS Dashboard
- AWS Console - RDS Instances (3 PostgreSQL)
- AWS Console - ElastiCache - Redis
- AWS Console - DynamoDB - Tables
- AWS Console - SQS - Queues
- AWS Console - ECR - Repositories (5)
- S3 Backend - mostrando terraform.tfstate

### Narração Contínua:

"Toda essa infraestrutura foi criada com **menos de um comando**:
```bash
terraform apply
```

Nenhum clique manual, nenhum erro, nenhuma inconsistência. E se precisarmos destruir tudo:
```bash
terraform destroy
```

Tudo desaparece. Idempotent, repetível, auditável."

---

## 🎬 SEÇÃO 8: CONCLUSÃO (1 min)

### Narração:

"Em resumo, o ToggleMaster Phase 3 implementa as três práticas críticas do DevOps moderno:

🏭 **Infrastructure as Code** - Terraform provisionando toda infraestrutura de forma modular, versionada e reprodutível.

🔒 **DevSecOps** - GitHub Actions com SAST e SCA que bloqueiam vulnerabilidades críticas automaticamente.

🚀 **GitOps** - ArgoCD sincronizando o cluster a partir de um repositório Git, garantindo consistência e rastreabilidade.

O resultado: **velocidade de entrega, confiabilidade de produção, e segurança como padrão, não como exceção**.

Essa é a base para escalar operações DevOps modernas em qualquer organização.

Obrigado!"

### Capturas de Tela Finais:
- ArgoCD Dashboard mostrando os 5 serviços em sync
- GitHub Actions com execução bem-sucedida
- Kubernetes Dashboard mostrando pods saudáveis
- Terraform state versionado no S3

---

## 📋 CHECKLIST PARA GRAVAÇÃO

Antes de colar no NotebookLM, confirme:

- [ ] Todos os serviços rodando no EKS (`kubectl get pods -n togglemaster`)
- [ ] GitHub Actions workflows configurados e testados
- [ ] ArgoCD instalado e sincronizando
- [ ] Terraform state no S3 backend
- [ ] Preparar screenshot/terminal captures para cada seção
- [ ] Preparar exemplo de vulnerabilidade para demonstração
- [ ] AWS Academy/Personal Account com créditos disponíveis
- [ ] Duração total planejada (≤ 20 min)

---

## 🎥 INSTRUÇÕES FINAIS PARA NOTEBOOKLM

1. Acesse: https://notebooklm.google.com
2. **Create a new notebook**
3. Copie e cole **cada seção** (uma por uma)
4. Clique em **"Generate Audio"**
5. Aguarde o áudio ser gerado
6. **Download** cada arquivo de áudio
7. Compile em um editor de vídeo (Adobe Premiere, Final Cut Pro, etc)
8. **Adicione capturas de tela/terminal** sincronizadas com o áudio
9. **Exporte em qualidade 1080p/4K**
10. Upload no repositório GitHub ou YouTube

---

**Total Estimado:**
- 📝 Tempo de gravação: ~25-30 min (incluindo retakes)
- 🎬 Tempo de edição: ~1-2 horas
- 📤 Upload e processamento: ~10-15 min

**Tamanho recomendado:** 300-500 MB para 1080p

---

**Sucesso! 🚀**
