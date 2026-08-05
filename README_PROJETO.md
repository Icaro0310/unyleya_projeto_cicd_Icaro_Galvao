# Unyleya Projeto CI/CD - Azure Voting App

**Aluno:** Icaro Galvao do Nascimento  
**Curso:** Unylea - Engenheiro DevOps  
**Projeto:** Pipeline CI/CD com GitHub Actions  

---

## Sobre o Projeto

Este projeto implementa uma esteira (pipeline) automatizada de CI/CD para a aplicacao **Azure Voting App Redis** usando **GitHub Actions**.

A aplicacao consiste em:
- **Frontend:** Python Flask (votacao web)
- **Backend:** Redis (armazenamento dos votos)
- **Containerizacao:** Docker + Docker Compose

---

## Topologia do Pipeline

```
[Push/Pull Request no GitHub]
         |
         v
    +-----------+
    |   LINT    |  -> flake8 + pylint (qualidade de codigo)
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
    |  DEPLOY   |  -> Push para Docker Hub (apenas branch main)
    +-----------+
```

---

## Jobs do Pipeline

| Job | Descricao | Ferramenta |
|-----|-----------|------------|
| **Lint** | Analise estatica do codigo Python | flake8, pylint |
| **Build** | Construcao da imagem Docker | docker/build-push-action |
| **Test** | Testes integrados com Docker Compose | docker-compose, curl |
| **Security** | Scan de vulnerabilidades na imagem | Trivy |
| **Deploy** | Publicacao da imagem (apenas main) | Docker Hub (opcional) |

---

## Como Executar

### 1. Fork e Clone
```bash
git clone https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao.git
cd unyleya_projeto_cicd_Icaro_Galvao
```

### 2. Executar localmente com Docker Compose
```bash
docker-compose up -d
# Acessar: http://localhost:8080
```

### 3. O pipeline executa automaticamente
- Em cada **push** para `main` ou `master`
- Em cada **Pull Request** para `main` ou `master`

---

## Repositorio

- **GitHub:** https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao
- **Fork de:** https://github.com/osanam-giordane/azure-voting-app-redis

---

## Tecnologia Utilizada

- **CI/CD:** GitHub Actions (gratuito para repos publicos)
- **Containerizacao:** Docker + Docker Compose
- **Linguagem:** Python (Flask)
- **Backend:** Redis
- **Security:** Trivy
- **Code Quality:** flake8, pylint

---

**Aluno:** Icaro Galvao do Nascimento  
**Curso:** Unylea - Engenheiro DevOps