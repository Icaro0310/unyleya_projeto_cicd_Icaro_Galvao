# PROJETO COMPLETO - CI/CD AZURE VOTING APP

**Aluno:** Icaro Galvao do Nascimento  
**Curso:** Unylea - Engenheiro DevOps  
**Projeto:** Pipeline CI/CD com GitHub Actions, Kubernetes e New Relic  
**Status:** Migração para VM Google Cloud em andamento

---

## ÍNDICE

1. [Visão Geral do Projeto](#visão-geral-do-projeto)
2. [Parte 1 - CI/CD com GitHub Actions](#parte-1---cicd-com-github-actions)
3. [Parte 2 - Kubernetes e Monitoramento](#parte-2---kubernetes-e-monitoramento)
4. [Migração para VM Google Cloud](#migração-para-vm-google-cloud)
5. [Estrutura do Repositório](#estrutura-do-repositório)
6. [Ambientes](#ambientes)
7. [Instruções de Uso](#instruções-de-uso)
8. [Status Atual](#status-atual)
9. [Próximos Passos](#próximos-passos)

---

## VISÃO GERAL DO PROJETO

Este projeto implementa uma esteira (pipeline) automatizada de CI/CD completa para a aplicação **Azure Voting App Redis**, que consiste em:

- **Frontend:** Aplicação Python Flask (sistema de votação web)
- **Backend:** Redis para armazenamento dos votos
- **Infraestrutura:** Kubernetes com Helm Charts
- **Monitoramento:** New Relic
- **CI/CD:** GitHub Actions com aprovação manual

### Tecnologias Utilizadas

- **Linguagem:** Python 3.9
- **Containerização:** Docker
- **Orquestração:** Kubernetes (kind local + k3s VM)
- **Gerenciamento de Pacotes:** Helm
- **CI/CD:** GitHub Actions
- **IaC:** Terraform (Kubernetes provider)
- **Monitoramento:** New Relic
- **Registry:** GitHub Container Registry (ghcr.io)

---

## PARTE 1 - CI/CD COM GITHUB ACTIONS

### Etapa 1: Fork do Repositório

Fiz o fork do repositório original `osanam-giordane/azure-voting-app-redis` para minha conta GitHub, criando `Icaro0310/azure-voting-app-redis`.

### Etapa 2: Clone para PC

Clonei o repositório forkado para minha máquina local.

### Etapa 3: Criação do Novo Repositório

Criei um novo repositório no GitHub chamado `unyleya_projeto_cicd_Icaro_Galvao`.

### Etapa 4: Commit e Push do Código

Alterei o remote origin para o novo repositório e fiz o push de todo o código.

### Etapa 5: Pipeline CI/CD (ci-cd.yml)

Criei o pipeline CI/CD com 5 jobs:

1. **Lint & Code Quality** - flake8
2. **Build Docker Image** - docker build
3. **Testes Integrados** - docker compose + curl + redis-cli
4. **Security Scan** - Trivy
5. **Deploy** - Resumo do deploy

**Resultado:** 5/5 jobs aprovados em 3m26s.

### Pipeline CI Atualizada (ci-build.yml)

Pipeline de CI atualizada para build e push da imagem para o registry:

1. **Lint & Code Quality** - flake8
2. **Build Docker Image** - build + push para GitHub Container Registry (ghcr.io)
3. **Security Scan** - Trivy
4. **Validar Helm Chart** - helm lint + helm template
5. **Validar Terraform** - terraform init + validate + fmt

---

## PARTE 2 - KUBERNETES E MONITORAMENTO

### Etapa 6: Criação da Infraestrutura Kubernetes (substituto do AKS)

Criei um cluster Kubernetes local usando **kind (Kubernetes in Docker)** como alternativa gratuita ao AKS (Azure Kubernetes Service).

**Cluster:** `unyleya-k8s` (1 node control-plane, Kubernetes v1.30.0)

### Etapa 7: Registry Local (substituto do ACR)

Configurei um registry Docker local como alternativa gratuita ao ACR (Azure Container Registry) para armazenar as imagens da aplicação.

### Etapa 8: Terraform - Provisionamento K8s

Criei a infraestrutura como código com Terraform (Kubernetes provider) provisionando:

- Namespace `azure-vote`
- ConfigMap com configurações da aplicação
- Deployment do frontend (2 replicas, Flask)
- Deployment do backend (1 replica, Redis)
- Service NodePort (porta 30080) para frontend
- Service ClusterIP para backend
- Liveness e readiness probes
- Resource limits (CPU e memória)

**Arquivo:** `iac/terraform-k8s/main.tf`

### Etapa 9: Helm Chart da Aplicação

Criei um Helm Chart para a aplicação azure-vote com:

- `Chart.yaml` - metadados do chart
- `values.yaml` - configurações parametrizáveis
- `templates/namespace.yaml` - namespace
- `templates/configmap.yaml` - configurações
- `templates/deployment-frontend.yaml` - deployment Flask
- `templates/deployment-backend.yaml` - deployment Redis
- `templates/service.yaml` - services NodePort e ClusterIP
- `templates/NOTES.txt` - instruções pós-deploy

**Diretório:** `iac/helm/azure-vote/`

### Etapa 10: Pipeline CD com Aprovação por Email (cd-deploy.yml)

Criei a pipeline de CD com:

- **Job de Aprovação** - usa GitHub Environment `production` com required reviewers (notificação por email)
- **Job de Deploy** - deploy via Helm no Kubernetes
  - Login no registry
  - Configuração do kubeconfig
  - `helm upgrade --install` com a imagem do registry
  - Verificação do deployment
  - Teste de acesso à aplicação

### Etapa 11: Implantação no Kubernetes

Fiz o deploy da aplicação no cluster Kubernetes local via Helm:

```bash
helm install azure-vote iac/helm/azure-vote \
  --set frontend.image.repository=azure-vote-front \
  --set frontend.image.tag=latest \
  --set frontend.image.pullPolicy=Never
```

**Resultado:**
- 3 pods rodando (2 frontend + 1 backend)
- Service NodePort exposto na porta 30080
- Aplicação acessível em http://localhost:30080
- HTTP 200 - página de votação com Cats x Dogs

### Etapa 12: Monitoramento com New Relic

Instalei o New Relic no cluster Kubernetes via Helm para monitoramento de:

- Infraestrutura (nodes, pods, containers)
- Kubernetes (control plane, kubelet, KSM)
- Métricas Prometheus
- Logs da aplicação
- Aplicação implantada

```bash
helm install newrelic newrelic/nri-bundle \
  --set global.licenseKey=<INGEST-LICENSE-KEY> \
  --set global.cluster=unyleya-k8s \
  --namespace newrelic --create-namespace
```

**Resultado:** 5 pods do New Relic rodando e enviando dados para a plataforma.

### Etapa 13: Teste de Acesso à Aplicação

Testei o acesso à aplicação provisionada no Kubernetes:

```bash
curl http://localhost:30080
# HTTP Status: 200
# Página com botões Cats e Dogs funcionando
```

### Etapa 14: Permissão para o Professor

Adicionei o professor `osanam-giordane` como colaborador com permissão de **ADMIN** no repositório GitHub.

---

## MIGRAÇÃO PARA VM GOOGLE CLOUD

### Motivação

Como a subscription Azure estava desativada e sem créditos, utilizei alternativas gratuitas que demonstram os mesmos conceitos:

- **AKS → kind** (Kubernetes in Docker) - cluster K8s real
- **ACR → GitHub Container Registry** (ghcr.io) + registry local
- **New Relic → Free trial** (100GB grátis/mês) - instalado e ativo

### Problema

O cluster kind roda localmente no PC, tornando a aplicação inacessível para o professor (só funciona na máquina local).

### Solução

Migração para VM Google Cloud (unyleya-k8s, IP: 35.228.210.46) para acesso público.

### Infraestrutura da VM

- **Nome:** unyleya-k8s
- **Zona:** europe-north1-c
- **IP Externo:** 35.228.210.46
- **IP Interno:** 10.166.0.2
- **Status:** RUNNING
- **SO:** Ubuntu 22.04

### Componentes Instalados na VM

- **Kubernetes:** k3s v1.36.3 (cluster leve)
- **Helm:** v3.21.3
- **Firewall:** Portas 30080, 6443, 10250 configuradas
- **Namespace:** azure-vote criado

### Scripts de Automação Criados

1. **setup-vm-k8s.sh** - Setup inicial Kubernetes + Helm
2. **setup-completo.sh** - Setup completo em um script
3. **continuar-setup.sh** - Continuar setup após k3s instalado
4. **deploy-app.sh** - Deploy da aplicação
5. **setup-newrelic.sh** - Configuração New Relic
6. **emergencia-deploy.sh** - Script de emergência
7. **emergencia-total.sh** - Limpeza completa e reinstalação
8. **setup-cron-job.sh** - Configuração CRON automático
9. **deploy-unico-comando.sh** - Deploy com um único comando

### Configurações Kubernetes Adaptables

- **values-prod.yaml** - Configurações específicas para VM
- **values.yaml** - Atualizado para usar ghcr.io
- **cd-deploy-vm.yml** - Pipeline CD para VM Google Cloud

### Documentação Criada

- **MIGRACAO_VM.md** - Instruções detalhadas passo a passo
- **README_MIGRACAO_COMPLETA.md** - Status completo da migração
- **PROXIMOS_PASSOS.md** - Próximos passos para conclusão
- **INSTRUCAO_CONSOLE_CLOUD.md** - Instruções via navegador
- **scripts/README.md** - Documentação dos scripts

---

## ESTRUTURA DO REPOSITÓRIO

```
unyleya_projeto_cicd_Icaro_Galvao/
├── .github/
│   └── workflows/
│       ├── ci-cd.yml              # Pipeline CI/CD Parte 1
│       ├── ci-build.yml           # Pipeline CI Parte 2 (build + push)
│       ├── cd-deploy.yml          # Pipeline CD Parte 2 (deploy Helm)
│       └── cd-deploy-vm.yml       # Pipeline CD para VM Google Cloud
├── iac/
│   ├── terraform-k8s/
│   │   ├── main.tf                # Terraform - recursos Kubernetes
│   │   └── variables.tf           # Variáveis Terraform
│   └── helm/
│       └── azure-vote/
│           ├── Chart.yaml         # Metadados do Helm Chart
│           ├── values.yaml        # Valores parametrizáveis
│           ├── values-prod.yaml    # Valores para produção VM
│           └── templates/
│               ├── namespace.yaml
│               ├── configmap.yaml
│               ├── deployment-frontend.yaml
│               ├── deployment-backend.yaml
│               ├── service.yaml
│               └── NOTES.txt
├── azure-vote/
│   ├── azure-vote/
│   │   ├── main.py                # Aplicação Flask (votação)
│   │   ├── config_file.cfg
│   │   ├── static/default.css
│   │   └── templates/index.html
│   ├── Dockerfile                 # Dockerfile do frontend
│   └── ...
├── scripts/
│   ├── setup-vm-k8s.sh           # Setup Kubernetes na VM
│   ├── setup-completo.sh         # Setup completo
│   ├── continuar-setup.sh        # Continuar setup
│   ├── deploy-app.sh             # Deploy aplicação
│   ├── setup-newrelic.sh         # Setup New Relic
│   ├── emergencia-deploy.sh      # Emergência
│   ├── emergencia-total.sh       # Emergência total
│   ├── setup-cron-job.sh         # Setup CRON automático
│   ├── deploy-unico-comando.sh  # Deploy único comando
│   ├── INSTRUCAO_CONSOLE_CLOUD.md # Instruções navegador
│   └── README.md                 # Documentação scripts
├── docker-compose.yaml
├── README.md                     # README original Microsoft
├── README_PROJETO.md             # Documentação do projeto
├── README_PROJETO_COMPLETO.md     # Este documento
├── README_MIGRACAO_COMPLETA.md    # Documentação migração
├── MIGRACAO_VM.md                # Instruções migração
└── PROXIMOS_PASSOS.md            # Próximos passos
```

---

## AMBIENTES

### Ambiente de Desenvolvimento (Local)

- **Cluster:** kind (Kubernetes in Docker)
- **Acesso:** http://localhost:30080
- **Registry:** localhost:5000
- **Monitoramento:** New Relic instalado
- **Status:** ✅ Funcionando

### Ambiente de Produção (VM Google Cloud)

- **Cluster:** k3s (Kubernetes nativo)
- **VM:** unyleya-k8s (IP: 35.228.210.46)
- **Acesso:** http://35.228.210.46:30080
- **Registry:** ghcr.io
- **Monitoramento:** New Relic (a configurar)
- **Status:** 🔄 Em andamento

---

## INSTRUÇÕES DE USO

### Ambiente Local (Kind)

1. **Iniciar cluster kind:**
```bash
kind create cluster --name unyleya-k8s
```

2. **Deploy via Helm:**
```bash
helm install azure-vote iac/helm/azure-vote \
  --set frontend.image.repository=localhost:5000/azure-vote-front \
  --set frontend.image.tag=latest
```

3. **Acessar aplicação:**
```bash
http://localhost:30080
```

### Ambiente de Produção (VM Google Cloud)

1. **Acessar VM via Console SSH:**
   - Acesse: https://console.cloud.google.com/compute/instances
   - Clique no botão "SSH" ao lado da VM unyleya-k8s

2. **Executar setup automático:**
```bash
cd ~/unyleya_projeto_cicd_Icaro_Galvao
git pull
chmod +x scripts/deploy-unico-comando.sh
./scripts/deploy-unico-comando.sh
```

3. **Monitorar progresso:**
```bash
tail -f /tmp/deploy.log
```

4. **Acessar aplicação:**
```bash
http://35.228.210.46:30080
```

---

## STATUS ATUAL

### ✅ CONCLUÍDO

**Parte 1 - CI/CD:**
- [x] Fork do repositório original
- [x] Criação do novo repositório
- [x] Pipeline CI/CD com 5 jobs
- [x] Pipeline CI atualizada para ghcr.io
- [x] Security scan com Trivy
- [x] Validação Helm Chart
- [x] Validação Terraform

**Parte 2 - Kubernetes Local:**
- [x] Cluster kind criado e configurado
- [x] Registry local configurado
- [x] Terraform provisionamento K8s
- [x] Helm Chart completo
- [x] Pipeline CD com aprovação
- [x] Deploy da aplicação (localhost:30080)
- [x] Monitoramento New Relic instalado
- [x] Teste de acesso (HTTP 200)
- [x] Permissão para o professor

**Migração VM Google Cloud:**
- [x] Scripts de automação criados
- [x] Helm Chart adaptado para produção
- [x] Pipeline CD para VM criado
- [x] Documentação completa
- [x] Chaves SSH configuradas
- [x] k3s instalado na VM
- [x] Helm instalado na VM
- [x] Firewall configurado
- [x] Namespace criado
- [x] Todo o código no GitHub

### ✅ SOLUÇÃO FINAL - LOCALHOST PARA INTERNET

**Acesso Público do Professor:** https://great-planes-jump.loca.lt

**Solução Implementada:**
- ✅ Aplicação rodando no kind cluster local (localhost:30080)
- ✅ Exposta para internet via localtunnel
- ✅ URL pública gerada automaticamente
- ✅ Acessível de qualquer lugar
- ✅ Sem necessidade de VM Google Cloud

**Como Funciona:**
1. Aplicação Azure Voting App rodando no kind cluster
2. Port-forward para localhost:30080
3. localtunnel expõe localhost para internet
4. Professor acessa via URL pública

**Comandos para Reproduzir:**
```bash
# 1. Instalar localtunnel
npm install -g localtunnel

# 2. Port-forward do Kubernetes
kubectl port-forward -n azure-vote svc/azure-vote-front 30080:80

# 3. Expor para internet
lt --port 30080
```

**Migração VM Google Cloud:** ❌ **CANCELADA**
- VM apresentou múltiplos problemas (k3s, Docker, apt-get)
- Solução localtunnel é mais rápida e confiável
- Mesmo resultado: aplicação acessível publicamente

---

## PRÓXIMOS PASSOS

### 1. Concluir Deploy na VM

**Status:** CRON job configurado e executando automaticamente.

O deploy está sendo tentado automaticamente a cada 5 minutos via CRON job. Para monitorar o progresso:

```bash
# Na VM via Console SSH
tail -f /tmp/deploy.log
```

Ou execute manualmente se preferir:

```bash
cd ~/unyleya_projeto_cicd_Icaro_Galvao
git pull
chmod +x scripts/emergencia-total.sh
./scripts/emergencia-total.sh
```

### 2. Configurar GitHub Actions

1. **Exportar kubeconfig da VM:**
```bash
cat ~/.kube/config | base64 -w 0
```

2. **Adicionar secret no GitHub:**
   - GitHub → Settings → Secrets → Actions
   - Nome: `KUBECONFIG_VM`
   - Valor: cole o base64 acima

### 3. Testar Acesso Público

```bash
curl http://35.228.210.46:30080
```

Acessar no navegador: http://35.228.210.46:30080

### 4. Configurar New Relic (Opcional)

```bash
cd ~/unyleya_projeto_cicd_Icaro_Galvao
./scripts/setup-newrelic.sh
```

---

## VALIDAÇÃO PARA O PROFESSOR

Após conclusão da migração, o professor poderá acessar:

### ✅ ACESSÍVEL PUBLICAMENTE

- **Aplicação:** http://35.228.210.46:30080
- **Código + IaC:** https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao
- **Pipelines CI/CD:** https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao/actions
- **Helm Chart:** Disponível no repositório
- **Logs:** GitHub Actions + kubectl na VM

### 📊 MONITORAMENTO (SE CONFIGURADO)

- **New Relic:** https://one.newrelic.com
- **Infraestrutura K8s:** Monitoramento completo
- **Métricas:** Pods, containers, nodes
- **Logs:** Logs da aplicação

---

## CONCEITOS DEMONSTRADOS

### CI/CD
- ✅ Pipeline automatizado com GitHub Actions
- ✅ Lint e qualidade de código
- ✅ Build e push de imagens Docker
- ✅ Testes integrados
- ✅ Security scan
- ✅ Aprovação manual para produção
- ✅ Deploy automatizado

### Kubernetes
- ✅ Cluster Kubernetes (kind + k3s)
- ✅ Deployments e Services
- ✅ ConfigMaps
- ✅ Liveness e readiness probes
- ✅ Resource limits
- ✅ Helm Charts

### Infraestrutura como Código
- ✅ Terraform (Kubernetes provider)
- ✅ Helm Charts parametrizáveis
- ✅ Configurações versionadas

### Monitoramento
- ✅ New Relic integration
- ✅ Monitoramento de infraestrutura
- ✅ Métricas e logs

---

## CONCLUSÃO

Este projeto demonstra de forma completa os conceitos de CI/CD, Kubernetes, Helm, Terraform e monitoramento, utilizando tecnologias modernas e práticas de DevOps.

### Status Final

**Parte 1 - CI/CD:** ✅ 100% CONCLUÍDO
- Pipeline CI/CD funcional
- Build e push para ghcr.io
- Security scan
- Validação Helm e Terraform

**Parte 2 - Kubernetes Local:** ✅ 100% CONCLUÍDO
- Cluster kind funcionando
- Aplicação rodando em localhost:30080
- Monitoramento New Relic ativo

**Acesso Público:** ✅ 100% CONCLUÍDO
- Aplicação exposta via localtunnel
- URL pública: https://great-planes-jump.loca.lt
- Professor pode acessar de qualquer lugar

**Migração VM Google Cloud:** ❌ CANCELADA
- VM apresentou múltiplos problemas técnicos
- Solução localtunnel substituiu necessidade da VM
- Mesmo resultado alcançado com melhor simplicidade

### Acesso para o Professor

**URL Pública:** https://great-planes-jump.loca.lt

O professor pode acessar a aplicação Azure Voting App através desta URL pública, que está expondo o cluster kind local para internet.

Todos os conceitos pedidos foram implementados e documentados. O projeto está ready for review com a aplicação funcionando e acessível publicamente!