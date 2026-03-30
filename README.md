# Veeam Tape Protect

![PowerShell](https://img.shields.io/badge/PowerShell-7+-blue.svg)
![Veeam](https://img.shields.io/badge/Veeam-VBR%20v13-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

---

## Overview

This script automates the tape software protection cycle in Veeam Backup & Replication.

It protects eligible tapes after write activity and removes protection from expired tapes, helping maintain a consistent tape handling process for GFS and operational media pools.

---

## How It Works

1. Loads the Veeam PowerShell module  
2. Calculates the protection eligibility threshold based on `DaysToProtect`  
3. Retrieves tapes from the configured media pool  
4. Protects tapes that match the configured media set pattern and are not yet software-protected  
5. Checks protected tapes that are now expired  
6. Removes software protection from expired tapes  
7. Logs the full cycle to a file  

---

## Requirements

- Veeam Backup & Replication v13 recommended
- PowerShell 7+
- Windows Server
- Veeam Backup Console / PowerShell module available
- Administrative rights on the Veeam server

---

## Installation

```bash
git clone https://github.com/julianscunha/Veeam.Tape.Protect.git
cd Veeam.Tape.Protect
```

---

## Usage

```powershell
pwsh.exe -File .\veeam_tape_protect.ps1
```

---

## With parameters

```powershell
pwsh.exe -File .\veeam_tape_protect.ps1 `
    -DaysToProtect 7 `
    -MediaSetPattern "*Daily*" `
    -WritePoolName "GFS-Pool"
```

---

## Accept TLS Certificate (for remote execution)

This repository version operates locally through the Veeam PowerShell session and does not expose remote server connectivity by default.

If you later add remote connectivity, the standard pattern is:

```powershell
Connect-VBRServer -Server "veeam01.domain.local" -ForceAcceptTlsCertificate
```

---

## Parameters

| Parameter | Description | Default |
|----------|------------|--------|
| DaysToProtect | Days threshold for protection eligibility | `7` |
| MediaSetPattern | Media set filter | `*Daily*` |
| WritePoolName | Target media pool | `GFS-Pool` |
| LogPath | Log file path | `C:\Temp\tape_protect.log` |

---

## Log Output Example

```text
2026-03-30 22:01:10 [INFO] ===== START PROTECTION CYCLE =====
2026-03-30 22:01:11 [INFO] Tapes eligible for protection: 2
2026-03-30 22:01:12 [SUCCESS] Tape TAPE-001 protected
2026-03-30 22:01:20 [INFO] Expired protected tapes found: 1
2026-03-30 22:01:21 [SUCCESS] Protection removed from tape TAPE-010
2026-03-30 22:01:30 [INFO] ===== END CYCLE =====
```

---

## Important Notes

- The original repository version uses a fixed media pool and media set pattern in the script body  
- The original filtering logic protects tapes using `LastWriteTime -ge $limitDate`; if the business rule is “protect only after X days,” this should be reviewed carefully  
- The original script comment says compatibility is VBR v12.x or higher, but standardizing for VBR v13 and PowerShell 7 is the better baseline today  
- For production use, explicit module import and structured logging are recommended  

---

## Recommended Use Case

- GFS tape protection workflows
- Tape rotation operations
- Compliance retention handling
- Air-gapped backup processes

---

## Scheduling Example (Windows Task Scheduler)

Program:
```text
pwsh.exe
```

Arguments:
```text
-File "C:\Scripts\veeam_tape_protect.ps1"
```

Options:
- Run whether user is logged on or not
- Run with highest privileges

---

## Future Improvements

- Add formal parameter block
- Add remote Veeam connection support
- Add HTML / CSV reporting
- Add per-pool validation
- Add dry-run mode

---

## License

MIT License

---

## References

https://helpcenter.veeam.com/docs/vbr/powershell/  
https://helpcenter.veeam.com/docs/vbr/userguide/tape_backup.html  
https://helpcenter.veeam.com/docs/vbr/powershell/enable-vbrtapeprotection.html  
https://helpcenter.veeam.com/docs/vbr/powershell/disable-vbrtapeprotection.html  
