#!/bin/bash
# Script para continuar o setup após o k3s já estar instalado
# Execute este no Console SSH do Google Cloud

set -e

echo "=========================================="
echo "  CONTINUANDO SETUP KUBERNETES"
echo "=========================================="

# Configurar kubectl
echo ">>> Configurando kubectl..."
mkdir -p ~/.kube
sudo cat /etc/rancher/k3s/k3s.yaml > ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
chmod 600 ~/.kube/config

# Verificar cluster
echo ">>> Verificando cluster..."
sudo k3s kubectl get nodes
sudo k3s kubectl version --short

# Instalar Helm
echo ">>> Instalando Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verificar Helm
echo ">>> Verificando Helm..."
helm version

# Configurar firewall
echo ">>> Configurando firewall..."
sudo ufw allow 30080/tcp
sudo ufw allow 6443/tcp
sudo ufw allow 10250/tcp

# Criar namespace azure-vote
echo ">>> Criando namespace azure-vote..."
sudo k3s kubectl create namespace azure-vote --dry-run=client -o yaml | sudo k3s kubectl apply -f -

# Configurar kubeconfig para acesso externo
echo ">>> Configurando kubeconfig para acesso externo..."
sudo cat /etc/rancher/k3s/k3s.yaml | sed "s/127.0.0.1/35.228.210.46/g" > ~/.kube/config

echo "=========================================="
echo "  SETUP KUBERNETES CONCLUÍDO!"
echo "=========================================="
echo "=========================================="
echo "  KUBECONFIG PARA GITHUB"
echo "=========================================="
echo "Copie este texto e adicione como secret KUBECONFIG_VM no GitHub:"
echo ""
cat ~/.kube/config | base64 -w 0
echo ""
echo "=========================================="

echo ">>> Executando deploy da aplicação..."
cd ~/unyleya_projeto_cicd_Icaro_Galvao
./scripts/deploy-app.sh