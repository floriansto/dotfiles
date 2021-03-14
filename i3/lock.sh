#!/bin/bash
scrot /tmp/screen.png
convert /tmp/screen.png -scale 10% -scale 1000% /tmp/screen.png
[[ -f ~/.config/i3/lock.png ]] && convert /tmp/screen.png ~/.config/i3/lock.png -gravity center -composite -matte /tmp/screen.png
playerctl pause
i3lock -i /tmp/screen.png
rm /tmp/screen.png

