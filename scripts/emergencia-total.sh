#!/bin/bash
# SCRIPT DE EMERGÊNCIA TOTAL - LIMPA TUDO E REINSTALA
# Executar se o k3s estiver com problemas graves

set -e

echo "=========================================="
echo "  EMERGÊNCIA TOTAL - LIMPEZA COMPLETA"
echo "=========================================="

# 1. Matar todos os processos k3s e containerd
echo ">>> Matando processos k3s/containerd..."
sudo pkill -9 k3s || true
sudo pkill -9 containerd || true
sudo pkill -9 containerd-shim || true
sleep 5

# 2. Parar e desabilitar k3s
echo ">>> Parando k3s..."
sudo systemctl stop k3s || true
sudo systemctl disable k3s || true

# 3. Limpar completamente
echo ">>> Limpando completamente k3s..."
sudo rm -rf /var/lib/rancher/k3s/*
sudo rm -rf /etc/rancher/k3s/*
sudo rm -f /usr/local/bin/k3s
sudo rm -f /usr/local/bin/kubectl
sudo rm -f /usr/local/bin/crictl
sudo rm -f /usr/local/bin/ctr

# 4. Remover serviço systemd
echo ">>> Removendo serviço systemd..."
sudo rm -f /etc/systemd/system/k3s.service
sudo rm -f /etc/systemd/system/k3s.service.env
sudo systemctl daemon-reload

# 5. Reinstalar k3s do zero
echo ">>> Reinstalando k3s do zero..."
curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_START=true sh -

# 6. Habilitar e iniciar k3s
echo ">>> Iniciando k3s..."
sudo systemctl enable k3s
sudo systemctl start k3s

# 7. Aguardar k3s iniciar
echo ">>> Aguardando k3s iniciar (60 segundos)..."
sleep 60

# 8. Verificar status
echo ">>> Verificando status k3s..."
sudo systemctl status k3s

# 9. Verificar cluster
echo ">>> Verificando cluster..."
sudo k3s kubectl get nodes

# 10. Configurar kubectl
echo ">>> Configurando kubectl..."
mkdir -p ~/.kube
sudo k3s kubectl config view --raw > ~/.kube/config
chmod 600 ~/.kube/config

# 11. Criar namespace
echo ">>> Criando namespace..."
sudo k3s kubectl create namespace azure-vote --dry-run=client -o yaml | sudo k3s kubectl apply -f -

# 12. Deploy via Helm
echo ">>> Fazendo deploy via Helm..."
cd /tmp
rm -rf unyleya_projeto_cicd_Icaro_Galvao
git clone https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao.git
cd unyleya_projeto_cicd_Icaro_Galvao

helm upgrade --install azure-vote iac/helm/azure-vote \
  --namespace azure-vote \
  --create-namespace \
  --set frontend.image.repository=ghcr.io/Icaro0310/azure-vote-front \
  --set frontend.image.tag=latest \
  --set frontend.image.pullPolicy=Always \
  --set service.frontend.type=NodePort \
  --set service.frontend.nodePort=30080 \
  --wait --timeout 300s

# 13. Verificar deploy
echo ">>> Verificando deploy..."
sudo k3s kubectl get all -n azure-vote

# 14. Testar acesso
echo ">>> Testando acesso..."
sleep 10
curl -I http://localhost:30080 || echo "Aguardando aplicação iniciar..."

echo "=========================================="
echo "  DEPLOY CONCLUÍDO!"
echo "=========================================="
echo "Aplicação disponível em: http://35.228.210.46:30080"
echo "=========================================="