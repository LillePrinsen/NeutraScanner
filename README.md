# NeutraScan

**Scan. Identify. Control.**

A network reconnaissance and administration suite for Windows environments.<br>
Runs on stock PowerShell. No installer. No dependencies. No telemetry.

<br>

[![Version](https://img.shields.io/badge/version-1.0.0-58A6FF?style=for-the-badge&labelColor=0D1117)](https://neutraco.vercel.app/)
[![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-0078D6?style=for-the-badge&labelColor=0D1117)](#requirements)
[![PowerShell](https://img.shields.io/badge/powershell-5.1-5391FE?style=for-the-badge&labelColor=0D1117)](#requirements)
[![License](https://img.shields.io/badge/license-Commercial-DA3633?style=for-the-badge&labelColor=0D1117)](LICENSE)

[![Download](https://img.shields.io/badge/DOWNLOAD-NeutraScan-238636?style=for-the-badge&labelColor=0D1117)](https://neutraco.vercel.app/)
[![Website](https://img.shields.io/badge/WEBSITE-neutraco.vercel.app-8957E5?style=for-the-badge&labelColor=0D1117)](https://neutraco.vercel.app/)

<br>

[Overview](#overview) &nbsp;&middot;&nbsp;
[Install](#install) &nbsp;&middot;&nbsp;
[Usage](#usage) &nbsp;&middot;&nbsp;
[Features](#features) &nbsp;&middot;&nbsp;
[FAQ](#faq) &nbsp;&middot;&nbsp;
[License](#license)

</div>

---

<br>

<div align="center">

## Overview

</div>

**NeutraScan** is a single-tool network scanner built for sysadmins, IT support teams, and security professionals working in corporate Windows environments. Enter a subnet, and it discovers every live host, fingerprints each one, enumerates identities on accessible machines, and gives you the tools to act on what it finds — all from one window.

It runs entirely on the Windows PowerShell 5.1 that ships with every modern Windows install. Nothing to compile. Nothing to install. No background service, no agents on targets, no cloud dependency.

<br>

<div align="center">

<img src="assets/screenshot.png" alt="NeutraScan interface" width="90%" />

<sub><i>The NeutraScan interface — Network Scan tab with the GitHub Dark theme applied.</i></sub>

</div>

<br>

---

## Install

<div align="center">

### One-line installer

</div>

Open **PowerShell as Administrator** and run:

```powershell
irm https://neutraco.vercel.app/install.ps1 | iex
```

<div align="center">
<sub>Downloads NeutraScan into <code>%LOCALAPPDATA%\NeutraScan\</code>, creates a Start Menu shortcut, and launches the app.</sub>
</div>

<br>

<div align="center">

### Prefer to inspect first?

</div>

```powershell
irm https://neutraco.vercel.app/install.ps1 -OutFile install.ps1
notepad install.ps1
.\install.ps1
```

<br>

<div align="center">

### Manual install

</div>

1. Download both files into the same folder:
   - [`NeutraScan.bat`](https://neutraco.vercel.app/NeutraScan.bat)
   - [`NeutraScan.ps1`](https://neutraco.vercel.app/NeutraScan.ps1)
2. Double-click `NeutraScan.bat`
3. Accept the UAC prompt

> Do not move `NeutraScan.ps1` away from `NeutraScan.bat`. The launcher resolves the script relative to its own directory.

<br>

---

## Quick start

```powershell
# 1. Install
irm https://neutraco.vercel.app/install.ps1 | iex

# 2. Launch from Start Menu, or:
& "$env:LOCALAPPDATA\NeutraScan\NeutraScan.bat"
```

Then, in the app:

1. Enter a target range on the **Network Scan** tab (default `192.168.1.0/24`)
2. Choose a scan mode and port preset
3. Click **Start Scan**
4. Double-click any result row to load that host into the **Identities** and **Messaging** tabs

<br>

---

## Requirements

<div align="center">

| | Requirement |
|:---:|:---|
| ![OS](https://img.shields.io/badge/-Windows%2010%20%2F%2011-0078D6?style=flat-square&labelColor=0D1117) | Windows 10 or Windows 11 |
| ![Shell](https://img.shields.io/badge/-PowerShell%205.1-5391FE?style=flat-square&labelColor=0D1117) | Built into Windows — nothing to install |
| ![Rights](https://img.shields.io/badge/-Administrator-DA3633?style=flat-square&labelColor=0D1117) | Required for port scan, WMI queries, remote messaging |
| ![Targets](https://img.shields.io/badge/-WMI%20%2F%20WinRM-8957E5?style=flat-square&labelColor=0D1117) | Needed on targets for OS, user, and privilege data |

</div>

<br>

---

## Features

<div align="center">

### Network scan

</div>

| Feature | Description |
|---|---|
| **Flexible targets** | CIDR (`192.168.1.0/24`), range (`192.168.1.1-192.168.1.50`), or comma-separated list |
| **Batch ping sweep** | Parallel ICMP with configurable timeout, up to 4094 hosts per run |
| **Port scanning** | Top 20 · Top 100 · Common 1-1024 · Full 1-65535 |
| **Host fingerprinting** | Reverse DNS, MAC (ARP), operating system, logged-on user |
| **Scan depths** | Quick · Standard · Deep |

<div align="center">

### Identity and privileges

</div>

| Feature | Description |
|---|---|
| **Logged-in users** | Who is at the keyboard of each live host |
| **Local administrators** | Members of the target's Administrators group |
| **Network shares** | Paths, names, and share types |
| **Effective privileges** | Via WinRM, with local `whoami /priv` fallback |

<div align="center">

### Network messaging

</div>

| Feature | Description |
|---|---|
| **Targeted messages** | Popup to a specific host and session |
| **Broadcast** | Message every host discovered in the last scan |
| **Delivery methods** | `msg.exe` with automatic WinRM fallback, or force either |

<div align="center">

### Tools

</div>

| Feature | Description |
|---|---|
| **Reachability** | Ping, traceroute, forward and reverse DNS |
| **Port checker** | Single ports, lists, or ranges (`22,80,443,8000-8100`) |
| **Local network state** | ARP table, netstat, routes, neighbors, adapters, `ipconfig /all` |
| **Wake-on-LAN** | Send magic packets to any MAC on the subnet |

<div align="center">

### Reporting

</div>

| Feature | Description |
|---|---|
| **Exports** | CSV, HTML (styled), JSON |
| **Clipboard** | Copy the full result table in one click |
| **Statistics** | OS distribution, top open ports |

<br>

---

## Scan modes

<div align="center">

| Mode | Included |
|:---:|:---|
| ![Quick](https://img.shields.io/badge/Quick-3FB950?style=for-the-badge&labelColor=0D1117) | Ping sweep · Port scan |
| ![Standard](https://img.shields.io/badge/Standard-D29922?style=for-the-badge&labelColor=0D1117) | + OS query · Logged-on user |
| ![Deep](https://img.shields.io/badge/Deep-DA3633?style=for-the-badge&labelColor=0D1117) | + Local Administrators check |

</div>

> **Deep mode requires administrative rights on the target machine**, not just the machine running NeutraScan.

<br>

---

## Screenshots

<div align="center">

<table>
<tr>
<td width="50%">

<img src="assets/screenshot-scan.png" alt="Network Scan" width="100%" />
<sub><b>Network Scan</b> — live host discovery and fingerprinting</sub>

</td>
<td width="50%">

<img src="assets/screenshot-identities.png" alt="Identities" width="100%" />
<sub><b>Identities</b> — users, admins, shares, privileges</sub>

</td>
</tr>
<tr>
<td width="50%">

<img src="assets/screenshot-messaging.png" alt="Messaging" width="100%" />
<sub><b>Messaging</b> — popup delivery via msg.exe or WinRM</sub>

</td>
<td width="50%">

<img src="assets/screenshot-tools.png" alt="Tools" width="100%" />
<sub><b>Tools</b> — ping, DNS, port check, WoL, local state</sub>

</td>
</tr>
</table>

</div>

<br>

---

## Usage

### Basic scan

```
Network Scan tab  →  enter target range  →  Start Scan
```

Live hosts appear in the results table as they are discovered. Double-click any row to load that IP into the **Identities** and **Messaging** tabs.

### Enumerate a single host

```
Identities tab  →  enter IP or hostname  →  Run All
```

Or use the individual buttons to run just one check.

### Send a message

```
Messaging tab  →  pick a target from the dropdown  →  edit body  →  Send
```

Use **Broadcast to All Discovered** to message every host from the last scan.

### Export

```
Reports tab  →  Export CSV / HTML / JSON
```

<br>

---

## Notes and caveats

- Deep scans and privilege enumeration require administrative rights on the **target**, not just the scanning host.
- WinRM must be enabled on targets for remote privilege enumeration. Without it, the tool falls back to local privileges on the scanning host.
- Corporate networks often block ICMP, WMI, or SMB. Scan results will be correspondingly limited.
- A single scan is capped at **4094 hosts**. Split larger ranges across multiple runs.
- **Only scan networks you own or have explicit written permission to test.** Unauthorized network scanning is illegal in most jurisdictions.

<br>

---

## FAQ

<details>
<summary><b>Does NeutraScan install anything on the target machines?</b></summary>

No. Everything runs from the scanning host. WMI and WinRM queries are executed remotely using Windows' built-in facilities — nothing is deployed or left behind on targets.
</details>

<details>
<summary><b>Why does the port scan miss open ports?</b></summary>

The port preset determines which ports are probed. If you're looking for something outside the preset list, switch to **Common 1-1024** or **Full 1-65535**. Also check the port timeout in Settings — slow hosts need a longer window.
</details>

<details>
<summary><b>Why is the OS column empty?</b></summary>

WMI access to the target is required for that column. The most common causes are firewall rules blocking WMI (RPC port 135 + dynamic range), missing credentials, or the target not being domain-joined on the same network.
</details>

<details>
<summary><b>Why does Deep mode show "Denied" for administrators?</b></summary>

That column reports whether the scanning account has admin rights **on the target**. If your account is a local admin on your own machine but not on the target, the check is correctly returning "Denied".
</details>

<details>
<summary><b>Is there a Linux or macOS version?</b></summary>

Not at this time. NeutraScan is Windows-only by design — the interface is WPF, and the scanning techniques rely on Windows-native WMI and WinRM.
</details>

<br>

---

## License

<div align="center">

**NeutraScan is commercial software.**<br>
Not free to use beyond the trial period.

<br>

[![License](https://img.shields.io/badge/VIEW%20LICENSE-Commercial-DA3633?style=for-the-badge&labelColor=0D1117)](LICENSE)
[![Purchase](https://img.shields.io/badge/PURCHASE-License-238636?style=for-the-badge&labelColor=0D1117)](https://neutraco.vercel.app/)

</div>

- **Trial:** 14 days, non-commercial evaluation only
- **After trial:** purchase required
- **Redistribution:** not permitted
- See [`LICENSE`](LICENSE) for full terms

<br>

---

<div align="center">

## Contact

**littlleprince**

[![Discord](https://img.shields.io/badge/Discord-littlleprince-5865F2?style=for-the-badge&logo=discord&logoColor=white&labelColor=0D1117)](https://discord.com/users/littlleprince)
[![Email](https://img.shields.io/badge/Email-neutracocontact@gmail.com-EA4335?style=for-the-badge&logo=gmail&logoColor=white&labelColor=0D1117)](mailto:neutracocontact@gmail.com)
[![Website](https://img.shields.io/badge/Website-neutraco.vercel.app-58A6FF?style=for-the-badge&logo=vercel&logoColor=white&labelColor=0D1117)](https://neutraco.vercel.app/)

<br>

<sub>Built for the people who keep Windows networks running.</sub>

</div>
```

---

## Placeholders to replace

Search the file and replace each of these:

| Placeholder | Replace with |
|---|---|
| `USERNAME/REPO` | (none appear — all links already point at `neutraco.vercel.app`) |

You're good — no GitHub-URL placeholders this time. Everything goes through your own domain.

---

## Assets you need to add

Create an `assets/` folder in the repo and drop these in. Missing files just render as broken-image icons; the rest of the README works without them.

| File | Size | Content |
|---|---|---|
| `assets/banner.png` | 1280×320 | Wide header image — dark background, "NeutraScan" wordmark, "Scan. Identify. Control." tagline |
| `assets/screenshot.png` | any | Hero screenshot (used in Overview) |
| `assets/screenshot-scan.png` | any | Network Scan tab |
| `assets/screenshot-identities.png` | any | Identities tab |
| `assets/screenshot-messaging.png` | any | Messaging tab |
| `assets/screenshot-tools.png` | any | Tools tab |

### Quick way to make a decent banner without design software

Open PowerShell, run this, save the output as a PNG via Paint if you want an image — or just make it in Figma/Canva in five minutes using:

- Background: `#0D1117`
- A rounded square on the left with `#58A6FF` fill and a white **N**
- Next to it, "NeutraScan" in white (Segoe UI Bold, ~72pt)
- Under it, "Scan. Identify. Control." in `#8B949E` italic (~24pt)

That matches the app's header exactly, so the README banner and the running app look like the same product.

---

## Badges note

The shields.io badges are all live — they render on GitHub without any setup. The two you'll want to update as things change:

- **Version** — edit `version-1.0.0` when you bump
- **License** — leave as-is unless you change the license

The Discord badge links to `discord.com/users/littlleprince`, which only works if people can add you by username. If you'd rather point at a server invite, swap the URL.
