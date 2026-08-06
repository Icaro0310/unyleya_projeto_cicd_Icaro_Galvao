# INSTRUÇÕES - REINÍCIO AUTOMÁTICO DA VM

## OPÇÃO 1: REINÍCIO VIA CONSOLE GOOGLE CLOUD (RECOMENDADO)

1. Acesse: https://console.cloud.google.com/compute/instances
2. Encontre a VM: unyleya-k8s
3. Clique no botão "Reiniciar" (Reset)
4. Após reiniciar, o CRON job executará automaticamente

## OPÇÃO 2: STOP/START DA VM

1. Acesse: https://console.cloud.google.com/compute/instances
2. Pare a VM: clique em "Parar"
3. Aguarde parar completamente
4. Inicie a VM: clique em "Iniciar"
5. O CRON job executará automaticamente no boot

## OPÇÃO 3: REINSTALAÇÃO LIMPA

Se as opções acima não funcionarem:

1. Acesse: https://console.cloud.google.com/compute/instances
2. Clique na VM unyleya-k8s
3. Clique em "Excluir"
4. Crie uma nova VM com as mesmas configurações
5. Execute o setup inicial

## MONITORAMENTO

Após reiniciar, monitore o progresso no Console SSH:
```bash
tail -f /tmp/deploy.log
```

Ou verifique o status remotamente:
```bash
curl http://35.228.210.46:30080
```