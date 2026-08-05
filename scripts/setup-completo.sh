#!/bin/bash
# Script de setup completo para executar via Google Cloud Console
# Abra: https://console.cloud.google.com/compute/instances
# Clique na VM unyleya-k8s -> SSH -> abrir no navegador
# Cole este script e execute

set -e

echo "=========================================="
echo "  SETUP COMPLETO AZURE VOTING APP"
echo "  VM: unyleya-k8s (35.228.210.46)"
echo "=========================================="

# 1. Clonar repositório
echo ">>> Clonando repositório..."
cd ~
if [ -d "unyleya_projeto_cicd_Icaro_Galvao" ]; then
  cd unyleya_projeto_cicd_Icaro_Galvao
  git pull
else
  git clone https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao.git
  cd unyleya_projeto_cicd_Icaro_Galvao
fi

# 2. Dar permissão aos scripts
echo ">>> Configurando permissões..."
chmod +x scripts/*.sh

# 3. Executar setup do Kubernetes
echo ">>> Executando setup do Kubernetes..."
./scripts/setup-vm-k8s.sh

# 4. Aguardar Kubernetes estar pronto
echo ">>> Aguardando Kubernetes estar pronto..."
sleep 20
kubectl get nodes

# 5. Fazer deploy da aplicação
echo ">>> Fazendo deploy da aplicação..."
./scripts/deploy-app.sh

# 6. Exibir kubeconfig em base64 para copiar
echo "=========================================="
echo "  KUBECONFIG PARA GITHUB"
echo "=========================================="
echo "Copie este texto e adicione como secret KUBECONFIG_VM no GitHub:"
echo ""
cat ~/.kube/config | base64 -w 0
echo ""
echo "=========================================="

# 7. Testar acesso
echo ">>> Testando acesso à aplicação..."
sleep 10
curl -I http://35.228.210.46:30080 || echo "Aplicação iniciando, aguarde alguns minutos"

echo "=========================================="
echo "  SETUP CONCLUÍDO!"
echo "=========================================="
echo "Aplicação disponível em: http://35.228.210.46:30080"
echo "=========================================="
echo "Próximos passos:"
echo "1. Copie o kubeconfig acima e adicione no GitHub (secret: KUBECONFIG_VM)"
echo "2. Configure o pipeline CD-deploy-vm.yml no GitHub Actions"
echo "3. Acompanhe o deploy automático"
echo "=========================================="