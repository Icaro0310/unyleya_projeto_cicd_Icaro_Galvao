# Scripts de Setup e Deploy

## Scripts Disponíveis

### 1. setup-vm-k8s.sh
Setup inicial da VM Google Cloud para Kubernetes.

**O que faz:**
- Atualiza o sistema
- Instala k3s (Kubernetes leve)
- Configura kubectl
- Instala Helm
- Configura firewall (portas 30080, 6443, 10250)
- Cria namespace azure-vote
- Configura kubeconfig para acesso externo

**Como usar:**
```bash
chmod +x setup-vm-k8s.sh
./setup-vm-k8s.sh
```

### 2. deploy-app.sh
Deploy da aplicação Azure Voting App na VM.

**O que faz:**
- Configura acesso ao GitHub Container Registry
- Clona o repositório
- Faz deploy via Helm Chart
- Configura NodePort para acesso público
- Testa acesso à aplicação

**Como usar:**
```bash
chmod +x deploy-app.sh
./deploy-app.sh
```

### 3. setup-newrelic.sh
Configura monitoramento com New Relic.

**O que faz:**
- Adiciona repositório Helm do New Relic
- Instala New Relic Bundle
- Configura license key
- Verifica pods do New Relic

**Como usar:**
```bash
chmod +x setup-newrelic.sh
./setup-newrelic.sh
```

---

## Ordem de Execução

1. **setup-vm-k8s.sh** - Primeiro (configura o ambiente)
2. **deploy-app.sh** - Segundo (deploy da aplicação)
3. **setup-newrelic.sh** - Terceiro (monitoramento, opcional)

---

## Requisitos

- Acesso SSH à VM Google Cloud
- Permissões sudo
- Conexão com internet