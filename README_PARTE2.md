# Unyleya Projeto DevOps - Parte 2

**Aluno:** Icaro Galvao do Nascimento  
**Curso:** Unylea - Engenheiro DevOps  
**Projeto:** Kubernetes, Terraform, Helm e Monitoramento New Relic  

---

## Sobre a Parte 2

Nesta etapa dei continuidade ao projeto iniciado na Unidade 3, incluindo a criacao da infraestrutura Kubernetes, deploy da aplicacao via Helm Chart, pipeline de CD com aprovacao por email, e monitoramento com New Relic.

A aplicacao Azure Voting App (frontend Python Flask + backend Redis) foi implantada em um cluster Kubernetes e monitorada com New Relic.

---

## Topologia

```
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

### Etapa 1: Criacao da Infraestrutura Kubernetes (substituto do AKS)

Criei um cluster Kubernetes local usando **kind (Kubernetes in Docker)** como alternativa ao AKS (Azure Kubernetes Service), ja que minha subscription Azure estava desativada.

- Cluster: `unyleya-k8s` (1 node control-plane)
- Kubernetes v1.30.0
- Porta NodePort 30080 mapeada para o host

### Etapa 2: Registry de Imagens (substituto do ACR)

Configurei o **GitHub Container Registry (ghcr.io)** como alternativa ao ACR (Azure Container Registry) para armazenar as imagens da aplicacao. Tambem utilizei um registry Docker local para testes.

### Etapa 3: Terraform - Provisionamento K8s

Criei a infraestrutura como codigo com Terraform (Kubernetes provider) provisionando:

- Namespace `azure-vote`
- ConfigMap com configuracoes da aplicacao (TITLE, VOTE1VALUE, VOTE2VALUE)
- Deployment do frontend (2 replicas, Flask)
- Deployment do backend (1 replica, Redis)
- Service NodePort (porta 30080) para frontend
- Service ClusterIP para backend
- Liveness e readiness probes
- Resource limits (CPU e memoria)

Arquivo principal: `iac/terraform-k8s/main.tf`

### Etapa 4: Helm Chart da Aplicacao

Criei um Helm Chart para a aplicacao azure-vote com a seguinte estrutura:

- `Chart.yaml` - metadados do chart (v1.0.0)
- `values.yaml` - configuracoes parametrizaveis (replicas, imagens, resources, probes)
- `templates/namespace.yaml` - namespace azure-vote
- `templates/configmap.yaml` - configuracoes da aplicacao
- `templates/deployment-frontend.yaml` - deployment Flask (2 replicas)
- `templates/deployment-backend.yaml` - deployment Redis (1 replica)
- `templates/service.yaml` - services NodePort e ClusterIP
- `templates/NOTES.txt` - instrucoes pos-deploy

Diretorio: `iac/helm/azure-vote/`

Validacao do chart:
- `helm lint` - aprovado sem erros
- `helm template` - renderizado com sucesso

### Etapa 5: Pipeline CI - Build e Push da Imagem (ci-build.yml)

Criei a pipeline de CI atualizada para build e push da imagem para o registry:

1. **Lint & Code Quality** - analise estatica com flake8
2. **Build Docker Image** - build da imagem + push para GitHub Container Registry (ghcr.io)
3. **Security Scan** - scanner de vulnerabilidades com Trivy
4. **Validar Helm Chart** - helm lint + helm template
5. **Validar Terraform** - terraform init + validate + fmt

A imagem e enviada para `ghcr.io/icaro0310/azure-vote-front` com tag do SHA do commit e tag `latest`.

### Etapa 6: Pipeline CD com Aprovacao por Email (cd-deploy.yml)

Criei a pipeline de CD com dois jobs:

**Job 1 - Aprovacao por Email:**
- Usa GitHub Environment `production` com required reviewers
- Os aprovadores recebem notificacao por email
- O deploy so continua apos aprovacao manual

**Job 2 - Deploy via Helm:**
- Login no GitHub Container Registry
- Configuracao do kubeconfig do cluster
- `helm upgrade --install` com a imagem do registry
- Verificacao do deployment (kubectl get all)
- Teste de acesso a aplicacao (curl)
- Resumo do deploy

A pipeline e acionada automaticamente apos a conclusao da pipeline de CI ou manualmente via `workflow_dispatch`.

### Etapa 7: Implantacao no Kubernetes

Fiz o build da imagem da aplicacao e o deploy no cluster Kubernetes local via Helm:

Build da imagem:
```bash
docker build -t azure-vote-front:latest ./azure-vote
```

Carregamento da imagem no node kind:
```bash
docker save azure-vote-front:latest -o azure-vote.tar
docker cp azure-vote.tar unyleya-k8s-control-plane:/azure-vote.tar
docker exec unyleya-k8s-control-plane ctr -n k8s.io images import /azure-vote.tar
```

Deploy via Helm:
```bash
helm install azure-vote iac/helm/azure-vote \
  --set frontend.image.repository=azure-vote-front \
  --set frontend.image.tag=latest \
  --set frontend.image.pullPolicy=Never
