# Hyprland Configuration

Modular Lua-based Hyprland configuration on Arch Linux.
Designed for a **34-key Forager split keyboard** — home-row navigation, minimal chords.

Keybindings reference: [`KEYBINDINGS.md`](KEYBINDINGS.md)

---

## Directory Tree

```
~/.config/hypr/
├── hyprland.lua              # Root entry point (require chain)
├── README.md
│
├── config/
│   ├── env.lua               # Environment variables
│   ├── monitors.lua          # Monitor documentation & defaults
│   ├── autostart.lua         # Startup programs & daemons
│   ├── appearance.lua        # General, decoration, misc, layouts
│   ├── input.lua             # Input, touchpad, gesture, per-device
│   ├── workspaces.lua        # Workspace-to-monitor pinning
│   ├── animations.lua        # Curves, animation leaves
│   ├── binds.lua             # All keyboard & mouse bindings
│   ├── media.lua             # Media/hardware key bindings
│   └── rules.lua             # Window rules
│
├── scripts/
│   ├── auto-monitor.sh       # Description-based monitor layout
│   ├── monitor-daemon.sh     # Hotplug topology daemon
│   └── randowall.sh          # Random wallpaper picker
│
├── hypridle.conf             # Idle management (lock + suspend)
└── hyprlock.conf             # Lock screen appearance
```

---

## Architecture

### Module Load Order

```
  hyprland.lua
      │
      ├── config/env.lua          Environment variables (earliest)
      ├── config/monitors.lua     Monitor documentation only
      ├── config/autostart.lua    Startup services & daemons
      ├── config/appearance.lua   Gaps, borders, shadows, blur
      ├── config/input.lua        Keyboard, touchpad, mouse
      ├── config/workspaces.lua   Workspace pinning
      ├── config/animations.lua   Curves & animation leaves
      ├── config/binds.lua        Keybindings (home-row focus)
      ├── config/media.lua        XF86 hardware keys
      └── config/rules.lua        Window matching rules
```

All `hl.config{}` blocks merge at the Hyprland level — order between files does not affect behavior. The `require` order is organizational.

### Startup Sequence

```
┌─────────────────────────────────────────────────────┐
│ start-hyprland                                       │
│   │                                                   │
│   ├── hyprland.lua loaded                             │
│   │   └── config/*.lua loaded (declarative config)    │
│   │                                                   │
│   ├── hyprland.start event fires                      │
│   │   ├── dbus-update-activation-environment          │
│   │   ├── systemctl import-environment                │
│   │   ├── systemctl start hyprland-session.target     │
│   │   ├── monitor-daemon.sh &  (background daemon)    │
│   │   ├── sleep 1 && auto-monitor.sh                  │
│   │   ├── nm-applet                                   │
│   │   ├── dunst                                       │
│   │   ├── blueman-applet                              │
│   │   ├── gnome-keyring-daemon                        │
│   │   ├── polkit-gnome-authentication-agent-1         │
│   │   ├── waybar                                      │
│   │   ├── awww-daemon                                 │
│   │   ├── hypridle                                    │
│   │   ├── randowall.sh                                │
│   │   ├── firewall-applet                             │
│   │   └── cliphist store (text + image)               │
│   │                                                   │
│   └── Hyprland running (interactive)                  │
└─────────────────────────────────────────────────────┘
```

---

## Monitor Management

### Detection Pipeline

```
┌──────────────────────────────────────────────────────────────────┐
│                      monitor-daemon.sh                           │
│                                                                   │
│  sleep 2  ──►  poll hyprctl monitors -j  ──►  jq fingerprint     │
│                      every 1s                    name|description │
│                                                    ┌───┴───┐      │
│                                                    │ same  │      │
│                                                    │  ?    │      │
│                                                    └───┬───┘      │
│                                                   No  │  Yes     │
│                                                    ┌──┴──┐       │
│                                                    │     │       │
│                                                    ▼     └─►sleep│
│                                              auto-monitor.sh     │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│                       auto-monitor.sh                             │
│                                                                   │
│  ┌─ Debounce (2s cooldown) ──────────────────────────────────┐   │
│  │  if called twice within 2s → skip                          │   │
│  └────────────────────────────────────────────────────────────┘   │
│                                                                   │
│  ┌─ Parse hyprctl monitors -j ───────────────────────────────┐   │
│  │  python3 JSON parser                                       │   │
│  │  laptop = pick('BOE 0x0AE6')  ← description match         │   │
│  │  arzopa = pick('ARZOPA')      ← description match         │   │
│  │  other  = everything else     ← generic external          │   │
│  │  fallback: connector-based if description fails            │   │
│  └────────────────────────────────────────────────────────────┘   │
│                                                                   │
│  ┌─ Apply layout ────────────────────────────────────────────┐   │
│  │  count=1  → laptop only                                    │   │
│  │  count=2  → laptop + arzopa (portrait) or laptop + other   │   │
│  │  count>=3 → arzopa left + laptop center + other right      │   │
│  │  on error → keep laptop alive at minimum                   │   │
│  └────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘
```

