# Veeam Tape Protect Script

![PowerShell](https://img.shields.io/badge/PowerShell-7+-blue.svg)
![Veeam](https://img.shields.io/badge/Veeam-VBR%20v13-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

---

## Overview

This script automates software write protection for tape media in Veeam Backup & Replication.

It ensures that tapes are protected based on defined criteria, preventing premature reuse and improving backup integrity.

---

## How It Works

1. Connects to Veeam Backup Server  
2. Identifies the target Media Pool  
3. Filters tapes based on:
   - Last write time  
   - Protection status  
4. Applies software protection  
5. Logs all actions  

---

## Requirements

- Veeam Backup & Replication v13+
- PowerShell 7+
- Windows Server
- Veeam Console installed

---

## Installation

```
git clone https://github.com/julianscunha/Veeam.Tape.Protect.git
cd Veeam.Tape.Protect
```

---

## Usage

```
pwsh.exe -File .\veeam_tape_protect.ps1
```

---

## With parameters

```
pwsh.exe -File .\veeam_tape_protect.ps1 `
    -MediaPoolName "GFS-Daily" `
    -DaysToProtect 7
```

---

## Accept TLS Certificate (for remote execution)

```
pwsh.exe -File .\veeam_tape_protect.ps1 `
    -Server "veeam01.domain.local" `
    -MediaPoolName "GFS-Daily" `
    -ForceAcceptTlsCertificate
```

---

## Parameters

| Parameter | Description | Default |
|----------|------------|--------|
| Server | Veeam server hostname | localhost |
| MediaPoolName | Target media pool | Required |
| DaysToProtect | Days threshold for protection | 7 |
| LogPath | Log file path | C:\Temp\tape_protect.log |
| ForceAcceptTlsCertificate | Ignore TLS warnings | Disabled |

---

## Log Output Example

```
2026-03-30 22:01:10 [INFO] Starting execution
2026-03-30 22:01:11 [INFO] Found 5 tapes eligible for protection
2026-03-30 22:01:12 [SUCCESS] Tape ABC123 protected
```

---

## Important Notes

- Only unprotected tapes are processed  
- Protection is based on LastWriteTime  
- Prevents accidental tape reuse  
- Designed for automation  

---

## Recommended Use Case

- GFS tape strategies  
- Compliance environments  
- Air-gapped backups  
- Long-term retention policies  

---

## Scheduling Example (Windows Task Scheduler)

Program:
```
pwsh.exe
```

Arguments:
```
-File "C:\Scripts\veeam_tape_protect.ps1"
```

Options:
- Run whether user is logged on or not  
- Run with highest privileges  

---

## Future Improvements

- Automatic unprotect after expiration  
- Reporting (HTML / CSV)  
- Multi-pool support  
- Integration with monitoring tools  

---

## License

MIT License

---

## References

https://helpcenter.veeam.com/docs/vbr/powershell/  
https://helpcenter.veeam.com/docs/vbr/userguide/tape_backup.html  
