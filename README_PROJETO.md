# Unyleya Projeto CI/CD - Azure Voting App

**Aluno:** Icaro Galvao do Nascimento  
**Curso:** Unylea - Engenheiro DevOps  
**Projeto:** Pipeline CI/CD com GitHub Actions  

---

## Sobre o Projeto

Implementei uma esteira (pipeline) automatizada de CI/CD para a aplicacao **Azure Voting App Redis** usando **GitHub Actions**. A aplicacao consiste em um frontend Python Flask (sistema de votacao web) e um backend Redis para armazenamento dos votos, containerizados com Docker e Docker Compose.

---

## Topologia do Pipeline

```
[Push/Pull Request no GitHub]
         |
         v
    +-----------+
    |   LINT    |  -> flake8 (qualidade de codigo)
    +-----------+
         |
         v
    +-----------+
    |   BUILD   |  -> Build da imagem Docker (azure-vote-front)
    +-----------+
         |
    +----+----+
    |         |
    v         v
+-------+ +----------+
| TEST  | | SECURITY |  -> Testes integrados + Scan Trivy
+-------+ +----------+
    |         |
    +----+----+
         |
         v
    +-----------+
    |  DEPLOY   |  -> Resumo do deploy (apenas branch main)
    +-----------+
```

---

## Jobs do Pipeline

| Job | Descricao | Ferramenta | Duracao |
|-----|-----------|------------|---------|
| **Lint** | Analise estatica do codigo Python | flake8 | 18s |
| **Build** | Construcao da imagem Docker | docker build | 1m2s |
| **Test** | Testes integrados com Docker Compose | docker compose, curl, redis-cli | 50s |
| **Security** | Scan de vulnerabilidades na imagem | Trivy | 1m11s |
| **Deploy** | Resumo do deploy (apenas main) | echo | 40s |

**Tempo total do pipeline:** 3m26s  
**Resultado:** 5/5 jobs aprovados

---

## Etapas Realizadas

### Etapa 1: Fork do Repositorio
Fiz o fork do repositorio original `osanam-giordane/azure-voting-app-redis` para minha conta GitHub, criando `Icaro0310/azure-voting-app-redis`.

### Etapa 2: Clone para PC
Clonei o repositorio forkado para minha maquina local em `C:\Users\Utilizador\Downloads\azure-voting-app-redis`.

### Etapa 3: Criacao do Novo Repositorio
Criei um novo repositorio no GitHub chamado `unyleya_projeto_cicd_Icaro_Galvao` com descricao "Unyleya Projeto DevOps - CI/CD - Icaro Galvao do Nascimento".

### Etapa 4: Commit e Push do Codigo
Alterei o remote origin para o novo repositorio e fiz o push de todo o codigo da aplicacao azure-voting-app-redis para o novo repositorio.

### Etapa 5: Criacao do Pipeline CI/CD
Criei o arquivo `.github/workflows/ci-cd.yml` com 5 jobs encadeados:

1. **Lint & Code Quality** - Analise estatica com flake8
2. **Build Docker Image** - Construcao da imagem Docker da aplicacao
3. **Testes Integrados** - Subida da aplicacao com Docker Compose, teste HTTP (curl), teste Redis (redis-cli)
4. **Security Scan** - Scan de vulnerabilidades com Trivy
5. **Deploy** - Resumo do deploy (executado apenas na branch main)

### Etapa 6: Correcoes do Pipeline
Durante a execucao do pipeline, identifiquei e corrigi os seguintes problemas:

- **Tentativa 1:** Parametro invalido `tags-additional` no docker/build-push-action - corrigi usando `docker build` direto
- **Tentativa 2:** Acesso a `secrets` em condicional `if` - corrigi passando secret para variavel de ambiente
- **Tentativa 3:** Comando `docker-compose` nao encontrado no runner (GitHub Actions usa Docker Compose v2) - corrigi para `docker compose`
- **Tentativa 4:** Pipeline executado com sucesso total - 5/5 jobs aprovados

### Etapa 7: Adicao do Professor como Colaborador
Adicionei o professor `osanam-giordane` como colaborador com permissao de **ADMIN** no repositorio, para que ele possa validar todos os passos.

---

## Como Executar

### 1. Clonar o repositorio
```bash
git clone https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao.git
cd unyleya_projeto_cicd_Icaro_Galvao
```

### 2. Executar localmente com Docker Compose
```bash
docker compose up -d
# Acessar: http://localhost:8080
```

### 3. O pipeline executa automaticamente
- Em cada **push** para `main` ou `master`
- Em cada **Pull Request** para `main` ou `master`

Acompanhamento do pipeline:
- **URL:** https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao/actions
- **Run de sucesso:** Run #31026864085 (3m26s - 5/5 jobs aprovados)

---

## Estrutura do Repositorio

```
unyleya_projeto_cicd_Icaro_Galvao/
├── .github/
│   └── workflows/
│       └── ci-cd.yml              # Pipeline CI/CD (GitHub Actions)
├── azure-vote/
│   ├── azure-vote/
│   │   ├── main.py                # Aplicacao Flask (votacao)
│   │   ├── config_file.cfg        # Configuracoes da aplicacao
│   │   ├── static/
│   │   │   └── default.css        # Estilos CSS
│   │   └── templates/
│   │       └── index.html         # Template da pagina de votacao
│   ├── Dockerfile                 # Dockerfile do frontend (Flask)
│   ├── Dockerfile-for-app-service # Dockerfile alternativo para App Service
│   ├── app_init.supervisord.conf  # Configuracao do supervisord
│   └── sshd_config                # Configuracao SSH
├── jenkins-tutorial/
│   ├── config-jenkins.sh          # Script de configuracao Jenkins
│   └── deploy-jenkins-vm.sh       # Script de deploy Jenkins VM
├── docker-compose.yaml            # Docker Compose (frontend + Redis)
├── azure-vote-all-in-one-redis.yaml  # Manifest Kubernetes
├── azure-pipelines.yml            # Pipeline Azure DevOps (original)
├── README_PROJETO.md              # Documentacao do projeto
├── README.md                      # README original
├── .gitignore
└── LICENSE
```

---

## Tecnologia Utilizada

| Tecnologia | Funcao |
|------------|--------|
| **GitHub Actions** | CI/CD - pipeline automatizado |
| **Docker** | Containerizacao da aplicacao |
| **Docker Compose** | Orquestracao frontend + backend |
| **Python Flask** | Aplicacao web (votacao) |
| **Redis** | Backend - armazenamento dos votos |
| **flake8** | Analise estatica de codigo |
| **Trivy** | Scanner de vulnerabilidades |
| **Git** | Controle de versao |
| **GitHub** | Hospedagem do repositorio |

---

## Repositorios

| Repositorio | URL |
|-------------|-----|
| **Projeto CI/CD (principal)** | https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao |
| **Fork original** | https://github.com/Icaro0310/azure-voting-app-redis |
| **Repositorio original** | https://github.com/osanam-giordane/azure-voting-app-redis |

---

## Resultado do Pipeline

```
✓ Lint & Code Quality           - 18s   APROVADO
✓ Build Docker Image            - 1m2s  APROVADO
✓ Security Scan (Trivy)         - 1m11s APROVADO
✓ Testes Integrados (Docker)    - 50s   APROVADO
✓ Deploy (Producao)             - 40s   APROVADO
─────────────────────────────────────────────
  Total: 3m26s | 5/5 jobs aprovados | 0 falhas
```

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