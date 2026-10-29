# =====================================================================
# ejecutar_todo.ps1
# Reconstruye la base desde cero: migraciones en orden + semilla.
# NO contiene credenciales. La conexión se toma de las variables de
# entorno estándar de PostgreSQL (PGHOST, PGPORT, PGUSER) y la contraseña
# del archivo %APPDATA%\postgresql\pgpass.conf de cada integrante.
#
# Uso:  .\ejecutar_todo.ps1            (base por defecto: biblioteca)
#       .\ejecutar_todo.ps1 -Base otra
# =====================================================================
param([string]$Base = "biblioteca")

$ErrorActionPreference = "Stop"
$env:PGCLIENTENCODING = "UTF8"

psql -X -d postgres -c "DROP DATABASE IF EXISTS $Base;" -c "CREATE DATABASE $Base;"

$scripts = @(Get-ChildItem "$PSScriptRoot\migraciones\*.sql" | Sort-Object Name) +
           @(Get-Item "$PSScriptRoot\datos\semilla.sql")

foreach ($s in $scripts) {
    Write-Host "== $($s.Name)"
    psql -X -d $Base -v ON_ERROR_STOP=1 -q -f $s.FullName
    if ($LASTEXITCODE -ne 0) { throw "Falló $($s.Name)" }
}
Write-Host "Base '$Base' reconstruida."
