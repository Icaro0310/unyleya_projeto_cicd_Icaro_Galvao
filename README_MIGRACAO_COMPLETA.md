# MIGRAÇÃO COMPLETA - KIND LOCAL → VM GOOGLE CLOUD

## RESUMO DA MIGRAÇÃO

Este documento descreve o processo completo de migração da aplicação Azure Voting App do cluster kind local para a VM Google Cloud (unyleya-k8s, IP: 35.228.210.46), permitindo acesso público para o professor.

---

## STATUS FINAL ESPERADO

### ✅ CONCLUÍDO
- [x] Scripts de setup criados (setup-vm-k8s.sh, deploy-app.sh, setup-newrelic.sh)
- [x] Helm Chart adaptado para produção (values-prod.yaml)
- [x] Pipeline CD para VM criado (cd-deploy-vm.yml)
- [x] Documentação completa (MIGRACAO_VM.md, INSTRUCAO_CONSOLE_CLOUD.md)
- [x] Chaves SSH geradas e configuradas
- [x] k3s instalado na VM (v1.36.3)
- [x] Helm instalado na VM (v3.21.3)
- [x] Firewall configurado (portas 30080, 6443, 10250)
- [x] Namespace azure-vote criado
- [x] Todo o código enviado para GitHub

### 🔄 EM ANDAMENTO
- [ ] Deploy da aplicação via Helm na VM
- [ ] Configuração do kubeconfig para GitHub Actions
- [ ] Teste de acesso público (http://35.228.210.46:30080)
- [ ] Configuração do New Relic (opcional)

---

## ESTRUTURA DE ARQUIVOS CRIADA

### Scripts (scripts/)
```
scripts/
├── setup-vm-k8s.sh           # Setup inicial Kubernetes + Helm
├── setup-completo.sh         # Setup completo em um script
├── continuar-setup.sh        # Continuar setup após k3s instalado
├── deploy-app.sh             # Deploy da aplicação
├── setup-newrelic.sh         # Configuração New Relic
├── README.md                 # Documentação dos scripts
└── INSTRUCAO_CONSOLE_CLOUD.md # Instruções via navegador
```

### Configurações Kubernetes
```
iac/helm/azure-vote/
├── Chart.yaml                # Metadados do chart
├── values.yaml               # Configurações padrão (atualizado para ghcr.io)
└── values-prod.yaml          # Configurações produção VM
```

### Pipelines CI/CD
```
.github/workflows/
├── ci-build.yml              # Pipeline CI (build + push)
├── cd-deploy.yml             # Pipeline CD original (kind)
└── cd-deploy-vm.yml          # Pipeline CD para VM Google Cloud
```

### Documentação
```
├── MIGRACAO_VM.md            # Instruções detalhadas migração
├── PROXIMOS_PASSOS.md        # Próximos passos após setup
├── README_MIGRACAO_COMPLETA.md # Este documento
└── README_PROJETO.md         # Atualizado com status VM
```

---

## PROCESSO DE MIGRAÇÃO REALIZADO

### FASE 1: PREPARAÇÃO (CONCLUÍDA ✅)

1. **Análise do ambiente local**
   - Cluster kind rodando em localhost:30080
   - Aplicação funcionando com Cats x Dogs
   - Monitoramento New Relic ativo

2. **Criação de scripts de automação**
   - setup-vm-k8s.sh: Instala k3s + Helm + firewall
   - deploy-app.sh: Deploy via Helm Chart
   - setup-newrelic.sh: Configuração monitoramento

3. **Adaptação do Helm Chart**
   - values.yaml: Atualizado para usar ghcr.io
   - values-prod.yaml: Configurações específicas para VM
   - Ajuste de recursos e portas para produção

4. **Criação de pipeline CD**
   - cd-deploy-vm.yml: Pipeline para deploy automático
   - Configuração para usar kubeconfig da VM
   - Integração com GitHub Actions

### FASE 2: CONFIGURAÇÃO VM (CONCLUÍDA ✅)

1. **Acesso à VM**
   - Via Google Cloud Console (SSH no navegador)
   - Chaves SSH geradas e configuradas
   - Usuário: icarogalvao5

2. **Instalação do Kubernetes**
   - k3s v1.36.3 instalado
   - Cluster funcionando (nó unyleya-k8s Ready)
   - kubectl configurado

3. **Instalação do Helm**
   - Helm v3.21.3 instalado
   - Verificado e funcionando

4. **Configuração de rede**
   - Firewall: portas 30080, 6443, 10250 abertas
   - Namespace azure-vote criado

### FASE 3: DEPLOY (EM ANDAMENTO 🔄)

1. **Configuração do kubeconfig**
   - Arquivo de configuração Kubernetes
   - Necessário para GitHub Actions
   - Pode ser exportado via: `cat ~/.kube/config | base64 -w 0`

2. **Deploy via Helm**
   - Comando pronto: `helm upgrade --install azure-vote iac/helm/azure-vote ...`
   - Configurações NodePort: 30080
   - Imagem: ghcr.io/Icaro0310/azure-vote-front:latest

3. **Verificação**
   - Ver pods: `sudo k3s kubectl get pods -n azure-vote`
   - Ver serviços: `sudo k3s kubectl get svc -n azure-vote`
   - Teste acesso: `curl http://35.228.210.46:30080`

---

## PRÓXIMOS PASSOS PARA CONCLUSÃO

### 1. CONCLUIR DEPLOY MANUAL (NA VM)

Execute estes comandos no Console SSH da VM:

```bash
# Reiniciar k3s se necessário
sudo systemctl restart k3s
sleep 10

# Verificar cluster
sudo k3s kubectl get nodes

# Criar namespace
sudo k3s kubectl create namespace azure-vote

# Criar secret do registry
sudo k3s kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=Icaro0310 \
  --docker-password=SEU_GITHUB_TOKEN \
  --namespace azure-vote

# Deploy via Helm
cd /tmp
rm -rf unyleya_projeto_cicd_Icaro_Galvao
git clone https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao.git
cd unyleya_projeto_cicd_Icaro_Galvao

helm upgrade --install azure-vote iac/helm/azure-vote \
  --namespace azure-vote \
  --create-namespace \
  --set frontend.image.repository=ghcr.io/Icaro0310/azure-vote-front \
  --set frontend.image.tag=latest \
  --set frontend.image.pullPolicy=Always \
  --set service.frontend.type=NodePort \
  --set service.frontend.nodePort=30080 \
  --wait --timeout 300s

# Verificar deploy
sudo k3s kubectl get all -n azure-vote
```

### 2. CONFIGURAR GITHUB ACTIONS (APÓS DEPLOY)

1. **Exportar kubeconfig da VM**
   ```bash
   cat ~/.kube/config | base64 -w 0
   ```

2. **Adicionar secret no GitHub**
   - GitHub → Settings → Secrets → Actions
   - Nome: `KUBECONFIG_VM`
   - Valor: cole o base64 acima

3. **Configurar token GitHub**
   - GitHub → Settings → Developer settings → Personal access tokens
   - Scopes: repo, workflow, read:packages
   - Adicionar como secret: `GITHUB_TOKEN`

### 3. TESTAR ACESSO PÚBLICO

```bash
# De qualquer lugar
curl http://35.228.210.46:30080

# No navegador
http://35.228.210.46:30080
```

### 4. CONFIGURAR NEW RELIC (OPCIONAL)

```bash
cd ~/unyleya_projeto_cicd_Icaro_Galvao
./scripts/setup-newrelic.sh
```

---

## COMPARAÇÃO: LOCAL vs VM

| Aspecto | Kind Local | VM Google Cloud |
|--------|------------|-----------------|
| **Cluster** | kind (Docker) | k3s (Kubernetes nativo) |
| **Acesso** | localhost:30080 | 35.228.210.46:30080 |
| **Registry** | localhost:5000 | ghcr.io |
| **Helm Chart** | values.yaml | values-prod.yaml |
| **Pipeline** | cd-deploy.yml | cd-deploy-vm.yml |
| **Kubeconfig** | KUBECONFIG | KUBECONFIG_VM |
| **Acesso Professor** | ❌ Não acessível | ✅ Acessível publicamente |

---

## VALIDAÇÃO PARA O PROFESSOR

Após conclusão, o professor poderá acessar:

### ✅ ACESSÍVEL PUBLICAMENTE
- **Aplicação:** http://35.228.210.46:30080
- **Código + IaC:** https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao
- **Pipelines CI/CD:** https://github.com/Icaro0310/unyleya_projeto_cicd_Icaro_Galvao/actions
- **Helm Chart:** Disponível no repositório
- **Logs:** GitHub Actions + kubectl na VM

### 📊 MONITORAMENTO (SE CONFIGURADO)
- **New Relic:** https://one.newrelic.com
- **Infraestrutura K8s:** Monitoramento completo
- **Métricas:** Pods, containers, nodes
- **Logs:** Logs da aplicação

---

## SOLUÇÃO DE PROBLEMAS

### k3s timeout na conexão
```bash
sudo systemctl restart k3s
sleep 10
sudo k3s kubectl get nodes
```

### Imagem não pulla do ghcr.io
```bash
# Verificar secret
sudo k3s kubectl get secret ghcr-secret -n azure-vote

# Recriar se necessário
sudo k3s kubectl delete secret ghcr-secret -n azure-vote
sudo k3s kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=Icaro0310 \
  --docker-password=SEU_TOKEN \
  --namespace azure-vote
```

### Porta 30080 não acessível
```bash
# Verificar firewall
sudo ufw status
sudo ufw allow 30080/tcp

# Verificar serviço
sudo k3s kubectl get svc -n azure-vote
```

---

## REFERÊNCIAS

- **Documentação Principal:** `MIGRACAO_VM.md`
- **Instruções Console Cloud:** `scripts/INSTRUCAO_CONSOLE_CLOUD.md`
- **Próximos Passos:** `PROXIMOS_PASSOS.md`
- **Scripts:** `scripts/README.md`

---

## CONCLUSÃO

A migração está quase completa. O ambiente da VM está configurado com Kubernetes e Helm. Restam:

1. Concluir o deploy da aplicação via Helm
2. Configurar o kubeconfig no GitHub Actions
3. Testar o acesso público
4. (Opcional) Configurar New Relic

Após esses passos, o professor terá acesso completo à aplicação rodando na nuvem.