```

Resultado do deploy:
- 3 pods rodando (2 frontend + 1 backend)
- Service NodePort exposto na porta 30080
- Aplicacao acessivel em http://localhost:30080

### Etapa 8: Monitoramento com New Relic

Criei conta New Relic (free trial - 100GB gratis por mes) e instalei o agente no cluster Kubernetes via Helm:

```bash
helm repo add newrelic https://helm-charts.newrelic.com
helm repo update

helm install newrelic newrelic/nri-bundle \
  --set global.licenseKey=<INGEST-LICENSE-KEY> \
  --set global.cluster=unyleya-k8s \
  --namespace newrelic \
  --create-namespace \
  --set global.lowDataMode=true \
  --set infrastructure.enabled=true \
  --set logs.enabled=true \
  --set metrics.enabled=true \
  --set prometheus.enabled=true
```

Componentes do New Relic instalados:
- **nri-metadata-injection** - injecao de metadata nos pods
- **nri-prometheus** - coleta de metricas Prometheus
- **nrk8s-controlplane** - monitoramento do control plane
- **nrk8s-ksm** - Kubernetes State Metrics
- **nrk8s-kubelet** - monitoramento do kubelet

O monitoramento cobre:
- Infraestrutura (nodes, pods, containers)
- Kubernetes (control plane, kubelet, KSM)
- Metricas Prometheus
- Logs da aplicacao
- Aplicacao implantada

### Etapa 9: Teste de Acesso a Aplicacao

Testei o acesso a aplicacao provisionada no Kubernetes:

```bash
curl http://localhost:30080
```

Resultado:
- HTTP Status: 200
- Pagina de votacao com botoes Cats e Dogs funcionando
- Redis armazenando os votos corretamente

### Etapa 10: Permissao para o Professor

Adicionei o professor `osanam-giordane` como colaborador com permissao de **ADMIN** no repositorio GitHub para validacao do projeto.

---

## Estrutura de Arquivos da Parte 2

```
unyleya_projeto_cicd_Icaro_Galvao/
├── .github/
│   └── workflows/
│       ├── ci-build.yml           # Pipeline CI (build + push registry)
│       └── cd-deploy.yml          # Pipeline CD (deploy Helm + aprovacao email)
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
└── README_PARTE2.md               # Esta documentacao
```

---

## Tecnologia Utilizada

| Tecnologia | Funcao |
|------------|--------|
| **Kubernetes (kind)** | Orquestracao de containers (substituto do AKS) |
| **Terraform** | Infraestrutura como codigo (K8s provider) |
| **Helm** | Gerenciamento de pacotes K8s (Chart da aplicacao) |
| **GitHub Actions** | CI/CD - pipelines automatizados |
| **GitHub Container Registry** | Registry de imagens (substituto do ACR) |
| **Docker** | Containerizacao |
| **Python Flask** | Aplicacao web (votacao) |
| **Redis** | Backend - armazenamento dos votos |
| **New Relic** | Monitoramento e telemetria |
| **Trivy** | Scanner de vulnerabilidades |
| **flake8** | Analise estatica de codigo |
| **Git/GitHub** | Controle de versao e hospedagem |

---

## Pipelines GitHub Actions

### Pipeline CI (ci-build.yml)

| Job | Descricao | Ferramenta |
|-----|-----------|------------|
| Lint | Analise estatica do codigo | flake8 |
| Build | Build + push imagem para registry | docker, ghcr.io |
| Security | Scan de vulnerabilidades | Trivy |
| Helm Validate | Validacao do Helm Chart | helm lint + template |
| Terraform Validate | Validacao do Terraform | terraform init + validate + fmt |

### Pipeline CD (cd-deploy.yml)

| Job | Descricao | Gatilho |
|-----|-----------|---------|
| Approval | Aprovacao manual por email | Apos CI completar |
| Deploy | helm upgrade --install no Kubernetes | Apos aprovacao |

---

## Resultado do Kubernetes

```
NAMESPACE    NAME                                READY   STATUS    RESTARTS   AGE
azure-vote   azure-vote-back                     1/1     Running   0          16m
azure-vote   azure-vote-front (replica 1)        1/1     Running   1          16m
azure-vote   azure-vote-front (replica 2)        1/1     Running   1          16m
newrelic     newrelic-nri-metadata-injection     1/1     Running   0          3m
newrelic     newrelic-nri-prometheus             1/1     Running   0          3m
newrelic     newrelic-nrk8s-controlplane         2/2     Running   0          3m
newrelic     newrelic-nrk8s-ksm                  2/2     Running   0          33s
newrelic     newrelic-nrk8s-kubelet              2/2     Running   0          3m
```

### Acesso a Aplicacao
- **URL:** http://localhost:30080
- **HTTP Status:** 200
- **Conteudo:** Pagina de votacao Cats x Dogs

---

## Repositorio

- **GitHub:** https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao

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