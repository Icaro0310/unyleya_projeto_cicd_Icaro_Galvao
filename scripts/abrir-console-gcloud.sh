#!/bin/bash
# Script para abrir automaticamente o Console Google Cloud na página correta
# Funciona em Windows, Linux e macOS

echo "=========================================="
echo "  ABRINDO CONSOLE GOOGLE CLOUD"
echo "=========================================="

# URL direta para a página da VM
CONSOLE_URL="https://console.cloud.google.com/compute/instances?project=unyleya-cicd"

echo ">>> Abrindo navegador no Console Google Cloud..."
echo ">>> URL: $CONSOLE_URL"
echo ""
echo ">>> Instruções:"
echo "1. Encontre a VM: unyleya-k8s"
echo "2. Clique no botão 'Reiniciar' (Reset)"
echo "3. Aguarde reiniciar"
echo "4. O CRON job executará automaticamente"
echo "=========================================="

# Detectar sistema operacional e abrir navegador
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command -v xdg-open > /dev/null; then
        xdg-open "$CONSOLE_URL"
    elif command -v google-chrome > /dev/null; then
        google-chrome "$CONSOLE_URL"
    else
        echo "Navegador não encontrado. Abra manualmente: $CONSOLE_URL"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open "$CONSOLE_URL"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows
    start "$CONSOLE_URL"
else
    echo "Sistema não suportado. Abra manualmente: $CONSOLE_URL"
fi

echo "=========================================="