#!/bin/bash
# Script para executar comandos na VM via Google Cloud Compute API
# Requer: GOOGLE_CLOUD_PROJECT e GCP_OAUTH_TOKEN

set -e

echo "=========================================="
echo "  DEPLOY VIA GOOGLE CLOUD API"
echo "=========================================="

# Configurações
PROJECT_ID="unyleya-cicd"  # Substitua pelo seu Project ID
ZONE="europe-north1-c"
INSTANCE_NAME="unyleya-k8s"

# Comando para executar na VM
COMMAND="cd ~/unyleya_projeto_cicd_Icaro_Galvao && git pull && chmod +x scripts/emergencia-total.sh && ./scripts/emergencia-total.sh"

# Codificar comando em base64
ENCODED_COMMAND=$(echo -n "$COMMAND" | base64 -w 0)

echo ">>> Executando comando na VM via API..."
echo "Comando: $COMMAND"

# Executar comando via API (requer token OAuth)
# curl -X POST \
#   "https://compute.googleapis.com/compute/v1/projects/$PROJECT_ID/zones/$ZONE/instances/$INSTANCE_NAME/executeCmd" \
#   -H "Authorization: Bearer $GCP_OAUTH_TOKEN" \
#   -H "Content-Type: application/json" \
#   -d "{\"command\":\"$ENCODED_COMMAND\"}"

echo "=========================================="
echo "  INSTRUÇÕES PARA USAR ESTE SCRIPT"
echo "=========================================="
echo "1. Obter OAuth Token:"
echo "   gcloud auth print-access-token"
echo ""
echo "2. Definir variáveis:"
echo "   export GCP_OAUTH_TOKEN=<seu_token>"
echo "   export GOOGLE_CLOUD_PROJECT=<seu_project_id>"
echo ""
echo "3. Executar script"
echo "=========================================="