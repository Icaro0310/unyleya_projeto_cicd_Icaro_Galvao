#!/bin/bash
# Script de setup do New Relic na VM Google Cloud
# Para monitoramento do cluster k3s

set -e

echo "=========================================="
echo "  SETUP NEW RELIC MONITORING"
echo "=========================================="

# Verificar se já tem New Relic instalado
if helm list -n newrelic 2>/dev/null | grep -q nri-bundle; then
  echo "New Relic já está instalado. Atualizando..."
  helm upgrade newrelic newrelic/nri-bundle \
    --namespace newrelic \
    --reuse-values
else
  echo ">>> Instalando New Relic via Helm..."
  
  # Adicionar repositório do New Relic
  helm repo add newrelic https://helm-charts.newrelic.com
  helm repo update
  
  # Solicitar a LICENSE KEY do New Relic
  echo ">>> Preciso da New Relic License Key"
  echo "Você pode obter em: https://one.newrelic.com/launcher/nerdpacks.launcher"
  echo "Vá em: Account settings -> API Keys -> License Key"
  echo ""
  read -p "Cole sua New Relic License Key: " NR_LICENSE_KEY
  
  if [ -z "$NR_LICENSE_KEY" ]; then
    echo "ERRO: License Key não fornecida"
    exit 1
  fi
  
  # Instalar New Relic
  helm install newrelic newrelic/nri-bundle \
    --set global.licenseKey=$NR_LICENSE_KEY \
    --set global.cluster=unyleya-k8s-vm \
    --namespace newrelic \
    --create-namespace
  
  echo ">>> Aguardando pods do New Relic iniciarem..."
  sleep 30
fi

# Verificar pods do New Relic
echo ">>> Verificando pods do New Relic..."
kubectl get pods -n newrelic

echo "=========================================="
echo "  NEW RELIC CONFIGURADO!"
echo "=========================================="
echo "Namespace: newrelic"
echo "Cluster: unyleya-k8s-vm"
echo "=========================================="
echo "Acesse: https://one.newrelic.com"
echo "=========================================="