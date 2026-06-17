# Hyprland Configuration

Modular Lua-based configuration for Hyprland on Arch Linux.

## Structure

```
~/.config/hypr/
├── hyprland.lua          # Root entry point
├── config/
│   ├── env.lua           # Environment variables
│   ├── monitors.lua      # Monitor layout
│   ├── autostart.lua     # Startup programs
│   ├── appearance.lua    # General, decoration, misc
│   ├── input.lua         # Input, touchpad, gesture, device
│   ├── workspaces.lua    # Workspace-to-monitor assignments
│   ├── animations.lua    # Curves and animation leaves
│   ├── binds.lua         # Keybindings
│   ├── media.lua         # Media/hardware keys
│   └── rules.lua         # Window rules
├── hypridle.conf
├── hyprlock.conf
└── scripts/
    ├── auto-monitor.sh
    ├── monitor-daemon.sh
    └── randowall.sh
```

## Startup

```bash
start-hyprland
```

## Dependencies

| Package | Purpose |
|---|---|
| `hyprland` | Compositor |
| `waybar` | Status bar |
| `dunst` | Notifications |
| `rofi` | Application launcher |
| `alacritty` | Terminal |
| `pcmanfm` | File manager |
| `cliphist` | Clipboard manager |
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

## Keybindings

Mod key: `SUPER`

### Applications

| Key | Action |
|---|---|
| `SUPER + Return` | Alacritty |
| `SUPER + SHIFT + Return` | Kitty |
| `SUPER + Space` | Rofi launcher |
| `SUPER + B` | Brave |
| `SUPER + E` | PCManFM |
| `SUPER + V` | Clipboard history |
| `SUPER + ALT + C` | cmus |
| `SUPER + ALT + R` | Random wallpaper |
| `SUPER + W` | Rofi window switcher |

### Window Management

| Key | Action |
|---|---|
| `SUPER + Q` | Close window |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + S` | Toggle floating |
| `SUPER + P` | Toggle pseudo tiling |
| `SUPER + M` | Toggle split layout |
| `SUPER + H/J/K/L` | Focus left/down/up/right |
| `SUPER + SHIFT + H/J/K/L` | Move window |
| `SUPER + ALT + H/J/K/L` | Resize window |

### Workspaces

| Key | Action |
|---|---|
| `SUPER + 1..0` | Switch to workspace |
| `SUPER + SHIFT + 1..0` | Move window to workspace |
| `SUPER + Tab` | Previous workspace |
| `SUPER + [` / `SUPER + ]` | Cycle workspaces |
| `SUPER + mouse_down/up` | Cycle workspaces |

### Scratchpad

| Key | Action |
|---|---|
| `SUPER + I` | Toggle special (hidden) |
| `SUPER + SHIFT + I` | Move to special (hidden) |
| `SUPER + grave` | Toggle special (magic) |
| `SUPER + SHIFT + grave` | Move to special (magic) |

### System

| Key | Action |
|---|---|
| `SUPER + R` | Reload Hyprland |
| `SUPER + SHIFT + X` | Lock screen |
| `Print` | Full screenshot |
| `SUPER + SHIFT + S` | Area screenshot |

### Media Keys (locked)

| Key | Action |
|---|---|
| `XF86AudioRaiseVolume` | Volume +5% |
| `XF86AudioLowerVolume` | Volume -5% |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle mic mute |
| `XF86MonBrightnessUp` | Brightness +5% |
| `XF86MonBrightnessDown` | Brightness -5% |
| `XF86AudioNext/Pause/Play/Prev` | Media control |

## Idle

| Timeout | Action |
|---|---|
| 300s (5 min) | Lock screen |
| 900s (15 min) | Suspend |

## Monitor Setup

Two monitors: `eDP-1` (internal) and `HDMI-A-1` (external).

Workspaces 1-5 on eDP-1, workspaces 6-10 on HDMI-A-1.

Auto-detection handled by `scripts/auto-monitor.sh` and `scripts/monitor-daemon.sh`.

## Wallpaper

Handled by `awww-daemon` and `scripts/randowall.sh` (random image from `~/stuff/wallpaper.sxnkr/desktop.wall/`).

## Notes

- Designed for a **34-key Forager split keyboard** — home-row navigation, minimal finger travel, no three-key chords where avoidable.
- Mouse bindings (`SUPER + drag`, `SHIFT + arrows`) for floating window management.
