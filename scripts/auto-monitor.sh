#!/usr/bin/env bash
# auto-monitor.sh — connector-based monitor layout detection
#
# Dependencies: python3 (for JSON parsing)
#
# Identifies the laptop panel by connector name (eDP-* / LVDS-*),
# the Arzopa portable monitor by description, and everything else
# as generic external displays. Applies the correct layout for
# the detected combination.
#
# This approach works across different laptops with different
# internal panel descriptions.
#
# Layout rules:
#   1 monitor   → Laptop only
#   2 monitors  → Laptop + Arzopa, or Laptop + External
#   3+ monitors → Arzopa (portrait) + Laptop + External(s)
#
# Edge cases handled:
#   - Debounce: skips if called more than once per 2 seconds
#   - Parse failure: falls back to laptop-only safe state
#   - Unknown monitor: treats as generic external display
#   - Multiple externals: chained via auto-right

# ── Debounce ──────────────────────────────────────────
LAST_RUN="${XDG_RUNTIME_DIR}/hypr-monitor-lastrun"
if [ -f "$LAST_RUN" ]; then
  last=$(cat "$LAST_RUN")
  now=$(date +%s)
  if [ "$((now - last))" -lt 2 ]; then
    exit 0
  fi
fi
printf '%s' "$(date +%s)" > "$LAST_RUN"

# ── Detect monitors ──────────────────────────────────
hyprctl monitors -j | python3 -c '
import json, sys

try:
    monitors = json.load(sys.stdin)
except Exception:
    print("PARSE_ERROR=1")
    sys.exit(0)

if not monitors:
    print("PARSE_ERROR=1")
    sys.exit(0)

laptop = ""
arzopa = ""
externals = []

for m in monitors:
    name = m["name"]
    desc = m.get("description", "")
    if name.startswith("eDP") or name.startswith("LVDS"):
        laptop = name
    elif "ARZOPA" in desc.upper():
        arzopa = name
    else:
        externals.append(name)

if not laptop:
    laptop = monitors[0]["name"]

count = len(monitors)
ext_str = " ".join(externals)

print(f"count={count}")
print(f"laptop={laptop}")
print(f"arzopa={arzopa}")
print(f"externals={ext_str}")
print("PARSE_ERROR=0")
' > /tmp/hypr-monitors.cfg

source /tmp/hypr-monitors.cfg

# ── Safety: JSON parse failure → keep laptop alive ───
if [ "$PARSE_ERROR" = "1" ]; then
  hyprctl eval "hl.monitor({ output = \"eDP-1\", mode = \"preferred\", position = \"0x0\", scale = 1 })"
  exit 0
fi

# ── Apply layout ─────────────────────────────────────
apply_layout() {
  local laptop="$1" arzopa="$2" count="$3"
  shift 3
  local externals=("$@")

  if [ "$count" -eq 1 ]; then
    hyprctl eval "hl.monitor({ output = \"$laptop\", mode = \"preferred\", position = \"0x0\", scale = 1 })"

  elif [ "$count" -eq 2 ]; then
    if [ -n "$arzopa" ]; then
      hyprctl eval "hl.monitor({ output = \"$laptop\", mode = \"preferred\", position = \"0x0\", scale = 1 })"
      hyprctl eval "hl.monitor({ output = \"$arzopa\", mode = \"preferred\", position = \"auto-right\", scale = 1 ,transform=1})"
    else
      hyprctl eval "hl.monitor({ output = \"$laptop\", mode = \"preferred\", position = \"0x0\", scale = 1 })"
      hyprctl eval "hl.monitor({ output = \"${externals[0]}\", mode = \"preferred\", position = \"auto-right\", scale = 1 })"
    fi

  elif [ "$count" -ge 3 ]; then
    if [ -n "$arzopa" ]; then
      hyprctl eval "hl.monitor({ output = \"$arzopa\", mode = \"preferred\", position = \"0x0\", scale = 1, transform = 1 })"
      hyprctl eval "hl.monitor({ output = \"$laptop\", mode = \"preferred\", position = \"auto-right\", scale = 1 })"
      for ext in "${externals[@]}"; do
        hyprctl eval "hl.monitor({ output = \"$ext\", mode = \"preferred\", position = \"auto-right\", scale = 1 })"
      done
    else
      hyprctl eval "hl.monitor({ output = \"$laptop\", mode = \"preferred\", position = \"0x0\", scale = 1 })"
      for ext in "${externals[@]}"; do
        hyprctl eval "hl.monitor({ output = \"$ext\", mode = \"preferred\", position = \"auto-right\", scale = 1 })"
      done
    fi
  fi
}

apply_layout "$laptop" "$arzopa" "$count" $externals

# Restart waybar for per-output configs
~/.config/waybar/start-waybar.sh