### Monitor Fingerprint (jq)

```
hyprctl monitors -j | jq -r '.[] | "\(.name)|\(.description)"' | sort

Output:
  HDMI-A-1|GWD ARZOPA 0000001729970
  eDP-1|BOE 0x0AE6

Changes when:
  ✓ Monitor connected or disconnected
  ✓ Monitor swapped for another
  ✓ Connector changes (HDMI → DP → USB-C)
  ✓ Monitor replaced with different model
Does NOT change on:
  ✓ Hyprland ID reassignment  (IDs excluded)
  ✓ Workspace switches        (runtime state excluded)
  ✓ Cursor position changes   (x/y excluded)
```

### Layout Rules

```
1 monitor ──► Laptop only
  ┌──────────────────┐
  │  eDP-1 @ 1.25x   │
  │  BOE 0x0AE6       │
  └──────────────────┘

2 monitors ──► Laptop + Arzopa (portrait)
  ┌──────────────────┐ ┌──────────┐
  │  eDP-1 @ 1.25x   │ │  ARZOPA  │
  │  left             │ │  right   │
  │                   │ │ portrait │
  │                   │ │ @ 1.25x  │
  └──────────────────┘ └──────────┘

2 monitors ──► Laptop + Desktop
  ┌──────────────────┐ ┌──────────────────┐
  │  eDP-1 @ 1.25x   │ │  external @ 1x   │
  │  left             │ │  right           │
  └──────────────────┘ └──────────────────┘

3+ monitors ──► Arzopa + Laptop + Desktop
  ┌──────────┐ ┌──────────────────┐ ┌──────────────────┐
  │  ARZOPA  │ │  eDP-1 @ 1.25x   │ │  external @ 1x   │
  │  left     │ │  center          │ │  right           │
  │ portrait │ │                  │ │                  │
  │ @ 1.25x  │ │                  │ │                  │
  └──────────┘ └──────────────────┘ └──────────────────┘
```

### Edge Cases Handled

| Case | Mechanism |
|---|---|
| Monitors connected before Hyprland starts | `auto-monitor.sh` runs 1s after startup |
| Monitor hotplugged after login | `monitor-daemon.sh` detects fingerprint change → triggers layout |
| Monitor unplugged, windows active | Hyprland moves windows to remaining monitor; layout reapplied |
| Arzopa ↔ Desktop swap (same count) | Fingerprint detects description change → triggers layout |
| Connector changes (HDMI → DP → USB-C) | Matched by description (`ARZOPA`), not connector name |
| EDID changes / different monitor model | Fuzzy substring match; unknown monitors = "other" |
| Reconnect storm (docking station) | 2-second debounce in `auto-monitor.sh` |
| Script/parse failure | Falls back to `eDP-1 @ 1.25x` safe state — never disables all monitors |
| Future monitor replacement | No vendor-specific dependency — automatically "other" |

---

## Keybindings

Mod key: `SUPER` (designed for 34-key Forager — home-row navigation, minimal chords)

### Applications

| Key | Action | File |
|---|---|---|
| `SUPER + Return` | Alacritty | `binds.lua:8` |
| `SUPER + SHIFT + Return` | Kitty | `binds.lua:9` |
| `SUPER + Space` | Rofi app launcher | `binds.lua:13` |
| `SUPER + B` | Brave | `binds.lua:11` |
| `SUPER + E` | PCManFM | `binds.lua:12` |
| `SUPER + V` | Clipboard history (cliphist → rofi → wl-copy) | `binds.lua:7` |
| `SUPER + ALT + C` | cmus in Alacritty | `binds.lua:10` |
| `SUPER + ALT + R` | Random wallpaper | `binds.lua:14` |
| `SUPER + W` | Rofi window switcher | `binds.lua:17` |

### Window Management

| Key | Action | File |
|---|---|---|
| `SUPER + Q` | Close window | `binds.lua:27` |
| `SUPER + F` | Toggle fullscreen | `binds.lua:28` |
| `SUPER + S` | Toggle floating | `binds.lua:29` |
| `SUPER + P` | Toggle pseudo tiling | `binds.lua:30` |
| `SUPER + M` | Toggle split layout | `binds.lua:31` |
| `SUPER + H / J / K / L` | Focus left / down / up / right | `binds.lua:44-47` |
| `SUPER + SHIFT + H / J / K / L` | Move window left / down / up / right | `binds.lua:50-53` |
| `SUPER + ALT + H / J / K / L` | Resize window | `binds.lua:56-59` |
| `SUPER + mouse:272` | Drag floating window | `binds.lua:87` |
| `SUPER + mouse:273` | Resize window | `binds.lua:88` |

