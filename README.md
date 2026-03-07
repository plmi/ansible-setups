# Hyprland OSCP Lab (Ansible)

Reproducible pentest workstation setup for **Fedora 43** and **Kali Linux**.
No click-ops. No mystery state. Just `make apply`.

## Supported Hosts

| Host | OS | VM Platform | User | Desktop |
|---|---|---|---|---|
| `fedora43` | Fedora 43 | UTM | `michael` | Hyprland (Wayland) |
| `kali` | Kali Linux Rolling | Parallels Desktop | `parallels` | Hyprland (Wayland) |
| `kali-i3` | Kali Linux Rolling | — | `kali` | i3 (X11) |

## What You Get
- Minimal Hyprland desktop tuned for operator workflow
- `foot` + `zsh` + `tmux` + `neovim` + `eza`
- OSCP-oriented tooling with Kali-like paths where it matters
- Screenshot + annotation flow (`grim` + `slurp` + `swappy`)
- Waybar with VPN/target/public-IP visibility
- Dotfiles from `https://github.com/plmi/dotfiles` applied via `make fedora-hyprland`
- Obsidian via Flatpak, Brave Browser

## Fast Start
```bash
make deps
make doctor
make apply        # all hosts
make fedora       # fedora43 only
make kali         # kali only
make validate
```

## Install Ansible (Control Machine)
### macOS
```bash
brew install ansible
ansible --version
```

### Linux
Fedora:
```bash
sudo dnf install -y ansible-core
```

Debian/Kali:
```bash
sudo apt update && sudo apt install -y ansible
```

## Required VM Prep

Confirm SSH and set up key auth for each host:

```bash
ssh-copy-id michael@192.168.64.6   # fedora43
ssh-copy-id parallels@10.211.55.28 # kali
```

Password auth fallback:
```bash
make doctor EXTRA_ARGS='--ask-pass --ask-become-pass'
make apply  EXTRA_ARGS='--ask-pass --ask-become-pass'
```

## Inventory

```
inventories/lab/
├── hosts.yml               # host IPs and users
├── group_vars/
│   ├── all.yml             # shared defaults (timezone, primary_user, etc.)
│   ├── workstation.yml     # dotfiles repo URL, Obsidian toggle
│   ├── hyprland.yml        # Hyprland/COPR vars, monitor scale
│   ├── pentest.yml         # pentest tool flags and URLs
│   └── vpn_clients.yml     # VPN group (NM integration)
└── host_vars/
    ├── fedora43.yml        # Fedora-specific overrides
    └── kali.yml            # Kali-specific overrides (skips pre-installed tools, scale=1)
```

## Playbooks

| Playbook | What it runs |
|---|---|
| `playbooks/site.yml` | Full setup (workstation + pentest) |
| `playbooks/workstation.yml` | Base OS + user + shell + Hyprland + dotfiles |
| `playbooks/pentest.yml` | Pentest tools + VPN |
| `playbooks/validate.yml` | Post-install checks |

## Make Targets

| Target | Description |
|---|---|
| `make deps` | Install Ansible collections from `requirements.yml` |
| `make doctor` | Preflight checks (tools, inventory, SSH, target facts) |
| `make apply` | Run full setup on all hosts |
| `make workstation` | Run workstation stack only |
| `make pentest` | Run pentest stack only |
| `make validate` | Run validation checks (all hosts) |
| `make fedora` | Run `site.yml` limited to `fedora43` |
| `make kali` | Run `site.yml` limited to `kali` |
| `make kali-i3` | Run `site.yml` limited to `kali-i3` |
| `make validate-kali` | Run `validate.yml` limited to `kali` |

## Tool Matrix

