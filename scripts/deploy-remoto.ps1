# PowerShell Script para Deploy Remoto via Google Cloud
# Tenta múltiplas abordagens para reiniciar a VM

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  DEPLOY REMOTO - GOOGLE CLOUD" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

$VM_NAME = "unyleya-k8s"
$ZONE = "europe-north1-c"
$PROJECT_ID = "unyleya-cicd"  # Ajuste se necessário

# Tentativa 1: Verificar se gcloud está instalado
Write-Host ">>> Verificando gcloud CLI..." -ForegroundColor Yellow
try {
    $gcloudVersion = gcloud --version 2>$null
    if ($gcloudVersion) {
        Write-Host "✅ gcloud encontrado: $gcloudVersion" -ForegroundColor Green
        
        # Tentar usar gcloud
        Write-Host ">>> Tentando reiniciar VM via gcloud..." -ForegroundColor Yellow
        gcloud compute instances reset $VM_NAME --zone=$ZONE --project=$PROJECT_ID
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ VM reiniciada com sucesso!" -ForegroundColor Green
            Write-Host ">>> O CRON job executará automaticamente após o reinício" -ForegroundColor Yellow
            exit 0
        } else {
            Write-Host "❌ Erro ao reiniciar via gcloud" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "❌ gcloud não encontrado" -ForegroundColor Red
}

# Tentativa 2: Abrir Console Google Cloud
Write-Host ">>> Abrindo Console Google Cloud..." -ForegroundColor Yellow
$consoleUrl = "https://console.cloud.google.com/compute/instances?project=$PROJECT_ID"
Write-Host "URL: $consoleUrl" -ForegroundColor Cyan

try {
    Start-Process $consoleUrl
    Write-Host "✅ Console aberto no navegador" -ForegroundColor Green
} catch {
    Write-Host "❌ Não foi possível abrir navegador automaticamente" -ForegroundColor Red
    Write-Host "Abra manualmente: $consoleUrl" -ForegroundColor Yellow
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  INSTRUÇÕES MANUAIS" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "1. No Console que abriu, encontre a VM: $VM_NAME" -ForegroundColor White
Write-Host "2. Clique no botão 'Reiniciar' (Reset)" -ForegroundColor White
Write-Host "3. Aguarde o reinício completar" -ForegroundColor White
Write-Host "4. O CRON job executará automaticamente" -ForegroundColor White
Write-Host "==========================================" -ForegroundColor Cyan