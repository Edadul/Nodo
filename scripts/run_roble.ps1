# Lee .env local (gitignored) y lanza Flutter con --dart-define.
# Uso: .\scripts\run_roble.ps1 [-Device chrome]

param(
  [string]$Device = 'chrome',
  [string[]]$ExtraArgs = @()
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$envFile = Join-Path $root '.env'
if (-not (Test-Path $envFile)) {
  Write-Error "No existe .env. Copia .env.example a .env y completa los valores."
}

$defines = @{}
Get-Content $envFile | ForEach-Object {
  $line = $_.Trim()
  if ($line -eq '' -or $line.StartsWith('#')) { return }
  $parts = $line.Split('=', 2)
  if ($parts.Count -ne 2) { return }
  $defines[$parts[0].Trim()] = $parts[1].Trim()
}

foreach ($key in @('BASE_URL', 'CONTRACT_ID', 'GUEST_EMAIL')) {
  if (-not $defines.ContainsKey($key) -or [string]::IsNullOrWhiteSpace($defines[$key])) {
    Write-Error ".env incompleto: falta $key"
  }
}

# GUEST_PASSWORD / AUTO_LOGIN_* son opcionales.
if (-not $defines.ContainsKey('GUEST_PASSWORD')) {
  $defines['GUEST_PASSWORD'] = ''
}

$dartDefines = @()
foreach ($key in $defines.Keys) {
  $value = $defines[$key]
  if ([string]::IsNullOrWhiteSpace($value) -and $key -ne 'GUEST_PASSWORD') {
    continue
  }
  $dartDefines += "--dart-define=$key=$value"
}

$guestHint = if ([string]::IsNullOrWhiteSpace($defines['GUEST_PASSWORD'])) {
  'sin clave (anonimo)'
} else {
  'con guest password'
}

Write-Host "Contrato: $($defines['CONTRACT_ID']) | Guest: $($defines['GUEST_EMAIL']) ($guestHint)"
Write-Host "Device: $Device"
flutter run -d $Device @dartDefines @ExtraArgs
