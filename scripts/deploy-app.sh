#!/bin/bash
# Script de deploy da aplicação Azure Voting App na VM
# Após o setup Kubernetes estar completo

set -e

echo "=========================================="
echo "  DEPLOY AZURE VOTING APP"
echo "=========================================="

# Configurações
REGISTRY="ghcr.io"
IMAGE_NAME="azure-vote-front"
IMAGE_TAG="latest"
REPO_OWNER="Icaro0310"
NAMESPACE="azure-vote"
RELEASE_NAME="azure-vote"

echo ">>> Configurando acesso ao GitHub Container Registry..."
# Nota: Para uso em produção, configure o secret do registry
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=$REPO_OWNER \
  --docker-password=GITHUB_TOKEN \
  --namespace $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

echo ">>> Adicionando repositório Helm local..."
# Clonar o repositório para obter o Helm Chart
cd /tmp
git clone https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao.git
cd unyleya_projeto_cicd_Icaro_Galvao

echo ">>> Fazendo deploy via Helm..."
helm upgrade --install $RELEASE_NAME iac/helm/azure-vote \
  --namespace $NAMESPACE \
  --create-namespace \
  --set frontend.image.repository=$REGISTRY/$REPO_OWNER/$IMAGE_NAME \
  --set frontend.image.tag=$IMAGE_TAG \
  --set frontend.image.pullPolicy=Always \
  --set service.frontend.type=NodePort \
  --set service.frontend.nodePort=30080 \
  --wait --timeout 300s

echo ">>> Verificando deployment..."
kubectl get all -n $NAMESPACE

echo ">>> Obtendo informações de acesso..."
NODE_IP="35.228.210.46"
NODE_PORT="30080"

echo "=========================================="
echo "  DEPLOY CONCLUÍDO!"
echo "=========================================="
echo "Aplicação disponível em: http://$NODE_IP:$NODE_PORT"
echo "=========================================="

echo ">>> Testando acesso..."
sleep 5
curl -I http://$NODE_IP:$NODE_PORT || echo "Aguardando aplicação iniciar..."

echo "=========================================="
echo "  Instruções para monitoramento:"
echo "=========================================="
echo "Ver pods: kubectl get pods -n $NAMESPACE"
echo "Ver logs: kubectl logs -n $NAMESPACE -l app=azure-vote-front"
echo "Ver serviço: kubectl get svc -n $NAMESPACE"
echo "=========================================="