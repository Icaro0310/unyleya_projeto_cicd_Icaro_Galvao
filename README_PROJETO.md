# Unyleya Projeto CI/CD - Azure Voting App

**Aluno:** Icaro Galvao do Nascimento  
**Curso:** Unylea - Engenheiro DevOps  
**Projeto:** Pipeline CI/CD com GitHub Actions, Kubernetes e New Relic  

---

## STATUS ATUAL

### Ambiente de Produção (VM Google Cloud)
- ✅ **VM Google Cloud:** unyleya-k8s (IP: 35.228.210.46)
- ✅ **Kubernetes:** k3s v1.36.3 instalado e rodando
- ✅ **Helm:** v3.21.3 instalado
- ✅ **Firewall:** Portas 30080, 6443, 10250 configuradas
- 🔄 **Deploy:** Em andamento - Helm Chart configurado
- 📝 **Instruções:** Veja `MIGRACAO_VM.md` e `README_MIGRACAO_COMPLETA.md`

### Ambiente de Desenvolvimento (Local)
- ✅ **Cluster:** kind (Kubernetes in Docker)
- ✅ **Acesso Local:** http://localhost:30080
- ✅ **Monitoramento:** New Relic instalado

---

## Sobre o Projeto

Implementei uma esteira (pipeline) automatizada de CI/CD completa para a aplicacao **Azure Voting App Redis**, incluindo:

- **Parte 1 (Unidade 3):** Pipeline CI/CD com GitHub Actions - lint, build, test, security scan
- **Parte 2 (Unidade 4):** Infraestrutura Kubernetes com Terraform, deploy via Helm Chart, e monitoramento com New Relic
- **Migração para Nuvem:** Deploy em VM Google Cloud para acesso público do professor

A aplicacao consiste em um frontend Python Flask (sistema de votacao web) e um backend Redis para armazenamento dos votos, containerizados com Docker.

---

## Topologia Completa

```
                    PARTE 1 - CI/CD (GitHub Actions)
                    ================================

[Push/Pull Request no GitHub]
         |
         v
    +-----------+
    |   LINT    |  -> flake8 (qualidade de codigo)
    +-----------+
         |
         v
    +-----------+
    |   BUILD   |  -> Build da imagem Docker + Push para Registry
    +-----------+
         |
    +----+----+
    |         |
    v         v
+-------+ +----------+
| TEST  | | SECURITY |  -> Testes integrados + Scan Trivy
+-------+ +----------+


                    PARTE 2 - KUBERNETES + MONITORAMENTO
                    =====================================

    +------------------+
    |   TERRAFORM      |  -> Provisiona Namespace, Deployments, Services
    |   (K8s Provider) |
    +------------------+
         |
         v
    +-----------+        Aprovacao por Email
    |  CD PIPE  | -----> (Environment: production)
    |  (Helm)   |
    +-----------+
         |
         v
    +------------------+     +------------------+
    |   KUBERNETES     | <-- |    NEW RELIC     |
    |   (kind cluster) |     |    (Monitoramento)|
    |                  |     |    - Infra       |
    |  azure-vote      |     |    - K8s         |
    |  namespace       |     |    - Pods        |
    +------------------+     +------------------+
         |
         v
    +-----------+
    |  APLICACAO|  -> http://localhost:30080
    |  (NodePort)|
    +-----------+
```

---

## Etapas Realizadas

### PARTE 1 - CI/CD (Unidade 3)

#### Etapa 1: Fork do Repositorio
Fiz o fork do repositorio original `osanam-giordane/azure-voting-app-redis` para minha conta GitHub, criando `Icaro0310/azure-voting-app-redis`.

#### Etapa 2: Clone para PC
Clonei o repositorio forkado para minha maquina local.

#### Etapa 3: Criacao do Novo Repositorio
Criei um novo repositorio no GitHub chamado `unyleya_projeto_cicd_Icaro_Galvao`.

#### Etapa 4: Commit e Push do Codigo
Alterei o remote origin para o novo repositorio e fiz o push de todo o codigo.

#### Etapa 5: Pipeline CI/CD (ci-cd.yml)
Criei o pipeline CI/CD com 5 jobs:
1. **Lint & Code Quality** - flake8
2. **Build Docker Image** - docker build
3. **Testes Integrados** - docker compose + curl + redis-cli
4. **Security Scan** - Trivy
5. **Deploy** - Resumo do deploy

Resultado: 5/5 jobs aprovados em 3m26s.

### PARTE 2 - KUBERNETES + NEW RELIC (Unidade 4)

