#!/bin/bash
# SCRIPT ÚNICO - CONFIGURA CRON E EXECUTA AUTOMATICAMENTE
# Execute este ÚNICO comando no Console SSH para automatizar tudo

set -e

echo "=========================================="
echo "  CONFIGURANDO DEPLOY AUTOMÁTICO"
echo "=========================================="

# Atualizar repositório
cd ~/unyleya_projeto_cicd_Icaro_Galvao || (cd ~ && git clone https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao.git && cd unyleya_projeto_cicd_Icaro_Galvao)
git pull

# Dar permissão e configurar CRON
chmod +x scripts/setup-cron-job.sh
./scripts/setup-cron-job.sh

echo "=========================================="
echo "  CONFIGURAÇÃO CONCLUÍDA!"
echo "=========================================="
echo "O deploy será executado automaticamente em até 5 minutos"
echo "Monitore o progresso: tail -f /tmp/deploy.log"
echo "=========================================="