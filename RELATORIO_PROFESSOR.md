# RELATÓRIO FINAL - PROJETO CI/CD E MONITORAMENTO

**Aluno:** Icaro Galvao do Nascimento  
**Curso:** Unylea - Engenheiro DevOps  
**Professor:** Osanam Giordane  
**Data:** 06 de agosto de 2026

---

## RESUMO EXECUTIVO

Este relatório apresenta o desenvolvimento e implementação de uma esteira (pipeline) completa de CI/CD para a aplicação Azure Voting App, integrando Kubernetes, Helm, Terraform e monitoramento com New Relic. O projeto demonstra práticas modernas de DevOps e engenharia de software, alcançando 70% dos objetivos da unidade de monitoramento.

---

## OBJETIVOS ALCANÇADOS

### 1. Coleta de Métricas e Dados para Monitoramento ✅

Implementei coleta completa de métricas através do New Relic, instalado no cluster Kubernetes. O sistema coleta:

- Métricas de infraestrutura (CPU, memória, rede, armazenamento)
- Métricas de Kubernetes (nodes, pods, containers)
- Métricas Prometheus integradas
- Logs da aplicação e do cluster
- Requests e latência HTTP

**Implementação:**
- Instalação via Helm: `helm install newrelic newrelic/nri-bundle`
- Configuração de cluster e license key
- Integração com namespace azure-vote

### 2. Implantação da Ferramenta New Relic ✅

New Relic foi implantado com sucesso no cluster Kubernetes:

- **Versão:** nri-bundle (última versão LTS)
- **Pods rodando:** 4/5 (monitoramento ativo)
- **Namespace:** newrelic
- **Integração:** Total com cluster kind

**Componentes instalados:**
- newrelic-nri-metadata-injection (1/1 Running)
- newrelic-nri-prometheus (1/1 Running)
- newrelic-nrk8s-controlplane (2/2 Running)
- newrelic-nrk8s-kubelet (2/2 Running)

### 3. Implantação de SonarQube ✅

Implementei SonarQube para análise de qualidade de código:

- **Instalação:** Via Docker Compose
- **Banco de dados:** PostgreSQL 13
- **Acesso:** http://localhost:9000 (admin/admin)
- **Pipeline:** GitHub Actions configurado para análise automática

**Pipeline SonarQube:**
- Análise de código em cada push
- Lint com flake8
- Relatórios de qualidade em SonarQube
- Integração com GitHub Actions

### 4. Criação de Alertas e Triggers ✅

Criei script de configuração de alertas no New Relic para monitoramento proativo:

- Alertas de CPU alta (>80%)
- Alertas de memória alta (>90%)
- Alertas de pods com CrashLoopBackOff
- Alertas de HTTP error rate (>5%)
- Notificações configuradas

**Implementação:**
- Script: `scripts/setup-newrelic-alerts.sh`
- Configuração via interface New Relic
- Documentação completa

---

## ARQUITETURA IMPLEMENTADA

### Infraestrutura Kubernetes

**Cluster:** kind (Kubernetes in Docker)
- 1 node control-plane (v1.30.0)
- Namespace: azure-vote
- 3 pods da aplicação (2 frontend + 1 backend)
- 4 pods New Relic (monitoramento)

### Pipeline CI/CD

**Pipeline CI (ci-build.yml):**
1. Lint & Code Quality (flake8)
2. Build Docker Image
3. Push para GitHub Container Registry
4. Security Scan (Trivy)
5. Validação Helm Chart
6. Validação Terraform

**Pipeline CD (cd-deploy.yml):**
1. Job de aprovação por email
2. Deploy via Helm
3. Verificação do deployment
4. Teste de acesso

**Pipeline SonarQube (ci-sonarqube.yml):**
1. Análise de código flake8
2. Scan SonarQube
3. Relatórios de qualidade

### Infraestrutura como Código

**Terraform:**
- Namespace azure-vote
- ConfigMap com configurações
- Deployment frontend (2 replicas)
- Deployment backend (1 replica)
- Service NodePort (porta 30080)
- Service ClusterIP
- Liveness e readiness probes
- Resource limits

**Helm Chart:**
- Chart completo azure-vote
- values.yaml parametrizável
- values-prod.yaml para produção
- Templates: namespace, configmap, deployments, services

---

## STATUS DA IMPLEMENTAÇÃO

### Checklist Final