#### Etapa 6: Criacao da Infraestrutura Kubernetes (substituto do AKS)
Criei um cluster Kubernetes local usando **kind (Kubernetes in Docker)** como alternativa gratuita ao AKS (Azure Kubernetes Service).

Cluster: `unyleya-k8s` (1 node control-plane, Kubernetes v1.30.0)

#### Etapa 7: Registry Local (substituto do ACR)
Configurei um registry Docker local como alternativa gratuita ao ACR (Azure Container Registry) para armazenar as imagens da aplicacao.

#### Etapa 8: Terraform - Provisionamento K8s
Criei a infraestrutura como codigo com Terraform (Kubernetes provider) provisionando:
- Namespace `azure-vote`
- ConfigMap com configuracoes da aplicacao
- Deployment do frontend (2 replicas, Flask)
- Deployment do backend (1 replica, Redis)
- Service NodePort (porta 30080) para frontend
- Service ClusterIP para backend
- Liveness e readiness probes
- Resource limits (CPU e memoria)

Arquivo: `iac/terraform-k8s/main.tf`

#### Etapa 9: Helm Chart da Aplicacao
Criei um Helm Chart para a aplicacao azure-vote com:
- `Chart.yaml` - metadados do chart
- `values.yaml` - configuracoes parametrizaveis
- `templates/namespace.yaml` - namespace
- `templates/configmap.yaml` - configuracoes
- `templates/deployment-frontend.yaml` - deployment Flask
- `templates/deployment-backend.yaml` - deployment Redis
- `templates/service.yaml` - services NodePort e ClusterIP
- `templates/NOTES.txt` - instrucoes pos-deploy

Diretorio: `iac/helm/azure-vote/`

#### Etapa 10: Pipeline CI Atualizada (ci-build.yml)
Criei a pipeline de CI atualizada para build e push da imagem para o registry:
1. **Lint & Code Quality** - flake8
2. **Build Docker Image** - build + push para GitHub Container Registry (ghcr.io)
3. **Security Scan** - Trivy
4. **Validar Helm Chart** - helm lint + helm template
5. **Validar Terraform** - terraform init + validate + fmt

#### Etapa 11: Pipeline CD com Aprovacao por Email (cd-deploy.yml)
Criei a pipeline de CD com:
- **Job de Aprovacao** - usa GitHub Environment `production` com required reviewers (notificacao por email)
- **Job de Deploy** - deploy via Helm no Kubernetes
  - Login no registry
  - Configuracao do kubeconfig
  - `helm upgrade --install` com a imagem do registry
  - Verificacao do deployment
  - Teste de acesso a aplicacao

#### Etapa 12: Implantacao no Kubernetes
Fiz o deploy da aplicacao no cluster Kubernetes local via Helm:

```bash
helm install azure-vote iac/helm/azure-vote \
  --set frontend.image.repository=azure-vote-front \
  --set frontend.image.tag=latest \
  --set frontend.image.pullPolicy=Never
```

Resultado:
- 3 pods rodando (2 frontend + 1 backend)
- Service NodePort exposto na porta 30080
- Aplicacao acessivel em http://localhost:30080
- HTTP 200 - pagina de votacao com Cats x Dogs

#### Etapa 13: Monitoramento com New Relic
Instalei o New Relic no cluster Kubernetes via Helm para monitoramento de:
- Infraestrutura (nodes, pods, containers)
- Kubernetes (control plane, kubelet, KSM)
- Metricas Prometheus
- Logs da aplicacao
- Aplicacao implantada

```bash
helm install newrelic newrelic/nri-bundle \
  --set global.licenseKey=<INGEST-LICENSE-KEY> \
  --set global.cluster=unyleya-k8s \
  --namespace newrelic --create-namespace
```

Resultado: 5 pods do New Relic rodando e enviando dados para a plataforma.

#### Etapa 14: Teste de Acesso a Aplicacao
Testei o acesso a aplicacao provisionada no Kubernetes:

```bash
curl http://localhost:30080
# HTTP Status: 200
# Pagina com botoes Cats e Dogs funcionando
```

#### Etapa 15: Permissao para o Professor
Adicionei o professor `osanam-giordane` como colaborador com permissao de **ADMIN** no repositorio GitHub.

---

## Status da Migração para VM Google Cloud

Para informações detalhadas sobre a migração do kind local para a VM Google Cloud, consulte:
- **[README_MIGRACAO_COMPLETA.md](README_MIGRACAO_COMPLETA.md)** - Documentação completa da migração
- **[MIGRACAO_VM.md](MIGRACAO_VM.md)** - Instruções passo a passo
- **[PROXIMOS_PASSOS.md](PROXIMOS_PASSOS.md)** - Próximos passos para conclusão

---

