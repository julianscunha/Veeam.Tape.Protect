# Veeam.Tape.Protect

[![License](https://img.shields.io/github/license/julianscunha/Veeam.Tape.Protect)](https://github.com/julianscunha/Veeam.Tape.Protect/blob/main/LICENSE)
[![Top language](https://img.shields.io/github/languages/top/julianscunha/Veeam.Tape.Protect)](https://github.com/julianscunha/Veeam.Tape.Protect)
[![Last commit](https://img.shields.io/github/last-commit/julianscunha/Veeam.Tape.Protect)](https://github.com/julianscunha/Veeam.Tape.Protect/commits/main)
[![Open issues](https://img.shields.io/github/issues/julianscunha/Veeam.Tape.Protect)](https://github.com/julianscunha/Veeam.Tape.Protect/issues)

A small PowerShell utility to automate the tape protect/unprotect cycle for GFS (Grandfather-Father-Son) media sets in Veeam Backup & Replication.

The script protects recently-written GFS tapes against accidental overwrite and removes protection from tapes whose protection has expired.

---

## Key features

- Protects GFS tapes based on last write date and media set pattern.
- Removes software protection from expired protected tapes to make them writable.
- Simple configuration via a few variables at the top of the script.
- Designed to run on the Veeam server with administrative permissions.

---

## Compatibility & Requirements

- Veeam Backup & Replication v12.x or higher
- PowerShell 7.x (pwsh)
- Veeam PowerShell module available on the system (Veeam.Backup.PowerShell)
- Administrative permissions for Veeam cmdlets
- Tape media in a Veeam media pool and reachable by the server

---

## Files

- `veeam_tape_protect.ps1` — main script (edit configuration at the top)
- `LICENSE` — project license

---

## Configuration

Open `veeam_tape_protect.ps1` and edit the top section to match your environment:

- `$daysToProtect` — minimum days since last write for a tape to be considered eligible for protection (default: `7`)
- `$mediaSetPattern` — pattern to match the Media Set description (example: `"*Daily*"`)
- `$writePoolName` — name of the GFS media pool (example: `"GFS-Pool"`)
- `$log` — full path to a log file (example: `C:\temp\tape_protect.log`)

Tip: Uncomment or ensure the Veeam module import line is present if the environment does not auto-import it:
```powershell
# Import-Module Veeam.Backup.PowerShell
```

---

## Usage

Run the script from PowerShell 7 with administrative privileges on the Veeam server:

```powershell
pwsh -ExecutionPolicy Bypass -File .\veeam_tape_protect.ps1
```

Suggested workflows:
- Test interactively first (inspect the list of tapes the script will act on).
- Run as a scheduled task under an account with required permissions.

Example: run manually to verify:
```powershell
# Edit configuration variables in the script, then:
pwsh -File .\veeam_tape_protect.ps1
Get-Content C:\temp\tape_protect.log -Tail 50
```

---

## Scheduling (recommended)

Create a Windows Scheduled Task that runs under a service or administrative account (highest privileges required). Recommended frequency: daily or weekly depending on your retention and tape usage patterns.

- Trigger: Daily at a low-usage hour (e.g., 02:00)
- Action: pwsh -ExecutionPolicy Bypass -File "C:\path\to\veeam_tape_protect.ps1"
- Run with highest privileges

---

## Troubleshooting

- If the script reports missing cmdlets, ensure the Veeam PowerShell module is installed and the script is executed on a Veeam server.
- Ensure the account running the script has appropriate permissions in Veeam.
- Check the log file defined by `$log` for script output and errors.
- If no tapes are found, verify `$writePoolName` and `$mediaSetPattern` match your Veeam configuration and that tapes have LastWriteTime set.

---

## Security & Disclaimer

This script performs tape protection/unprotection operations. Test carefully in a non-production environment and review the logic before scheduling. The author is not responsible for data loss caused by running this script without proper testing.

---

## Suggested improvements

- Parameterize the script (accept CLI parameters or support a configuration file).
- Add a `-WhatIf` or dry-run mode to preview changes.
- Add structured logging (timestamped JSON or CSV) and email/alert notifications.
- Provide unit/integration tests or a CI pipeline for syntax/format checks.
- Add a module manifest and publish to a central location if appropriate.

---

## Contributing

Feel free to open issues or pull requests. If you submit changes, describe the problem you are solving and provide testing notes.

---

## License

This repository is provided under the terms in `LICENSE`.
