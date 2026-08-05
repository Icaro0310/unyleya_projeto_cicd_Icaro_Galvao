# INSTRUÇÕES - EXECUTAR VIA GOOGLE CLOUD CONSOLE

## MÉTODO MAIS SIMPLES (SEM INSTALAR NADA NO SEU PC)

### 1. ABRIR CONSOLE DO GOOGLE CLOUD
Acesse: https://console.cloud.google.com/compute/instances

### 2. ENCONTRAR A VM
- Procure pela VM: unyleya-k8s
- Zona: europe-north1-c
- Status: RUNNING

### 3. ABRIR SSH NO NAVEGADOR
- Clique no botão "SSH" ao lado da VM
- Isso abrirá um terminal diretamente no navegador (sem instalar nada)

### 4. EXECUTAR O SETUP COMPLETO
No terminal que abriu no navegador, cole e execute:

```bash
cd ~
git clone https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao.git
cd unyleya_projeto_cicd_Icaro_Galvao
chmod +x scripts/*.sh
./scripts/setup-completo.sh
```

### 5. COPIAR KUBECONFIG PARA GITHUB
O script vai exibir o kubeconfig em base64. Copie e:
- Vá no GitHub: Settings → Secrets and variables → Actions
- New repository secret
- Name: KUBECONFIG_VM
- Value: cole o base64

### 6. CONFIGURAR PIPELINE NO GITHUB
- Vá em Actions → CD - Deploy VM Google Cloud
- Configure os secrets necessários
- Execute o workflow

### 7. TESTAR ACESSO
Abra no navegador: http://35.228.210.46:30080

---

## VANTAGENS DESTE MÉTODO

✅ Não precisa instalar gcloud SDK no seu PC
✅ Não precisa configurar chaves SSH
✅ Funciona diretamente no navegador
✅ Mais rápido e simples

---

## TEMPO ESTIMADO

- Acesso SSH no navegador: 1 minuto
- Execução do script: 5-10 minutos
- Configuração GitHub: 2 minutos
- Total: ~15 minutos