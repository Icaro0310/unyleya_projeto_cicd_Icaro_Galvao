#!/bin/bash
# Script para reiniciar VM via HTTP API direta
# Não requer gcloud SDK, apenas curl

set -e

echo "=========================================="
echo "  DEPLOY VIA HTTP API - GOOGLE CLOUD"
echo "=========================================="

# Precisamos do Project ID e OAuth Token
echo ">>> Este script requer:"
echo "1. Google Cloud Project ID"
echo "2. OAuth Token (gcloud auth print-access-token)"
echo ""
echo ">>> Obtendo informações..."
echo "Project ID é necessário para continuar"
echo ""
echo "Para reiniciar a VM manualmente:"
echo "1. Acesse: https://console.cloud.google.com/compute/instances"
echo "2. Encontre: unyleya-k8s"
echo "3. Clique: Reiniciar (Reset)"
echo ""
echo "Para automação completa via API:"
echo "1. Obtenha OAuth Token: gcloud auth print-access-token"
echo "2. Execute com: PROJECT_ID=<seu_id> TOKEN=<seu_token> bash deploy-via-http.sh"
echo "=========================================="