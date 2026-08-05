# PRÓXIMOS PASSOS - MIGRAÇÃO VM GOOGLE CLOUD

## ✅ O QUE JÁ FOI FEITO

1. **Scripts de setup criados** (pasta `scripts/`)
   - `setup-vm-k8s.sh` - Instala Kubernetes k3s + Helm na VM
   - `deploy-app.sh` - Deploy da aplicação
   - `setup-newrelic.sh` - Configura monitoramento

2. **Helm Chart adaptado**
   - `values-prod.yaml` - Configurações para VM Google Cloud
   - Atualizado `values.yaml` para usar ghcr.io

3. **Pipeline CD criado**
   - `cd-deploy-vm.yml` - Deploy automático via GitHub Actions

4. **Documentação criada**
   - `MIGRACAO_VM.md` - Instruções completas passo a passo
   - `scripts/README.md` - Documentação dos scripts

5. **Código enviado para GitHub**
   - Commit realizado e push com sucesso

---

## 📋 PRÓXIMOS PASSOS (MÉTODO MAIS SIMPLES)

### MÉTODO RECOMENDADO: VIA GOOGLE CLOUD CONSOLE (NO NAVEGADOR)

Não precisa instalar nada no seu PC!

**1. Abrir Console do Google Cloud**
- Acesse: https://console.cloud.google.com/compute/instances
- Encontre a VM: unyleya-k8s
- Clique no botão "SSH" (abre terminal no navegador)

**2. Executar setup completo**
```bash
cd ~
git clone https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao.git
cd unyleya_projeto_cicd_Icaro_Galvao
chmod +x scripts/*.sh
./scripts/setup-completo.sh
```

**3. Copiar kubeconfig para GitHub**
- O script vai exibir o kubeconfig em base64
- No GitHub: Settings → Secrets → Actions → New secret
- Nome: `KUBECONFIG_VM`
- Valor: cole o base64

**4. Testar acesso**
Acesse: http://35.228.210.46:30080

---

### MÉTODO ALTERNATIVO: VIA gcloud CLI

Se preferir usar o terminal local:

```bash
gcloud compute ssh unyleya-k8s --zone=europe-north1-c
```

Depois siga os passos do script `setup-completo.sh` ou execute manualmente conforme `MIGRACAO_VM.md`

---

## 📄 ARQUIVOS IMPORTANTES

- `MIGRACAO_VM.md` - Documentação completa com troubleshooting
- `scripts/setup-vm-k8s.sh` - Script de setup principal
- `scripts/deploy-app.sh` - Script de deploy
- `iac/helm/azure-vote/values-prod.yaml` - Configurações produção
- `.github/workflows/cd-deploy-vm.yml` - Pipeline CD

---

## 🎯 OBJETIVO

Após completar os passos acima, o professor poderá acessar:
- ✅ Aplicação: http://35.228.210.46:30080
- ✅ Código: GitHub
- ✅ Pipelines: GitHub Actions
- ✅ Monitoramento: New Relic (se configurado)

---

## ❓ DÚVIDAS

Veja `MIGRACAO_VM.md` para instruções detalhadas e troubleshooting.