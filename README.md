# VPN Manager

OpenVPN manager for CTF platforms (HackTheBox, TryHackMe, etc.) with colored
status output and easy config switching.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Shell](https://img.shields.io/badge/shell-bash-green.svg)
![Platform](https://img.shields.io/badge/platform-linux-lightgrey.svg)

## Features

- Detailed status: uptime, tun/tap interface, IP, traffic, external IP, routing
- Automatic config detection from `${VPN_MANAGER_DIR:-~/vault/vpn}/`
- Smart connection switching — asks for confirmation interactively, auto-confirms when run non-interactively (or with `--yes`/`-y`)
- No sudo required — `openvpn` runs unprivileged via `setcap` (set up once by `install.sh`)
- Short aliases — map short names to long HTB/THM filenames via `.aliases`
- Case-insensitive and substring config name matching

## Requirements

- Linux (Debian/Ubuntu/Arch/etc.), bash, OpenVPN, `bc`, `curl`
- sudo privileges (one-time, during `install.sh` — grants `openvpn` `cap_net_admin`/`cap_net_raw` via `setcap` so it never needs sudo again)

## Installation

### Quick Install

```bash
git clone https://github.com/r3vpwnx/vpn-manager.git
cd vpn-manager
chmod +x install.sh
./install.sh
```

### Manual Install

```bash
# Install dependencies
sudo apt install openvpn bc curl  # Debian/Ubuntu

# Let openvpn run unprivileged (one-time)
sudo setcap cap_net_admin,cap_net_raw+ep "$(readlink -f "$(command -v openvpn)")"

# Copy the script
sudo cp vpn /usr/local/bin/vpn
sudo chmod +x /usr/local/bin/vpn

# Create VPN directory (override with VPN_MANAGER_DIR if you want a different path)
mkdir -p ~/vault/vpn
```

## Usage

Place your `.ovpn` files in `${VPN_MANAGER_DIR:-~/vault/vpn}/`, then:

```bash
vpn --available       # or -a  -- list configs
vpn --<name>          # connect, e.g. vpn --thm / vpn --htb (see Short Aliases below)
vpn --status          # or -s  -- connection details
vpn --terminate       # or -t  -- disconnect
vpn --help            # or -h
```

Add `--yes`/`-y` to skip the "terminate existing connection?" confirmation.
This happens automatically when the command isn't run from a terminal
(Claude/Codex tool calls, n8n webhooks, cron), so autonomous workflows never
hang on a prompt.

## Configuration

### VPN Directory
- **Location:** `${VPN_MANAGER_DIR:-~/vault/vpn}/` (override with the `VPN_MANAGER_DIR` env var)
- **File format:** `<name>.ovpn`

### Short Aliases
Config filenames from HTB/THM are often long and awkward to type
(`eu-central-1-r3vpwnx-regular.ovpn`). Add an `.aliases` file in the VPN
directory to map short names to them:

```
# ${VPN_MANAGER_DIR:-~/vault/vpn}/.aliases
thm=eu-central-1-r3vpwnx-regular
htb=machines_au-2
htb-sp=starting_points_eu-starting-point-1-dhcp
```

`vpn --thm` then resolves to the aliased file. Aliases are checked before
exact/substring matching, so they always win.

### Logs and Files
- **Connection log:** `/tmp/vpn_manager.log`
- **PID file:** `/tmp/vpn_manager.pid`
- **Connection info:** `/tmp/vpn_connection.info`

## Troubleshooting

**VPN not connecting?**
- Verify OpenVPN is installed: `which openvpn`
- Check config file exists: `ls ${VPN_MANAGER_DIR:-~/vault/vpn}/*.ovpn`
- View logs: `cat /tmp/vpn_manager.log`

**No configs showing?**
- Check directory: `ls -la ${VPN_MANAGER_DIR:-~/vault/vpn}/`
- Verify file extension: files must end with `.ovpn`

**Permission denied?**
- `openvpn` needs `cap_net_admin`/`cap_net_raw` to run without sudo. Check with:
  `getcap "$(readlink -f "$(command -v openvpn)")"`
- If missing, re-run: `sudo setcap cap_net_admin,cap_net_raw+ep "$(readlink -f "$(command -v openvpn)")"`

## License

MIT — see [LICENSE](LICENSE).

## Author

[@r3vpwnx](https://github.com/r3vpwnx)
