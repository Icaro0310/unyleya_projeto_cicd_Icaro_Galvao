#!/bin/bash
# Script de monitoramento remoto - verifica automaticamente quando app estiver funcionando
# Executar localmente para monitorar progresso

set -e

echo "=========================================="
echo "  MONITORAMENTO REMOTO AUTOMÁTICO"
echo "=========================================="

VM_IP="35.228.210.46"
VM_PORT="30080"
MAX_ATTEMPTS=60  # 10 minutos (60 tentativas de 10 segundos)
ATTEMPT=0

echo ">>> Iniciando monitoramento..."
echo ">>> Verificando a cada 10 segundos"
echo ">>> Máximo de tentativas: $MAX_ATTEMPTS"
echo ""

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT + 1))
    echo ">>> Tentativa $ATTEMPT/$MAX_ATTEMPTS..."
    
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$VM_IP:$VM_PORT --max-time 10 --connect-timeout 5 2>/dev/null || echo "000")
    
    if [ "$HTTP_STATUS" = "200" ]; then
        echo "=========================================="
        echo "  ✅ SUCESSO! APLICAÇÃO FUNCIONANDO!"
        echo "=========================================="
        echo ">>> HTTP Status: 200"
        echo ">>> URL: http://$VM_IP:$VM_PORT"
        echo ">>> Tentativa: $ATTEMPT"
        echo ""
        echo ">>> Testando conteúdo..."
        CONTENT=$(curl -s http://$VM_IP:$VM_PORT --max-time 10 2>/dev/null | head -10)
        echo "$CONTENT"
        echo "=========================================="
        exit 0
    elif [ "$HTTP_STATUS" = "000" ]; then
        echo "⏳ Timeout - aguardando..."
    else
        echo "⚠️  HTTP $HTTP_STATUS - não é 200 ainda"
    fi
    
    sleep 10
done

echo "=========================================="
echo "  ❌ TEMPO LIMITE ATINGIDO"
echo "=========================================="
echo "A aplicação não ficou disponível em 10 minutos"
echo "Verifique manualmente em: http://$VM_IP:$VM_PORT"
echo "=========================================="