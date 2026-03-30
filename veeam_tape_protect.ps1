#requires -Version 7.0
<#
.SYNOPSIS
    Automates tape software protection and unprotection in a Veeam media pool.

.DESCRIPTION
    This script protects eligible tapes that match the configured media set
    pattern and removes software protection from tapes that are already expired.

.PARAMETER DaysToProtect
    Number of days used to calculate the protection threshold.

.PARAMETER MediaSetPattern
    Pattern used to filter tapes by MediaSet.

.PARAMETER WritePoolName
    Name of the media pool that will be processed.

.PARAMETER LogPath
    Path to the execution log file.

.EXAMPLE
    pwsh.exe -File .\veeam_tape_protect.ps1

.EXAMPLE
    pwsh.exe -File .\veeam_tape_protect.ps1 -DaysToProtect 7 -MediaSetPattern "*Daily*" -WritePoolName "GFS-Pool"

.NOTES
    Version      : 2.0.0
    Requirements : PowerShell 7+, Veeam Backup & Replication v13 recommended
#>

[CmdletBinding()]
param(
    [int]$DaysToProtect = 7,
    [string]$MediaSetPattern = "*Daily*",
    [string]$WritePoolName = "GFS-Pool",
    [string]$LogPath = "C:\Temp\tape_protect.log"
)

$ErrorActionPreference = "Stop"

function Initialize-Log {
    $folder = Split-Path -Path $LogPath -Parent
    if ($folder -and -not (Test-Path $folder)) {
        New-Item -Path $folder -ItemType Directory -Force | Out-Null
    }

    if (Test-Path $LogPath) {
        Remove-Item -Path $LogPath -Force
    }

    New-Item -Path $LogPath -ItemType File -Force | Out-Null
}

function Write-Log {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("INFO","SUCCESS","WARNING","ERROR")]
        [string]$Level = "INFO"
    )

    $line = "{0} [{1}] {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Level, $Message
    Write-Host $line
    Add-Content -Path $LogPath -Value $line
}

try {
    Initialize-Log
    Write-Log "===== START PROTECTION CYCLE ====="

    Import-Module Veeam.Backup.PowerShell -ErrorAction Stop
    Write-Log "Veeam.Backup.PowerShell module loaded." "SUCCESS"

    $limitDate = (Get-Date).AddDays(-$DaysToProtect)
    Write-Log "Protection threshold date: $limitDate"
    Write-Log "Media pool: $WritePoolName"
    Write-Log "Media set pattern: $MediaSetPattern"

    $tapesToProtect = Get-VBRTapeMedium -MediaPool $WritePoolName | Where-Object {
        $_.MediaSet -like $MediaSetPattern -and
        $_.LastWriteTime -ne $null -and
        $_.LastWriteTime -ge $limitDate -and
        $_.ProtectedBySoftware -eq $false -and
        $_.IsLocked -eq $false
    }

    if (-not $tapesToProtect) {
        Write-Log "No tapes are currently eligible for protection."
    }
    else {
        Write-Log "Tapes eligible for protection: $($tapesToProtect.Count)"
        foreach ($tape in $tapesToProtect) {
            try {
                Enable-VBRTapeProtection -Medium $tape
                Write-Log "Tape '$($tape.Name)' protected." "SUCCESS"
            }
            catch {
                Write-Log "Failed to protect tape '$($tape.Name)': $($_.Exception.Message)" "ERROR"
            }
        }
    }

    Write-Log "===== CHECKING EXPIRED PROTECTED TAPES ====="

    $protectedTapes = Get-VBRTapeMedium -MediaPool $WritePoolName | Where-Object {
        $_.ProtectedBySoftware -eq $true -and
        $_.IsExpired -eq $true
    }

    if (-not $protectedTapes) {
        Write-Log "No expired protected tapes were found."
    }
    else {
        Write-Log "Expired protected tapes found: $($protectedTapes.Count)"
        foreach ($tape in $protectedTapes) {
            try {
                Disable-VBRTapeProtection -Medium $tape
                Write-Log "Protection removed from tape '$($tape.Name)'." "SUCCESS"
            }
            catch {
                Write-Log "Failed to remove protection from tape '$($tape.Name)': $($_.Exception.Message)" "ERROR"
            }
        }
    }

    Write-Log "===== END CYCLE ====="
    exit 0
}
catch {
    Write-Log $_.Exception.Message "ERROR"
    exit 1
}