## Estrutura do Repositorio

```
unyleya_projeto_cicd_Icaro_Galvao/
├── .github/
│   └── workflows/
│       ├── ci-cd.yml              # Pipeline CI/CD Parte 1
│       ├── ci-build.yml           # Pipeline CI Parte 2 (build + push registry)
│       └── cd-deploy.yml          # Pipeline CD Parte 2 (deploy Helm + aprovacao)
├── iac/
│   ├── terraform-k8s/
│   │   ├── main.tf                # Terraform - recursos Kubernetes
│   │   └── variables.tf           # Variaveis Terraform
│   └── helm/
│       └── azure-vote/
│           ├── Chart.yaml         # Metadados do Helm Chart
│           ├── values.yaml        # Valores parametrizaveis
│           └── templates/
│               ├── namespace.yaml
│               ├── configmap.yaml
│               ├── deployment-frontend.yaml
│               ├── deployment-backend.yaml
│               ├── service.yaml
│               └── NOTES.txt
├── azure-vote/
│   ├── azure-vote/
│   │   ├── main.py                # Aplicacao Flask (votacao)
│   │   ├── config_file.cfg
│   │   ├── static/default.css
│   │   └── templates/index.html
│   ├── Dockerfile                 # Dockerfile do frontend
│   └── ...
├── docker-compose.yaml
├── README_PROJETO.md              # Esta documentacao
└── README.md
```

---

## Tecnologia Utilizada

| Tecnologia | Funcao |
|------------|--------|
| **GitHub Actions** | CI/CD - pipelines automatizados |
| **Kubernetes (kind)** | Orquestracao de containers (substituto do AKS) |
| **Terraform** | Infraestrutura como codigo (K8s provider) |
| **Helm** | Gerenciamento de pacotes K8s (Chart da aplicacao) |
| **Docker** | Containerizacao |
| **Docker Compose** | Orquestracao local (testes) |
| **Python Flask** | Aplicacao web (votacao) |
| **Redis** | Backend - armazenamento dos votos |
| **New Relic** | Monitoramento e telemetria |
| **Trivy** | Scanner de vulnerabilidades |
| **flake8** | Analise estatica de codigo |
| **GitHub Container Registry** | Registry de imagens (substituto do ACR) |
| **Git/GitHub** | Controle de versao e hospedagem |

---

## Pipelines GitHub Actions

### Pipeline CI (ci-build.yml)
| Job | Descricao | Duracao |
|-----|-----------|---------|
| Lint | Analise estatica flake8 | ~18s |
| Build | Build + push imagem para registry | ~1m |
| Security | Scan Trivy | ~1m11s |
| Helm Validate | helm lint + template | ~30s |
| Terraform Validate | init + validate + fmt | ~30s |

### Pipeline CD (cd-deploy.yml)
| Job | Descricao |
|-----|-----------|
| Approval | Aprovacao manual por email (environment: production) |
| Deploy | helm upgrade --install no Kubernetes |

---

## Resultado do Kubernetes

```
NAMESPACE    NAME                                READY   STATUS    RESTARTS   AGE
azure-vote   azure-vote-back-5fc4d7f79-nc9d4     1/1     Running   0          14m
azure-vote   azure-vote-front-55c8f54487-b8n5b   1/1     Running   1          14m
azure-vote   azure-vote-front-55c8f54487-vrglz   1/1     Running   1          14m
newrelic     newrelic-nri-metadata-injection     1/1     Running   0          82s
newrelic     newrelic-nri-prometheus             1/1     Running   0          82s
newrelic     newrelic-nrk8s-controlplane         2/2     Running   0          70s
newrelic     newrelic-nrk8s-ksm                  2/2     Running   0          82s
newrelic     newrelic-nrk8s-kubelet              2/2     Running   0          69s
```

### Acesso a Aplicacao
- **URL:** http://localhost:30080
- **HTTP Status:** 200
- **Conteudo:** Pagina de votacao Cats x Dogs

---

## Repositorios

| Repositorio | URL |
|-------------|-----|
| **Projeto principal** | https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao |
| **Fork original** | https://github.com/Icaro0310/azure-voting-app-redis |
| **Repositorio original** | https://github.com/osanam-giordane/azure-voting-app-redis |

---

## Colaboradores

| Usuario | Permissao | Funcao |
|---------|-----------|--------|
| `Icaro0310` | Owner | Aluno - Icaro Galvao do Nascimento |
| `osanam-giordane` | Admin | Professor - validacao do projeto |

---

**Aluno:** Icaro Galvao do Nascimento  
**Curso:** Unylea - Engenheiro DevOps  
**Data:** 05/08/2026