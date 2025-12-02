#!/bin/bash

WALLDIR="$HOME/Pictures/wallpapers"

# file that stores current index
INDEXFILE="$HOME/.cache/swww_wall_index"
mkdir -p "$(dirname "$INDEXFILE")"

# if no index exists, start at 0
if [ ! -f "$INDEXFILE" ]; then
    echo 0 > "$INDEXFILE"
fi

# read/compute next index
i=$(cat "$INDEXFILE")
files=("$WALLDIR"/*)
count=${#files[@]}

# choose wallpaper
next=$(( (i + 1) % count ))
echo $next > "$INDEXFILE"

# set with animation
swww img "${files[$next]}" --transition-type grow --transition-step 50

