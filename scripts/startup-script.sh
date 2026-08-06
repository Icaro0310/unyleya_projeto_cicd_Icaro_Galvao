#!/bin/bash
# Startup Script para VM Google Cloud
# Este script pode ser configurado via Instance Metadata
# ou via Console do Google Cloud para executar automaticamente no boot

set -e

echo "=========================================="
echo "  STARTUP SCRIPT - VM GOOGLE CLOUD"
echo "=========================================="

# Esperar sistema estar pronto
sleep 30

# Atualizar repositório
cd ~/unyleya_projeto_cicd_Icaro_Galvao || (cd ~ && git clone https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao.git && cd unyleya_projeto_cicd_Icaro_Galvao)
git pull

# Executar script de emergência total
chmod +x scripts/emergencia-total.sh
./scripts/emergencia-total.sh

# Verificar se aplicação está rodando
if curl -s http://localhost:30080 > /dev/null 2>&1; then
    echo "=========================================="
    echo "  APLICAÇÃO RODANDO COM SUCESSO!"
    echo "=========================================="
    echo "Acessível em: http://35.228.210.46:30080"
    echo "=========================================="
else
    echo "=========================================="
    echo "  FALHA NO DEPLOY - TENTANDO NOVAMENTE"
    echo "=========================================="
    # Aguardar e tentar novamente
    sleep 60
    ./scripts/emergencia-total.sh
fi

echo "=========================================="
echo "  STARTUP SCRIPT CONCLUÍDO"
echo "=========================================="