### Floating Window Movement

| Key | Action | File |
|---|---|---|
| `SUPER + SHIFT + left` | Move floating window left | `binds.lua:62` |
| `SUPER + SHIFT + down` | Move floating window down | `binds.lua:63` |
| `SUPER + SHIFT + up` | Move floating window up | `binds.lua:64` |
| `SUPER + SHIFT + right` | Move floating window right | `binds.lua:65` |

### Workspace Navigation

| Key | Action | File |
|---|---|---|
| `SUPER + 1..0` | Switch to workspace 1-10 | `binds.lua:70` |
| `SUPER + SHIFT + 1..0` | Move window to workspace 1-10 | `binds.lua:71` |
| `SUPER + Tab` | Previous workspace | `binds.lua:37` |
| `SUPER + [` | Previous workspace (cycle) | `binds.lua:75` |
| `SUPER + ]` | Next workspace (cycle) | `binds.lua:76` |
| `SUPER + mouse_down` | Next workspace | `binds.lua:83` |
| `SUPER + mouse_up` | Previous workspace | `binds.lua:84` |

### Scratchpad

| Key | Action | File |
|---|---|---|
| `SUPER + I` | Toggle special workspace (hidden) | `binds.lua:41` |
| `SUPER + SHIFT + I` | Move window to special workspace (hidden) | `binds.lua:40` |
| `SUPER + grave` | Toggle special workspace (magic) | `binds.lua:79` |
| `SUPER + SHIFT + grave` | Move window to special workspace (magic) | `binds.lua:80` |

### System

| Key | Action | File |
|---|---|---|
| `SUPER + R` | Reload Hyprland + re-detect monitors | `binds.lua:34` |
| `SUPER + SHIFT + X` | Lock screen (hyprlock) | `binds.lua:24` |
| `Print` | Full screenshot (grim) | `binds.lua:20` |
| `SUPER + SHIFT + S` | Area screenshot (grim + slurp) | `binds.lua:21` |

### Media / Hardware Keys (locked, repeating where appropriate)

| Key | Action | File |
|---|---|---|
| `XF86AudioRaiseVolume` | Volume +5% | `media.lua:1` |
| `XF86AudioLowerVolume` | Volume -5% | `media.lua:2` |
| `XF86AudioMute` | Toggle mute | `media.lua:3` |
| `XF86AudioMicMute` | Toggle mic mute | `media.lua:4` |
| `XF86MonBrightnessUp` | Brightness +5% | `media.lua:5` |
| `XF86MonBrightnessDown` | Brightness -5% | `media.lua:6` |
| `XF86AudioNext` | Next track | `media.lua:7` |
| `XF86AudioPause` | Play/pause | `media.lua:8` |
| `XF86AudioPlay` | Play/pause | `media.lua:9` |
| `XF86AudioPrev` | Previous track | `media.lua:10` |

---

## File Reference

### `config/env.lua`

```lua
hl.env("XCURSOR_SIZE", "24")
hl.env("GTK_THEME", "Graphite-Dark")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("GTK_ICON_THEME", "Papirus-icon-theme")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
```

Portal environment variables. `XDG_CURRENT_DESKTOP=Hyprland` is required by `xdg-desktop-portal-hyprland` for screen sharing and file picker integration.

### `config/autostart.lua`

Services started on `hyprland.start`: dbus environment propagation, session target, monitor daemon and initial layout, nm-applet, dunst, blueman-applet, gnome-keyring, polkit, waybar, awww-daemon (wallpaper), hypridle, randowall.sh, firewall-applet, cliphist (text + image watchers).

### `config/appearance.lua`

Three `hl.config{}` blocks:
- **general**: gaps (5/20), border size/color, dwindle layout
- **decoration**: rounding (0), shadow, blur (3px, 1 pass)
- **misc**: no default wallpaper, no logo
- **layouts**: dwindle `preserve_split`, master `new_status`

### `config/input.lua`

- **input**: US layout, flat acceleration, sensitivity 0.3
- **touchpad**: natural scroll, tap-to-click, drag lock, disable-while-typing, clickfinger, middle-button emulation
- **gesture**: 3-finger horizontal swipe for workspace switch
- **device**: epic-mouse-v1 sensitivity -0.5

### `config/workspaces.lua`

Workspaces 1-5 pinned to `eDP-1`. Workspaces 6-10 are unbound — Hyprland places them dynamically on whichever external monitor is connected. This avoids hardcoding connector names (`HDMI-A-1`, `DP-1`, etc.) that change with port/hardware configuration.

Tradeoff: without explicit bindings, you cannot predict which workspace number lands on which external monitor. In practice, Hyprland fills monitors in order, so workspaces 6-10 appear on the first available external.

