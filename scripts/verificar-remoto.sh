#!/bin/bash
# Script de verificação remota - checa se aplicação está rodando
# Executar localmente para verificar status da VM

set -e

echo "=========================================="
echo "  VERIFICAÇÃO REMOTA - VM GOOGLE CLOUD"
echo "=========================================="

VM_IP="35.228.210.46"
VM_PORT="30080"

echo ">>> Verificando conexão com VM..."
ping -c 1 $VM_IP > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ VM está online"
else
    echo "❌ VM está offline"
    exit 1
fi

echo ">>> Verificando porta 30080..."
timeout 5 bash -c "cat < /dev/null > /dev/tcp/$VM_IP/$VM_PORT" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ Porta 30080 está aberta"
else
    echo "❌ Porta 30080 está fechada"
fi

echo ">>> Testando acesso HTTP..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$VM_IP:$VM_PORT --max-time 10)
if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Aplicação respondendo HTTP 200"
    echo "🌐 Acessível em: http://$VM_IP:$VM_PORT"
else
    echo "❌ Aplicação não respondendo (HTTP $HTTP_STATUS ou timeout)"
fi

echo "=========================================="
echo "  VERIFICAÇÃO CONCLUÍDA"
echo "=========================================="