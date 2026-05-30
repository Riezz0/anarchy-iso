#!/bin/bash

useradd -m -G wheel,audio,video,input,network liveuser

passwd -d liveuser

chown -R liveuser:liveuser /home/liveuser

systemctl enable NetworkManager
systemctl enable sddm
