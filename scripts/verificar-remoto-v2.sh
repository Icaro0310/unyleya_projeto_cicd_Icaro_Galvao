#!/bin/bash
# Script de verificação remota simplificado - apenas HTTP

set -e

echo "=========================================="
echo "  VERIFICAÇÃO REMOTA - HTTP"
echo "=========================================="

VM_IP="35.228.210.46"
VM_PORT="30080"

echo ">>> Testando acesso HTTP direto..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$VM_IP:$VM_PORT --max-time 10 --connect-timeout 5 2>/dev/null || echo "000")

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ SUCESSO! Aplicação respondendo HTTP 200"
    echo "🌐 Acessível em: http://$VM_IP:$VM_PORT"
    echo ""
    echo ">>> Testando conteúdo..."
    CONTENT=$(curl -s http://$VM_IP:$VM_PORT --max-time 10 2>/dev/null | head -20)
    echo "$CONTENT"
    exit 0
elif [ "$HTTP_STATUS" = "000" ]; then
    echo "❌ TIMEOUT - Não foi possível conectar"
    echo "Possíveis causas:"
    echo "- Aplicação não está rodando"
    echo "- Firewall bloqueando porta 30080"
    echo "- VM não está acessível"
    exit 1
else
    echo "⚠️  HTTP $HTTP_STATUS - Aplicação respondendo mas não é 200"
    exit 1
fi