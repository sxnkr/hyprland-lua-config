#!/usr/bin/env bash
# auto-monitor.sh — description-based monitor layout detection
#
# Dependencies: python3 (for JSON parsing)
#
# Identifies monitors by display description (not connector name),
# then applies the correct layout for the detected combination.
#
# Layout rules:
#   1 monitor   → Laptop only
#   2 monitors  → Laptop + Arzopa (portrait) or Laptop + Desktop
#   3+ monitors → Arzopa (portrait) + Laptop + Desktop
#
# Edge cases handled:
#   - Debounce: skips if called more than once per 2 seconds
#   - Parse failure: falls back to laptop-only safe state
#   - Unknown monitor: treats as generic external display
#   - Connector change: matches by description, not connector name

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
eval "$(hyprctl monitors -j | python3 -c "
import json, sys

try:
    monitors = json.load(sys.stdin)
except Exception:
    print('PARSE_ERROR=1')
    sys.exit(0)

if not monitors:
    print('PARSE_ERROR=1')
    sys.exit(0)

def pick(desc_filter):
    for m in monitors:
        if desc_filter in m.get('description', ''):
            return m['name']
    return ''

def pick_other(exclude1, exclude2):
    for m in monitors:
        d = m.get('description', '')
        if exclude1 not in d and exclude2 not in d.upper():
            return m['name']
    return ''

laptop = pick('BOE 0x0AE6')
arzopa = pick('ARZOPA')
other  = pick_other('BOE 0x0AE6', 'ARZOPA')
count  = len(monitors)

# Fallback: connector-based if description matching fails
if not laptop:
    for m in monitors:
        if m['name'].startswith('eDP'):
            laptop = m['name']
            break
    if not laptop:
        laptop = monitors[0]['name']

if not arzopa and not other and count == 2:
    for m in monitors:
        if m['name'] != laptop:
            other = m['name']
            break

print(f'count={count}')
print(f'laptop={laptop}')
print(f'arzopa={arzopa}')
print(f'other={other}')
print('PARSE_ERROR=0')
")"

# ── Safety: JSON parse failure → keep laptop alive ───
if [ "$PARSE_ERROR" = "1" ]; then
  hyprctl eval "hl.monitor({ output = \"eDP-1\", mode = \"preferred\", position = \"0x0\", scale = 1.25 })"
  exit 0
fi

# ── Apply layout ─────────────────────────────────────
apply_layout() {
  local laptop="$1" arzopa="$2" other="$3" count="$4"

  if [ "$count" -eq 1 ]; then
    hyprctl eval "hl.monitor({ output = \"$laptop\", mode = \"preferred\", position = \"0x0\", scale = 1.25 })"

  elif [ "$count" -eq 2 ]; then
    if [ -n "$arzopa" ]; then
      hyprctl eval "hl.monitor({ output = \"$laptop\", mode = \"preferred\", position = \"0x0\", scale = 1.25 })"
      hyprctl eval "hl.monitor({ output = \"$arzopa\", mode = \"preferred\", position = \"auto-right\", scale = 1.25, transform = 1 })"
    else
      hyprctl eval "hl.monitor({ output = \"$laptop\", mode = \"preferred\", position = \"0x0\", scale = 1.25 })"
      hyprctl eval "hl.monitor({ output = \"$other\", mode = \"preferred\", position = \"auto-right\", scale = 1 })"
    fi

  elif [ "$count" -ge 3 ]; then
    hyprctl eval "hl.monitor({ output = \"$arzopa\", mode = \"preferred\", position = \"0x0\", scale = 1.25, transform = 1 })"
    hyprctl eval "hl.monitor({ output = \"$laptop\", mode = \"preferred\", position = \"auto-right\", scale = 1.25 })"
    hyprctl eval "hl.monitor({ output = \"$other\", mode = \"preferred\", position = \"auto-right\", scale = 1 })"
  fi
}

apply_layout "$laptop" "$arzopa" "$other" "$count"
