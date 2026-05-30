#!/usr/bin/env bash
kitty --class="Themer" \
      --title="Theme Selector" \
      -e bash -c "/home/$USER/.config/hypr/themer.sh; echo 'Press Enter to close...'; read" 2>/dev/null
