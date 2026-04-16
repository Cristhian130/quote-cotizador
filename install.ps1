# Script de Instalación para Quote
# Este script instala el certificado de confianza y luego la aplicación MSIX.

Set-Location -Path $PSScriptRoot

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Solicitando permisos de administrador..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$msixFile = Get-ChildItem -Filter "quote-*-windows.msix" | Select-Object -First 1

if (-not $msixFile) {
    Write-Error "No se encontró el archivo .msix en la carpeta actual."
    pause
    exit
}

Write-Host "Instalando certificado de confianza para: $($msixFile.Name)..." -ForegroundColor Cyan

try {
    $cert = (Get-AuthenticodeSignature -FilePath $msixFile.FullName).SignerCertificate
    if (-not $cert) {
        throw "El archivo no está firmado o no se pudo extraer el certificado."
    }

    $rootStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root", "LocalMachine")
    $rootStore.Open("ReadWrite")
    $rootStore.Add($cert)
    $rootStore.Close()

    $pubStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("TrustedPublisher", "LocalMachine")
    $pubStore.Open("ReadWrite")
    $pubStore.Add($cert)
    $pubStore.Close()

    Write-Host "Certificado instalado correctamente." -ForegroundColor Green
} catch {
    Write-Error "Error al instalar el certificado: $_"
    pause
    exit
}

Write-Host "Instalando aplicación..." -ForegroundColor Cyan
Add-AppxPackage -Path $msixFile.FullName

Write-Host "¡Instalación completada con éxito!" -ForegroundColor Green
pause
