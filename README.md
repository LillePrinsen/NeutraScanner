# NeutraScan

**Scan. Identify. Control.**

A network scanner for Windows environments. Runs in PowerShell with a WPF interface. No installer, no dependencies, no telemetry.

---

## Overview

NeutraScan is a single-tool network reconnaissance and administration suite for Windows sysadmins, IT support, and security professionals working in corporate environments. It scans a subnet, fingerprints every live host, enumerates identities on accessible machines, and lets you send messages to remote sessions — all from one window.

It runs entirely on the stock Windows PowerShell 5.1 that ships with every modern Windows install. Nothing to compile, nothing to install, no background service.

---

## Features

### Network scan
- Subnet, CIDR (`192.168.1.0/24`), range (`192.168.1.1-192.168.1.50`) or comma-list targets
- Batch parallel ping sweep with configurable timeout
- TCP port scanning: Top 20, Top 100, Common 1-1024, or Full 1-65535
- Reverse DNS, MAC address (ARP), operating system and logged-on user per host
- Three scan depths: Quick, Standard, Deep
- Live progress bar and phase indicator

### Identity and privileges
- Logged-in users on a target
- Local Administrators group members
- Network shares with paths and types
- Effective privileges (via WinRM, falls back to local `whoami /priv`)

### Network messaging
- Send popup messages to remote Windows sessions
- Per-target or broadcast to every discovered host
- `msg.exe` with automatic WinRM fallback, or force either method

### Network tools
- Ping, traceroute, forward and reverse DNS
- Port checker with ranges (`22,80,443,8000-8100`)
- ARP table, netstat, routing table, neighbor cache, adapters, full `ipconfig /all`
- Wake-on-LAN magic packet sender

### Reports
- Export results as CSV, HTML or JSON
- Copy the result table to clipboard
- Summary statistics: OS distribution, top open ports

### Interface
- 8 built-in color themes, applied live
- Top tab navigation, activity log, hover hints
- Optional UI click sounds (generated in-memory, toggleable)

---

## Requirements

- Windows 10 or Windows 11
- Windows PowerShell 5.1 (included with Windows — nothing to install)
- Administrator rights for full functionality (port scan, WMI queries, remote messaging)
- Targets must have WMI and/or WinRM accessible for OS / user / privilege data

---

## Installation

1. Download both files to the same folder:
   - `NeutraScan.bat`
   - `NeutraScan.ps1`
2. Double-click `NeutraScan.bat`
3. Accept the UAC prompt when it appears

That's the entire install.

> Do not move `NeutraScan.ps1` away from `NeutraScan.bat` — the launcher looks for it in the same directory.

---

## Usage

### Basic scan
1. Open the **Network Scan** tab
2. Enter a target range in the box (default: `192.168.1.0/24`)
3. Pick a scan mode and port preset
4. Click **Start Scan**

Results appear in the table as hosts are discovered. Double-click any row to load that IP into the Identity and Messaging tabs.

### Enumerating a single host
1. Switch to the **Identities** tab
2. Enter the target IP or hostname
3. Click **Run All**, or use the individual buttons

### Sending a message
1. Switch to the **Messaging** tab
2. Pick a target from the dropdown (populated from the last scan) or type one in
3. Edit the message body
4. Click **Send to Target** or **Broadcast to All Discovered**

### Exporting
1. Switch to the **Reports** tab
2. Click **Export CSV**, **Export HTML** or **Export JSON**

---

## Scan modes explained

| Mode | What it does |
|------|--------------|
| **Quick** | Ping sweep + port scan. Fastest. |
| **Standard** | Above + WMI queries for OS and logged-on user. |
| **Deep** | Above + local Administrators group check on each target. Requires admin rights on the target. |

---

## Notes and caveats

- Deep scan and privilege enumeration require administrative rights on the **target** machine, not just on the machine running NeutraScan.
- WinRM must be enabled on targets for the privilege enumeration feature to work. Without it, the tool falls back to local privileges on the scanning host.
- Some corporate networks block ICMP, WMI or SMB. Scan results will be correspondingly limited.
- Scan of a /16 network is capped at 4094 hosts per scan. Split larger ranges into multiple runs.
- Only scan networks you own or have **explicit written permission** to test. Scanning networks you do not control is illegal in most jurisdictions.

---

## License

NeutraScan is **commercial software**. It is not free to use beyond the trial period.

See [LICENSE](LICENSE) for the full terms.

**To purchase a license:** https://neutraco.vercel.app/

---

## Contact

- **Author:** littlleprince
- **Discord:** littlleprince
- **Email:** neutracocontact@gmail.com
- **Website:** https://neutraco.vercel.app/