### `config/animations.lua`

5 bezier curves and 16 animation leaves covering windows, fades, layers, workspaces, and zoom. All values preserved from the original configuration.

### `config/binds.lua`

46 unique keybindings. No duplicates or conflicts. Three categories of modifier chords:
- `SUPER + key` — applications, focus, window actions
- `SUPER + SHIFT + key` — move window, special workspace, screenshots
- `SUPER + ALT + key` — resize, media apps

Avoids 3-key chords where possible for 34-key keyboard ergonomics.

### `config/media.lua`

10 hardware key bindings for volume, brightness, and media playback. All use `locked = true` to work regardless of focus.

### `config/rules.lua`

3 active window rules:
- **suppress-maximize-events**: global maximize event suppression
- **fix-xwayland-drags**: prevents focus theft from empty XWayland windows
- **move-hyprland-run**: floats and positions the hyprland-run dialog

Plus 2 commented-out smart gaps rules.

### `config/monitors.lua`

Documentation-only. All monitor detection logic lives in `scripts/auto-monitor.sh`.

### `scripts/auto-monitor.sh`

Description-based monitor layout detection using `hyprctl monitors -j` with Python3 JSON parsing. Identifies laptop display (`BOE 0x0AE6`), Arzopa portable monitor (`ARZOPA`), and generic external displays. Falls back to connector-based detection if descriptions don't match. Applies 1 of 4 layouts based on monitor count and identity.

Safety features: 2-second debounce, parse-failure recovery (always keeps laptop alive).

### `scripts/monitor-daemon.sh`

Hotplug polling daemon. Fingerprints monitor topology every second using `hyprctl monitors -j` and `jq`. Compares `name|description` pairs — triggers `auto-monitor.sh` on any change. 2-second initial delay avoids startup race.

Unlike count-based detection, the fingerprint catches: monitor swaps (same count, different description), connector changes (same description, different name), and monitor additions/removals.

### `scripts/randowall.sh`

Picks a random image from `~/stuff/wallpaper.sxnkr/desktop.wall/` and sets it via `awww img` with fade transition.

### `hypridle.conf`

```
21600s (6h)   ──► hyprlock
23400s (6.5h) ──► systemctl suspend
```

### `hyprlock.conf`

Lock screen with: blurred screenshot background (3 passes), 24h clock, date, username, hostname, capsule-shaped password field, bottom hint text. Font: JetBrainsMono Nerd Font throughout.

---

## Dependencies

### Runtime

| Package | Purpose |
|---|---|
| `hyprland` | Compositor |
| `jq` | JSON parsing (monitor daemon) |
| `python3` | JSON parsing (auto-monitor) |
| `waybar` | Status bar |
| `dunst` | Notifications |
| `rofi` | Application launcher / window switcher |
| `alacritty` | Default terminal |
| `pcmanfm` | File manager |
| `cliphist` + `wl-clipboard` | Clipboard manager |
| `awww-daemon` | Wallpaper daemon |
| `hypridle` | Idle management |
| `hyprlock` | Lock screen |
| `nm-applet` | Network manager tray |
| `blueman-applet` | Bluetooth tray |
| `brightnessctl` | Backlight control |
| `playerctl` | Media player control |
| `grim` + `slurp` | Screenshots |
| `firewall-applet` | Firewall tray |
| `polkit-gnome` | Authentication agent |
| `gnome-keyring` | Secret storage |

### Optional

| Package | Purpose |
|---|---|
| `kitty` | Secondary terminal (`SUPER + SHIFT + Return`) |
| `brave` | Browser (`SUPER + B`) |
| `cmus` | Music player (`SUPER + ALT + C`) |

---

## Design Decisions

- **Monitor detection by description, not connector**: Connector names (`HDMI-A-1`, `DP-1`) change with physical ports, docking stations, and kernel behavior. Display descriptions (`BOE 0x0AE6`, `ARZOPA`) are tied to the panel's EDID and follow the monitor across any port.
- **Shell scripts for detection, Lua for config**: Monitor state (what's connected, which layout) is dynamic and best handled by scripts. Lua is used for static declarations (gaps, keybindings, animations).
- **Two-layer monitor system**: `monitor-daemon.sh` detects change events, `auto-monitor.sh` computes and applies the correct layout. Separation of concerns keeps each file simple.
- **Debounce in auto-monitor.sh**: Protects against reconnect storms from docking stations. The daemon itself stays simple — no rate-limiting logic.
- **Workspaces 1-5 pinned, 6-10 dynamic**: Primary workspaces stay on the laptop. External monitors get the remaining workspaces without hardcoded connector names.
- **No three-key chords on Forager**: `SUPER + ALT + SHIFT + key` removed as redundant. Resize uses only `SUPER + ALT + H/J/K/L` — the opposite directions cover both expand and contract.