| Category | Tool | Source | Method |
|---|---|---|---|
| Desktop | hyprland | COPR `solopasha/hyprland` | dnf |
| Desktop | brave-browser | Brave RPM repo | dnf |
| Desktop | obsidian | Flathub | flatpak |
| Shell | zsh | Fedora repos | dnf |
| Shell | foot | Fedora repos | dnf |
| Shell | tmux | Fedora repos | dnf |
| Shell | neovim | Fedora repos | dnf |
| Shell | eza | GitHub `eza-community/eza` latest | binary tarball |
| Shell | fzf | Fedora repos | dnf |
| Shell | bat | Fedora repos | dnf |
| Shell | btop | Fedora repos | dnf |
| Shell | zoxide | Fedora repos | dnf |
| Shell | fastfetch | Fedora repos | dnf |
| Shell | pyenv | GitHub `pyenv/pyenv` | git clone → `~/.pyenv` |
| Shell | pyenv-virtualenv | GitHub `pyenv/pyenv-virtualenv` | git clone → `~/.pyenv/plugins/` |
| Pentest | nmap | Fedora repos | dnf |
| Pentest | netcat | Fedora repos | dnf |
| Pentest | socat | Fedora repos | dnf |
| Pentest | tcpdump | Fedora repos | dnf |
| Pentest | wireshark | Fedora repos | dnf |
| Pentest | ffuf | Fedora repos | dnf |
| Pentest | gobuster | Fedora repos | dnf |
| Pentest | hydra | Fedora repos | dnf |
| Pentest | john | Fedora repos | dnf |
| Pentest | hashcat | Fedora repos | dnf |
| Pentest | feroxbuster | GitHub `epi052/feroxbuster` latest | binary zip |
| Pentest | nikto | GitHub `sullo/nikto` latest | source zip + wrapper |
| Pentest | sqlmap | GitHub `sqlmapproject/sqlmap` | git clone + wrapper |
| Pentest | impacket | PyPI | pipx |
| Pentest | metasploit | Snap Store | snap |
| Pentest | wpscan | RubyGems | gem |
| Pentest | searchsploit | GitLab `exploitdb` | git clone + symlink |
| Wordlists | seclists | GitHub `danielmiessler/SecLists` | zip → `/usr/share/seclists` |
| Wordlists | rockyou.txt | SecLists / fallback URL | copy → `/usr/share/wordlists/rockyou.txt` |
| VPN | openvpn | Fedora repos | dnf |
| VPN | wireguard-tools | Fedora repos | dnf |

> Kali skips most Pentest entries — override via `pentest_install_*: false` in `host_vars/kali.yml`.

### Dotfiles
- Repo cloned to `~/dotfiles`, profile applied with `make fedora-hyprland`
- On non-Fedora hosts (Kali), post-stow patches fix hardcoded paths and adapt config:
  - `/home/<author>/bin/` → `/home/<primary_user>/.local/bin/`
  - `windowrulev2` → `windowrule` (Hyprland 0.41+ syntax)
  - Monitor scale set from `hyprland_monitor_scale` (default `2`, Kali uses `1`)
  - `spice-vdagent` exec-once commented out on non-SPICE VMs

## Without Make
```bash
ansible-galaxy collection install -r requirements.yml
ansible-playbook -i inventories/lab/hosts.yml playbooks/site.yml
ansible-playbook -i inventories/lab/hosts.yml playbooks/site.yml --limit fedora43
ansible-playbook -i inventories/lab/hosts.yml playbooks/site.yml --limit kali
ansible-playbook -i inventories/lab/hosts.yml playbooks/validate.yml
```

## Notes
- Use only on systems/networks you own or are explicitly authorized to test.
- Store secrets with Ansible Vault.
- Firewall (`firewalld`/`ufw`) is **disabled by default** (`enable_firewalld: false`). Enable per-host in `host_vars/`.
- Dotfiles are the source of truth for user/system config (`~/.config/*`, shell, editor, Waybar, Hyprland).
- Ansible installs packages/services and applies dotfiles — it does not template overlapping dotfiles.
- `ansible.cfg` sets `ssh_connection.usetty=False` to avoid OSC 3008 escape-sequence noise.

## VPN Profile Import (nmcli)

Import each config once, then select it from the OSCP launcher (`SUPER+R`):

OpenVPN (`.ovpn`):
```bash
nmcli connection import type openvpn file /path/to/lab.ovpn
```

WireGuard (`.conf`):
```bash
nmcli connection import type wireguard file /path/to/lab.conf
```

Useful commands:
```bash
nmcli -t -f NAME,TYPE connection show | grep -E ':(vpn|wireguard)$'
nmcli connection up id "<profile-name>"
nmcli connection down id "<profile-name>"
```

## Hyprland Keybindings

Modifier: `SUPER`

| Keybind | Action |
|---|---|
| `SUPER+RETURN` | Open terminal (`foot`) |
| `SUPER+P` / `SUPER+D` | App launcher (`wofi`) |
| `SUPER+R` | OSCP launcher (`wofi-oscp`) |
| `SUPER+TAB` | Switch to previous workspace |
| `SUPER+SPACE` | Toggle special workspace (scratchpad) |
| `SUPER+SHIFT+SPACE` | Move window to special workspace |
| `SUPER+SHIFT+S` | Region screenshot → `swappy` |
| `SUPER+SHIFT+W` | Cycle wallpapers |
| `SUPER+B` | Toggle Waybar |
| `SUPER+SHIFT+B` | Reload Waybar |
| `SUPER+Q` | Close window |
| `SUPER+SHIFT+E` | Exit Hyprland |
| `SUPER+F` | Toggle fullscreen |
| `SUPER+V` | Toggle floating |
| `SUPER+L` | Lock screen (`hyprlock`) |
| `SUPER+1..9` | Switch workspace |
| `SUPER+SHIFT+1..9` | Move window to workspace |
| `SUPER+H/J/K/L` | Move focus left/down/up/right |
| `SUPER+Left Mouse` | Move window |
| `SUPER+Right Mouse` | Resize window |
