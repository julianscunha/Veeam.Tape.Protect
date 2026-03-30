# ===================================================================
# Script: Tape Protect Cycle Automation
# Versão: 2.0 - 01/2026
# Compatibilidade: Veeam Backup & Replication v12.x ou superior
#
# Objetivo:
#  - Proteger fitas GFS contra gravação
#  - Remover proteção de fitas expiradas
#
# Requer: 
#  - Fitas com dados no Media Pool
#  - Permissões de administrador para Veeam PowerShell 7.x
# ===================================================================

# ===================== CONFIGURAÇÕES =====================

# Dias mínimos desde a última gravação para proteção
$daysToProtect = 7

# Parte da descrição do Media Set para filtrar (ex: "*Daily*")
$mediaSetPattern = "*Daily*"

# Nome do Media Pool GFS
$writePoolName = "GFS-Pool"

# Log
$log = "C:\temp\tape_protect.log"

# ===================== INICIALIZAÇÃO =====================

Get-Date | Out-File $log
#Import-Module Veeam.Backup.PowerShell

$limitDate = (Get-Date).AddDays(-$daysToProtect)

Write-Output "===== INÍCIO DO CICLO DE PROTEÇÃO =====" | Out-File $log -Append

# ===================== FASE A – PROTEGER FITAS =================================

$TapesToProtect = Get-VBRTapeMedium -MediaPool $writePoolName | Where-Object {
    $_.MediaSet -like $mediaSetPattern -and
    $_.LastWriteTime -ne $null -and
    $_.LastWriteTime -ge $limitDate -and
    $_.ProtectedBySoftware -eq $false -and
	$_.IsLocked -eq $false
}

if (-not $TapesToProtect) {
    Write-Output "Nenhuma fita elegível para proteger." | Out-File $log -Append
} else {
    foreach ($t in $TapesToProtect) {
        try {
			Write-Output "Protegendo fita: $($t.Name)"
            # Ativa proteção contra gravação
            Enable-VBRTapeProtection -Medium $t
            Write-Output "Fita $($t.Name) protegida contra gravação." | Out-File $log -Append
        }
        catch {
            Write-Output "ERRO ao proteger fita $($t.Name): $_" | Out-File $log -Append
        }
    }
}

# ===================== FASE B – DESPROTEGER FITAS EXPIRADAS =====================

Write-Output "===== CHECANDO FITAS PROTEGIDAS EXPIRADAS =====" | Out-File $log -Append

$ProtectedTapes = Get-VBRTapeMedium -MediaPool $writePoolName | Where-Object {
    $_.ProtectedBySoftware -eq $true -and
    $_.IsExpired -eq $true
}

if (-not $ProtectedTapes) {
    Write-Output "Nenhuma fita protegida expirou." | Out-File $log -Append
} else {
    foreach ($p in $ProtectedTapes) {
        try {
			Write-Output "Removendo proteção da fita expirada: $($p.Name)"
            # Desativa proteção
            Disable-VBRTapeProtection -Medium $p
            Write-Output "Fita $($p.Name) desprotegida e disponível para escrita." | Out-File $log -Append
        }
        catch {
            Write-Output "ERRO ao desproteger fita $($p.Name): $_" | Out-File $log -Append
        }
    }
}
Write-Output "===== FIM DO CICLO =====" | Out-File $log -Append
