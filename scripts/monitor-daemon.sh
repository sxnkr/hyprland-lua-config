#!/usr/bin/env bash
sleep 2
while true; do
  previous=$(hyprctl monitors all | grep -c "(ID [0-9]")
  sleep 1
  current=$(hyprctl monitors all | grep -c "(ID [0-9]")
  if [ "$current" -ne "$previous" ]; then
    ~/.config/hypr/scripts/auto-monitor.sh
  fi
done
