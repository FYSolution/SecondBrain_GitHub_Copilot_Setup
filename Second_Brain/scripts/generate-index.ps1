<#
.SYNOPSIS
    LEGACY — Redirects to compile-wiki.ps1
.DESCRIPTION
    This script is superseded by compile-wiki.ps1 (fragment architecture v2).
    Kept for backward compatibility. Calling this script now runs compile-wiki.ps1.
.EXAMPLE
    .\generate-index.ps1
#>

Write-Host "⚠️  generate-index.ps1 is legacy. Redirecting to compile-wiki.ps1..." -ForegroundColor Yellow
& (Join-Path $PSScriptRoot "compile-wiki.ps1") @args
