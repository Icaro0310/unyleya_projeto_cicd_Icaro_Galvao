# MIGRAÇÃO PARA VM GOOGLE CLOUD - INSTRUÇÕES COMPLETAS

## SITUAÇÃO ATUAL
- ✅ Aplicação rodando no kind local (localhost:30080)
- ❌ Professor não consegue acessar (só funciona na sua máquina)
- ✅ VM Google Cloud pronta: unyleya-k8s (IP: 35.228.210.46)

## OBJETIVO
Migrar a aplicação do kind local para a VM Google Cloud para acesso público do professor.

---

## ESTRUTURA CRIADA

### Scripts (na pasta `scripts/`)
1. **setup-vm-k8s.sh** - Setup inicial da VM (Kubernetes k3s + Helm)
2. **deploy-app.sh** - Deploy da aplicação na VM
3. **setup-newrelic.sh** - Configuração do New Relic

### Arquivos de Configuração
1. **values-prod.yaml** - Configurações Helm para produção na VM
2. **cd-deploy-vm.yml** - Pipeline CD para deploy na VM

---

## PASSO A PASSO

### 1. ACESSAR A VM VIA SSH

#### Opção A: Usando Google Cloud CLI (recomendado)
```bash
# Instalar gcloud SDK primeiro se não tiver
# Depois:
gcloud compute ssh unyleya-k8s --zone=europe-north1-c
```

#### Opção B: Usando SSH direto
```bash
ssh -i /caminho/para/chave-privada usuario@35.228.210.46
```

### 2. EXECUTAR SETUP INICIAL NA VM

Dentro da VM, execute:

```bash
# Clonar o repositório
git clone https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao.git
cd unyleya_projeto_cicd_Icaro_Galvao

# Dar permissão de execução aos scripts
chmod +x scripts/*.sh

# Executar setup do Kubernetes
./scripts/setup-vm-k8s.sh
```

**O que este script faz:**
- Atualiza o sistema
- Instala k3s (Kubernetes leve)
- Configura kubectl
- Instala Helm
- Configura firewall (portas 30080, 6443, 10250)
- Cria namespace azure-vote
- Configura kubeconfig para acesso externo

### 3. COPIAR KUBECONFIG PARA GITHUB

Após o setup, o script exibirá o conteúdo do kubeconfig. Você precisa:

1. Copiar o conteúdo do arquivo `~/.kube/config` da VM
2. No GitHub: Settings → Secrets and variables → Actions → New repository secret
3. Nome: `KUBECONFIG_VM`
4. Valor: Colar o conteúdo do kubeconfig (em base64)

Para converter em base64 na VM:
```bash
cat ~/.kube/config | base64 -w 0
```

### 4. FAZER DEPLOY DA APLICAÇÃO

#### Opção A: Via Script na VM (recomendado para teste)
```bash
cd unyleya_projeto_cicd_Icaro_Galvao
./scripts/deploy-app.sh
```

#### Opção B: Via GitHub Actions (recomendado para produção)
1. Commit e push das mudanças no repositório
2. O pipeline `CI - Build e Push Imagem` vai rodar automaticamente
3. Vá em Actions → CD - Deploy VM Google Cloud
4. Clique em "Run workflow"
5. Aprovação por email será enviada
6. Após aprovação, o deploy será executado

### 5. CONFIGURAR NEW RELIC (OPCIONAL)

```bash
cd unyleya_projeto_cicd_Icaro_Galvao
./scripts/setup-newrelic.sh
```

Você precisará da New Relic License Key de:
https://one.newrelic.com/launcher/nerdpacks.launcher

---

## VERIFICAÇÃO

### Verificar se a aplicação está rodando
```bash
# Na VM
kubectl get pods -n azure-vote
kubectl get svc -n azure-vote
```

### Testar acesso público
```bash
# De qualquer lugar
curl http://35.228.210.46:30080
```

Acesse no navegador: http://35.228.210.46:30080

---

## DIFERENÇAS ENTRE LOCAL E VM

| Aspecto | Kind Local | VM Google Cloud |
|---------|------------|-----------------|
| Cluster | kind (Docker) | k3s (Kubernetes nativo) |
| Acesso | localhost:30080 | 35.228.210.46:30080 |
| Registry | localhost:5000 | ghcr.io (GitHub Container Registry) |
| Helm Chart | values.yaml | values-prod.yaml |
| Pipeline | cd-deploy.yml | cd-deploy-vm.yml |
| Kubeconfig Secret | KUBECONFIG | KUBECONFIG_VM |

---

## TROUBLESHOOTING

### Porta 30080 não acessível
```bash
# Verificar firewall na VM
sudo ufw status
sudo ufw allow 30080/tcp

# Verificar se NodePort está configurado
kubectl get svc -n azure-vote
```

### Imagem não pulla do ghcr.io
```bash
# Verificar secret do registry
kubectl get secret ghcr-secret -n azure-vote

# Recriar secret se necessário
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=Icaro0310 \
  --docker-password=SEU_GITHUB_TOKEN \
  --namespace azure-vote
```

### Pods não iniciam
```bash
# Verificar logs
kubectl logs -n azure-vote -l app=azure-vote-front

# Verificar eventos
kubectl describe pod -n azure-vote -l app=azure-vote-front
```

---

## VALIDAÇÃO PARA O PROFESSOR

O professor poderá acessar:
- ✅ Aplicação rodando: http://35.228.210.46:30080
- ✅ Código + IaC: GitHub
- ✅ Pipelines CI/CD: GitHub Actions
- ✅ Helm Chart: GitHub
- ✅ Logs: GitHub Actions + kubectl na VM
- ✅ New Relic: Se configurado

---

## PRÓXIMOS PASSOS

1. Acessar a VM via SSH
2. Executar `setup-vm-k8s.sh`
3. Copiar kubeconfig para GitHub (secret KUBECONFIG_VM)
4. Executar `deploy-app.sh` OU usar GitHub Actions
5. Testar acesso em http://35.228.210.46:30080
6. Configurar New Relic (opcional)
7. Compartilhar URL com o professor