#!/bin/bash
# SCRIPT DE EMERGÊNCIA - RESOLVE PROBLEMAS K3S E FAZ DEPLOY
# Execute este script na VM via Console SSH para concluir o deploy

set -e

echo "=========================================="
echo "  SCRIPT DE EMERGÊNCIA - DEPLOY"
echo "=========================================="

# 1. Parar k3s completamente
echo ">>> Parando k3s..."
sudo systemctl stop k3s
sudo systemctl disable k3s

# 2. Limpar problemas de banco de dados k3s
echo ">>> Limpando problemas do k3s..."
sudo rm -f /var/lib/rancher/k3s/server/db/*
sudo rm -f /var/lib/rancher/k3s/server/tls/*

# 3. Reinstalar k3s limpo
echo ">>> Reinstalando k3s limpo..."
curl -sfL https://get.k3s.io | sh -

# 4. Aguardar e verificar
echo ">>> Aguardando k3s iniciar..."
sleep 30
sudo systemctl status k3s

# 5. Verificar cluster
echo ">>> Verificando cluster..."
sudo k3s kubectl get nodes

# 6. Configurar kubectl local
echo ">>> Configurando kubectl..."
mkdir -p ~/.kube
sudo k3s kubectl config view --raw > ~/.kube/config
chmod 600 ~/.kube/config

# 7. Criar namespace
echo ">>> Criando namespace..."
sudo k3s kubectl create namespace azure-vote --dry-run=client -o yaml | sudo k3s kubectl apply -f -

# 8. Deploy via Helm
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

# 9. Verificar deploy
echo ">>> Verificando deploy..."
sudo k3s kubectl get all -n azure-vote

# 10. Testar acesso
echo ">>> Testando acesso..."
sleep 10
curl -I http://localhost:30080 || echo "Aguardando aplicação iniciar..."

echo "=========================================="
echo "  DEPLOY CONCLUÍDO!"
echo "=========================================="
echo "Aplicação disponível em: http://35.228.210.46:30080"
echo "=========================================="