#!/bin/bash
# Script de setup para VM Google Cloud - Kubernetes + Helm + Configurações
# Para VM: unyleya-k8s (IP: 35.228.210.46)

set -e

echo "=========================================="
echo "  SETUP KUBERNETES NA VM GOOGLE CLOUD"
echo "=========================================="
echo "VM: unyleya-k8s"
echo "IP Externo: 35.228.210.46"
echo "=========================================="

# Atualizar sistema
echo ">>> Atualizando sistema..."
sudo apt-get update && sudo apt-get upgrade -y

# Instalar dependências
echo ">>> Instalando dependências..."
sudo apt-get install -y curl git apt-transport-https ca-certificates gnupg lsb-release

# Instalar k3s (Kubernetes leve e simples)
echo ">>> Instalando k3s (Kubernetes)..."
curl -sfL https://get.k3s.io | sh -

# Aguardar k3s iniciar
echo ">>> Aguardando k3s iniciar..."
sleep 10
sudo systemctl status k3s

# Configurar kubectl
echo ">>> Configurando kubectl..."
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $USER:$USER $HOME/.kube/config
chmod 600 $HOME/.kube/config

# Verificar cluster
echo ">>> Verificando cluster..."
kubectl get nodes
kubectl version --short

# Instalar Helm
echo ">>> Instalando Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verificar Helm
echo ">>> Verificando Helm..."
helm version

# Configurar firewall para NodePort
echo ">>> Configurando firewall..."
sudo ufw allow 30080/tcp
sudo ufw allow 6443/tcp
sudo ufw allow 10250/tcp

# Criar namespace azure-vote
echo ">>> Criando namespace azure-vote..."
kubectl create namespace azure-vote --dry-run=client -o yaml | kubectl apply -f -

# Configurar kubeconfig para acesso externo
echo ">>> Configurando kubeconfig para acesso externo..."
# Substituir localhost pelo IP externo
sed -i "s/127.0.0.1/35.228.210.46/g" $HOME/.kube/config

# Testar acesso externo
echo ">>> Testando acesso ao cluster..."
kubectl get nodes

echo "=========================================="
echo "  SETUP CONCLUÍDO!"
echo "=========================================="
echo "Kubernetes: k3s instalado e rodando"
echo "Helm: instalado"
echo "Namespace azure-vote: criado"
echo "Firewall: portas 30080, 6443, 10250 abertas"
echo "=========================================="
echo "Cluster pronto para receber deploy!"
echo "=========================================="

# Exibir informações para copiar o kubeconfig
echo ""
echo ">>> Para acessar o cluster de fora da VM:"
echo "   Copie o conteúdo de ~/.kube/config e configure como secret KUBECONFIG no GitHub"
echo ""
echo ">>> Conteúdo do kubeconfig:"
cat $HOME/.kube/config