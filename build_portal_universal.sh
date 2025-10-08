#!/usr/bin/env bash
# =============================================
# StabMasterArson Enhancement Portal - Universal Build Script
# =============================================

echo "🧩 StabMasterArson Enhancement Portal - Universal Build Started"

if command -v node >/dev/null 2>&1; then
  echo "🟢 Node.js detected — running Node builder..."
  node build_portal.js "$@"
elif command -v pwsh >/dev/null 2>&1; then
  echo "🟣 PowerShell Core detected — running PowerShell builder..."
  pwsh ./build_portal.ps1 "$@"
elif command -v powershell >/dev/null 2>&1; then
  echo "🟣 Windows PowerShell detected — running PowerShell builder..."
  powershell -ExecutionPolicy Bypass -File ./build_portal.ps1 "$@"
else
  echo "❌ Neither Node.js nor PowerShell found. Please install one."
  exit 1
fi

