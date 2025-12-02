#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
CURRENT_WALL="$HOME/.cache/current_wall"

# Grab all wallpapers
mapfile -t WALLS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | sort)

TOTAL=${#WALLS[@]}
[[ $TOTAL -eq 0 ]] && exit 1

# Read last used wallpaper index
if [[ -f "$CURRENT_WALL" ]]; then
    INDEX=$(cat "$CURRENT_WALL")
else
    INDEX=0
fi

# Next wallpaper
NEXT=$(( (INDEX + 1) % TOTAL ))

# Show wallpaper
swww img "${WALLS[$NEXT]}" --transition-type wipe --transition-duration 1 --transition-fps 60

# Save index
echo $NEXT > "$CURRENT_WALL"

