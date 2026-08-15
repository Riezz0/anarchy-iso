#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="archlinux"
iso_label="ARCH_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Arch Linux <https://archlinux.org>"
iso_application="Arch Linux Live/Rescue DVD"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.systemd-boot')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/gshadow"]="0:0:0"
  ["/etc/shadow"]="0:0:400"
  ["/etc/sudoers.d"]="0:0:0"
  ["/etc/sudoers.d/liveuser"]="0:0:440"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/usr/local/bin/awww.sh"]="0:0:755"
  ["/usr/local/bin/anarchy-start.sh"]="0:0:755"
  ["/usr/local/bin/anarchy-installer.sh"]="0:0:755"
  ["/usr/local/bin/qbarmain.sh"]="0:0:755"
  ["/usr/local/bin/welcome.sh"]="0:0:755"
  ["/etc/skel/.config/rofi/launcher/launcher.sh"]="0:0:755"
  ["/etc/skel/.config/.hypr-themes/tokyo-night/tokyo-night.sh"]="0:0:755"
  ["/etc/skel/.local/share/themes/hypr-theme-active.sh"]="0:0:755"
  ["/etc/skel/.config/quickshell/scripts/wf-recorder.sh"]="0:0:755"
  ["/var/local/sddm-wallpaper"]="1000:sddm:775"
)
