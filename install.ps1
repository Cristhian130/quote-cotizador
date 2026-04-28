# Script de instalación inteligente para Quote (Importadoras Asociadas)
$ErrorActionPreference = "Stop"

try {
    Set-Location -Path $PSScriptRoot
    Write-Host "--- Preparando Instalación de Quote ---" -ForegroundColor Cyan

    # 1. Verificar si el certificado ya es de confianza
    $thumbprint = (Get-PfxCertificate -FilePath "certificate.cer" -ErrorAction SilentlyContinue).Thumbprint
    $isTrusted = Get-ChildItem -Path Cert:\LocalMachine\Root | Where-Object { $_.Thumbprint -eq $thumbprint }

    if (-not $isTrusted) {
        # Necesitamos elevar para instalar el certificado
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Host "Instalando certificado de confianza (Se requieren permisos)..." -ForegroundColor Yellow
            
            # Script temporal para solo el certificado
            $certScript = "Import-Certificate -FilePath '$PSScriptRoot\certificate.cer' -CertStoreLocation 'Cert:\LocalMachine\TrustedPeople'; Import-Certificate -FilePath '$PSScriptRoot\certificate.cer' -CertStoreLocation 'Cert:\LocalMachine\Root'"
            Start-Process powershell -ArgumentList "-NoProfile -Command $certScript" -Verb RunAs -Wait
            Write-Host "Certificado instalado." -ForegroundColor Green
        }
    }

    # 2. Buscar el archivo .msix
    $msixFile = Get-ChildItem -Filter "quote*.msix" | Select-Object -First 1
    if (-not $msixFile) { throw "No se encontró el archivo .msix en esta carpeta." }

    # 3. Instalar la app para el usuario ACTUAL (sin elevación necesaria para la app en sí)
    Write-Host "Instalando aplicación para el usuario actual: $($env:USERNAME)..." -ForegroundColor Cyan
    Add-AppxPackage -Path $msixFile.FullName
    Write-Host "¡Instalación completada con éxito!" -ForegroundColor Green
    Write-Host "Ya puedes buscar 'Quote' en tu menú de inicio." -ForegroundColor White

} catch {
    Write-Host "`n[ERROR] $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nProceso finalizado." -ForegroundColor Cyan
Read-Host "Presione Entrar para cerrar..."
