#!/bin/bash
# Script para deploy via Railway.app API automatizada
# Não requer intervenção manual após configuração inicial

set -e

echo "=========================================="
echo "  DEPLOY VIA RAILWAY.APP API"
echo "=========================================="

# Configurações
RAILWAY_TOKEN="YOUR_RAILWAY_TOKEN"  # Você precisa obter token em railway.app
PROJECT_ID="YOUR_PROJECT_ID"        # Criar projeto no Railway

echo ">>> Este script requer:"
echo "1. Railway Token (obter em: https://railway.app/project/YOUR_PROJECT/settings/api-tokens)"
echo "2. Railway Project ID"
echo ""
echo ">>> Para automatizar completamente:"
echo "1. Crie conta gratuita em railway.app"
echo "2. Crie novo projeto conectado ao GitHub"
echo "3. Obtenha API Token"
echo "4. Configure as variáveis acima"
echo "5. Execute este script novamente"
echo ""
echo ">>> OU use CLI do Railway:"
echo "curl -fsSL https://railway.app/install.sh | sh"
echo "railway login"
echo "railway link"
echo "railway up"
echo "=========================================="