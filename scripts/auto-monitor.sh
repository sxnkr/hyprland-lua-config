#!/usr/bin/env bash
connected=$(hyprctl monitors all | grep -c "(ID [0-9]")

if [ "$connected" -gt 1 ]; then
  hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1.25 })'
  hyprctl eval 'hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto-right", scale = 1.25 })'
else
  hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1.25 })'
fi
