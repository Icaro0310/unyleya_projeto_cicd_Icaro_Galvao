#!/bin/bash
# Deploy simples - Python Flask direto sem Kubernetes/Docker
# Solução mais rápida e confiável

set -e

echo "=========================================="
echo "  DEPLOY SIMPLES - PYTHON FLASK"
echo "=========================================="

cd ~/unyleya_projeto_cicd_Icaro_Galvao
git pull

cd azure-vote

# Instalar dependências Python
echo ">>> Instalando dependências Python..."
pip3 install flask redis -q

# Modificar para rodar em todas as interfaces (0.0.0.0)
echo ">>> Configurando aplicação..."
sed -i 's/app.run(host=.0.0.0./app.run(host="0.0.0.0", port=30080)/g' azure-vote/main.py

# Executar em background
echo ">>> Iniciando aplicação Python Flask..."
nohup python3 azure-vote/main.py > /tmp/app.log 2>&1 &

echo ">>> Aguardando aplicação iniciar..."
sleep 10

# Verificar se está rodando
if pgrep -f "python3.*main.py" > /dev/null; then
    echo "✅ Aplicação Python rodando!"
    echo "🌐 Logs: tail -f /tmp/app.log"
    echo "🌐 Acessível em: http://35.228.210.46:30080"
else
    echo "❌ Falha ao iniciar aplicação"
    cat /tmp/app.log
fi

echo "=========================================="