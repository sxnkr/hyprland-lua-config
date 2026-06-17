#!/usr/bin/env bash
# Dependencies: jq
#
# Monitors topology changes by fingerprinting monitor name + description
# from Hyprland's structured JSON output. Triggers auto-monitor.sh when
# the fingerprint changes.

sleep 2

fingerprint=$(hyprctl monitors -j | jq -r '.[] | "\(.name)|\(.description)"' | sort)

while true; do
  sleep 1
  new_fingerprint=$(hyprctl monitors -j | jq -r '.[] | "\(.name)|\(.description)"' | sort)
  if [ "$new_fingerprint" != "$fingerprint" ]; then
    ~/.config/hypr/scripts/auto-monitor.sh
    fingerprint=$new_fingerprint
  fi
done
