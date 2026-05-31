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
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/customize_airootfs.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/etc/sudoers.d/g_wheel"]="0:0:755"
  ##########CUSTOM##########
  ["/etc/default/useradd"]="0:0:755"
  ["/etc/firefox/policies/policies.json"]="0:0:755"
  ["/usr/share/firefox-extensions/pywalfox.xpi"]="0:0:755"
  ["/usr/local/bin/awww.sh"]="0:0:755"
  ["/usr/local/bin/binds.sh"]="0:0:755"
  ["/usr/local/bin/binds.py"]="0:0:755"
  ["/usr/local/bin/bt.sh"]="0:0:755"
  ["/usr/local/bin/font.sh"]="0:0:755"
  ["/usr/local/bin/net-stats.py"]="0:0:755"
  ["/usr/local/bin/net-toggle.sh"]="0:0:755"
  ["/usr/local/bin/netman.sh"]="0:0:755"
  ["/usr/local/bin/power.sh"]="0:0:755"
  ["/usr/local/bin/pulse.sh"]="0:0:755"
  ["/usr/local/bin/salaat.py"]="0:0:755"
  ["/usr/local/bin/tokyo-night.sh"]="0:0:755"
  ["/usr/local/bin/volume.sh"]="0:0:755"
  ["/usr/local/bin/waybar.sh"]="0:0:755"
  ["/usr/local/bin/welcome.sh"]="0:0:755"
  ["/etc/skel/.config/rofi/launcher/launcher.sh"]="0:0:755"
  ["/usr/local/share/themes/tokyo-night/tokyo-night.sh"]="0:0:755"
)
