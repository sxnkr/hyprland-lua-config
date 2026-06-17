#!/bin/bash

WALL_DIR="$HOME/stuff/wallpaper.sxnkr/desktop.wall"
WALL=$(find "$WALL_DIR" -type f | shuf -n1)

awww img "$WALL" --transition-type fade
