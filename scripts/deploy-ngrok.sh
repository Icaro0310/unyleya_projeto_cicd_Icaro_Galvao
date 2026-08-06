#!/bin/bash
# Script para deploy via ngrok - expor localhost para internet
# Requer ngrok instalado na VM ou no seu PC

set -e

echo "=========================================="
echo "  DEPLOY VIA NGROK - LOCAL TO INTERNET"
echo "=========================================="

echo ">>> Esta solução:"
echo "1. Roda aplicação localmente (no seu PC)"
echo "2. Usa ngrok para expor para internet"
echo "3. Professor acessa via URL pública do ngrok"
echo ""
echo ">>> Pré-requisitos:"
echo "- kind cluster rodando em localhost:30080 (já está funcionando)"
echo "- ngrok instalado (ou conta ngrok gratuita)"
echo ""
echo ">>> Para usar:"
echo "1. No seu PC (não na VM):"
echo "   ngrok http 30080"
echo "2. Compartilhe a URL gerada com o professor"
echo "=========================================="