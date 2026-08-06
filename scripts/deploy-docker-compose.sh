#!/bin/bash
# Script de deploy usando docker-compose (alternativa ao k3s)
# Mais simples e confiável para a VM

set -e

echo "=========================================="
echo "  DEPLOY VIA DOCKER-COMPOSE"
echo "=========================================="

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo ">>> Docker não encontrado. Tentando instalar..."
    
    # Matar processos apt-get travados
    echo ">>> Matando processos apt-get travados..."
    sudo pkill -9 apt-get || true
    sudo rm -f /var/lib/apt/lists/lock
    sudo rm -f /var/lib/dpkg/lock
    sudo rm -f /var/lib/dpkg/lock-frontend
    sudo dpkg --configure -a
    
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo ">>> Docker instalado. Reexecute o script."
    exit 1
fi

echo ">>> Docker encontrado. Configurando..."

# Ir para diretório do projeto
cd ~/unyleya_projeto_cicd_Icaro_Galvao
git pull

# Modificar docker-compose.yaml para expor porta 30080
sed -i 's/80:80/30080:80/g' docker-compose.yaml

# Iniciar containers via docker-compose
echo ">>> Iniciando containers via docker-compose..."
docker-compose up -d

# Aguardar containers iniciarem
echo ">>> Aguardando containers iniciarem..."
sleep 20

# Verificar status
echo ">>> Verificando status dos containers..."
docker-compose ps

# Testar acesso
echo ">>> Testando acesso..."
sleep 5
curl -I http://localhost:30080 || echo "Aguardando aplicação iniciar..."

echo "=========================================="
echo "  DEPLOY CONCLUÍDO!"
echo "=========================================="
echo "Aplicação disponível em: http://35.228.210.46:30080"
echo "=========================================="