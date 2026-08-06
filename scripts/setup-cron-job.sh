#!/bin/bash
# Script para configurar CRON job que executa deploy automaticamente
# Adiciona ao crontab para executar a cada 5 minutos até o deploy ser bem-sucedido

set -e

echo "=========================================="
echo "  CONFIGURANDO CRON JOB AUTOMÁTICO"
echo "=========================================="

# Criar script que será executado pelo CRON
cat > /tmp/auto-deploy.sh << 'EOF'
#!/bin/bash
cd ~/unyleya_projeto_cicd_Icaro_Galvao
git pull > /tmp/deploy.log 2>&1

# Verificar se aplicação já está rodando
if curl -s http://localhost:30080 > /dev/null 2>&1; then
    echo "Aplicação já está rodando - removendo CRON job"
    crontab -l | grep -v "auto-deploy.sh" | crontab -
    exit 0
fi

# Tentar deploy
chmod +x scripts/emergencia-total.sh
./scripts/emergencia-total.sh >> /tmp/deploy.log 2>&1

# Se deploy foi bem-sucedido, remover CRON job
if curl -s http://localhost:30080 > /dev/null 2>&1; then
    echo "Deploy bem-sucedido - removendo CRON job"
    crontab -l | grep -v "auto-deploy.sh" | crontab -
fi
EOF

chmod +x /tmp/auto-deploy.sh

# Adicionar ao crontab para executar a cada 5 minutos
(crontab -l 2>/dev/null | grep -v "auto-deploy.sh"; echo "*/5 * * * * /tmp/auto-deploy.sh") | crontab -

echo ">>> CRON job configurado!"
echo ">>> O script será executado automaticamente a cada 5 minutos"
echo ">>> Verifique o progresso em: /tmp/deploy.log"
echo ">>> Para ver o log: tail -f /tmp/deploy.log"
echo "=========================================="