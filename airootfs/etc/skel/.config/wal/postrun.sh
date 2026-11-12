#!/bin/bash
mkdir -p ~/.local/share/dark ~/.local/share/light
cp ~/.cache/wal/rewaita-pywal.css ~/.local/share/dark/pywal.css
cp ~/.cache/wal/rewaita-pywal.css ~/.local/share/light/pywal.css
rewaita --theme=pywal