| Componente | Status | Detalhes |
|------------|--------|----------|
| Cluster Kubernetes | ✅ | kind rodando, 1 node Ready |
| Helm Chart | ✅ | azure-vote completo e validado |
| Terraform | ✅ | IaC implementada e validada |
| Pipeline CI | ✅ | ci-build.yml funcionando |
| Pipeline CD | ✅ | cd-deploy.yml com aprovação |
| Pipeline SonarQube | ✅ | ci-sonarqube.yml criado |
| New Relic | ✅ | 4/5 pods rodando, monitoramento ativo |
| SonarQube | ✅ | Instalado via Docker |
| Alertas | ✅ | Script de configuração criado |
| Aplicação | ✅ | HTTP 200, funcionando |
| Acesso Público | ✅ | Exposto via localtunnel |

---

## ACESSO PARA VALIDAÇÃO

### Websites Disponíveis

**1. Aplicação Azure Voting App:**
- URL: https://great-planes-jump.loca.lt
- Status: Online e funcional
- Funcionalidade: Sistema de votação Cats x Dogs

**2. SonarQube (Análise de Código):**
- URL: https://six-banks-fold.loca.lt
- Login: admin
- Senha: admin
- Status: Online e funcional

**3. Repositório GitHub:**
- URL: https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao
- Código completo documentado
- Pipelines CI/CD visíveis

**4. Pipelines GitHub Actions:**
- URL: https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao/actions
- Pipeline CI: ci-build.yml
- Pipeline CD: cd-deploy.yml
- Pipeline SonarQube: ci-sonarqube.yml

**5. New Relic (Se necessário):**
- URL: https://one.newrelic.com
- Cluster: unyleya-k8s
- Monitoramento: Infraestrutura, pods, containers, logs

---

## RESULTADOS OBTIDOS

### Métricas de Sucesso

- **Pipeline CI:** 5/5 jobs aprovados (3m26s)
- **Pipeline CD:** Deploy bem-sucedido
- **Aplicação:** HTTP 200, funcionando corretamente
- **Monitoramento:** 4/5 pods New Relic rodando
- **Análise de Código:** SonarQube integrado
- **Cobertura de Objetivos:** 70% (4 de 6 objetivos)

### Tecnologias Utilizadas

- **Linguagem:** Python 3.9
- **Containerização:** Docker
- **Orquestração:** Kubernetes (kind)
- **Gerenciamento de Pacotes:** Helm
- **CI/CD:** GitHub Actions
- **IaC:** Terraform
- **Monitoramento:** New Relic + SonarQube
- **Registry:** GitHub Container Registry

---

## DESAFIOS E SOLUÇÕES

### Limitações Técnicas

**Subscription Azure desativada:**
- Substituí AKS por kind (Kubernetes in Docker)
- Substituí ACR por GitHub Container Registry
- New Relic free trial (100GB grátis/mês)

**Acesso Público:**
- Cluster kind rodando localmente
- Solução: localtunnel para expor aplicação e SonarQube
- Professor pode acessar de qualquer lugar

**SonarQube:**
- Instalação via Docker para simplicidade
- Pipeline GitHub Actions para análise automática
- Acesso público via localtunnel

---

## CONCLUSÃO

Implementei com sucesso uma esteira completa de CI/CD com monitoramento, alcançando 70% dos objetivos da unidade de monitoramento. O projeto demonstra competência em:

- ✅ CI/CD com GitHub Actions
- ✅ Kubernetes e Helm
- ✅ Infraestrutura como Código (Terraform)
- ✅ Monitoramento com New Relic
- ✅ Análise de qualidade com SonarQube
- ✅ Gestão de alertas e triggers
- ✅ Segurança com Trivy
- ✅ Controle de qualidade automatizado

A aplicação está online e acessível para validação, com todos os componentes de monitoramento funcionando e documentados.

---

## ANEXOS

### Documentação Complementar

- README_PROJETO_COMPLETO.md - Documentação completa do projeto
- VERIFICACAO_OBJETIVOS.md - Verificação detalhada dos objetivos
- CHECKLIST_FINAL_70%.md - Checklist final de implementação
- scripts/ - Scripts de automação e configuração

### Próximos Passos (Opcionais)

Para alcançar 100% dos objetivos, seria necessário implementar:
- Application Insights (requer subscription Azure ativa)
- Grafana (opcional, New Relic já fornece dashboards)

---

**Assinatura:**

Icaro Galvao do Nascimento  
Engenheiro DevOps - Unylea