#!/bin/bash
# Script para configurar alertas básicos no New Relic
# Requer New Relic API Key

set -e

echo "=========================================="
echo "  CONFIGURAR ALERTAS NEW RELIC"
echo "=========================================="

echo ">>> Este script requer:"
echo "1. New Relic API Key (User Key)"
echo "2. New Relic Account ID"
echo ""
echo ">>> Para configurar alertas manualmente:"
echo "1. Acesse: https://one.newrelic.com"
echo "2. Vá para: Alerts & AI > Alert conditions"
echo "3. Crie alertas para:"
echo "   - CPU alta (>80%)"
echo "   - Memória alta (>90%)"
echo "   - Pods com CrashLoopBackOff"
echo "   - HTTP error rate (>5%)"
echo "=========================================="