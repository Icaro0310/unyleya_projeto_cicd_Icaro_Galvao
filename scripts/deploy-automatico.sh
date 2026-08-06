#!/bin/bash
# SCRIPT AUTOMÁTICO - EXECUTA VIA CRON OU MANUALMENTE
# Solução completa que assume todos os passos automaticamente

set -e

echo "=========================================="
echo "  DEPLOY AUTOMÁTICO - VM GOOGLE CLOUD"
echo "=========================================="

# Atualizar repositório
cd ~/unyleya_projeto_cicd_Icaro_Galvao || cd ~ && git clone https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao.git && cd unyleya_projeto_cicd_Icaro_Galvao
git pull

# Dar permissão e executar script de emergência
chmod +x scripts/emergencia-deploy.sh
./scripts/emergencia-deploy.sh

echo "=========================================="
echo "  PROCESSO AUTOMÁTICO CONCLUÍDO"
echo "=========================================="