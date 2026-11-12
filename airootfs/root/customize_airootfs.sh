#!/usr/bin/env bash
# Runs inside the ISO chroot after pacstrap and after /etc/skel has been copied
# into the user homes. mkarchiso executes and then deletes this script.
#
# Purpose: make the paths that the live session writes to as `liveuser`
# writable by that user, without loosening permissions on the whole system.
# These paths are created by packages (or do not exist yet) at the time
# iso_build.sh runs, so they can only be fixed here, inside the chroot.
set -Eeuo pipefail

LIVE_USER=liveuser

log() {
    printf '[customize_airootfs] %s\n' "$*"
}

# Resolve the live user's numeric ids. If the account is missing there is
# nothing to fix; stop early instead of creating root-owned directories.
if ! getent passwd "$LIVE_USER" >/dev/null; then
    printf '[customize_airootfs] User %s does not exist, nothing to do\n' "$LIVE_USER"
    exit 0
fi
LIVE_UID="$(id -u "$LIVE_USER")"
LIVE_GID="$(id -g "$LIVE_USER")"

# sddm ships /usr/lib/sysusers.d/sddm.conf, so the group normally exists once
# pacstrap has installed it. Create it defensively so the ownership below does
# not fail on a chroot where sysusers did not run.
if ! getent group sddm >/dev/null; then
    if command -v groupadd >/dev/null; then
        groupadd --system sddm
        log "Created missing sddm group"
    else
        printf '[customize_airootfs] sddm group missing and groupadd unavailable\n' >&2
        exit 1
    fi
fi
SDDM_GID="$(getent group sddm | cut -d: -f3)"

# /usr/share/icons/default is where Xcursor looks for the default cursor theme.
# It is normally owned by default-cursors, which this ISO does not install, but
# set-cursor-theme.sh writes index.theme there at runtime. Hand the directory to
# liveuser so that write succeeds.
install -d -m 0755 -o "$LIVE_UID" -g "$LIVE_GID" /usr/share/icons/default
if [[ -f /usr/share/icons/default/index.theme ]]; then
    chown "$LIVE_UID:$LIVE_GID" /usr/share/icons/default/index.theme
    chmod u+rwX,g+rX,o+rX /usr/share/icons/default/index.theme
fi
log "Prepared /usr/share/icons/default for $LIVE_USER"

# Theme scripts copy the wallpaper and the generated Pywal colours here so the
# SDDM greeter can display them. liveuser must be able to write, sddm must be
# able to read; group-writable keeps both working without making it world-writable.
install -d -m 0775 -o "$LIVE_UID" -g "$SDDM_GID" /var/local/sddm-wallpaper
chown -R "$LIVE_UID:$SDDM_GID" /var/local/sddm-wallpaper
chmod -R u+rwX,g+rwX,o+rX /var/local/sddm-wallpaper
log "Prepared /var/local/sddm-wallpaper for $LIVE_USER:sddm"

# Some dotfile setups rewrite /etc/sddm.conf when switching themes. The live
# profile does not ship one (SDDM reads its packaged default), so only fix it
# when it is actually present.
if [[ -e /etc/sddm.conf ]]; then
    chown "$LIVE_UID:$SDDM_GID" /etc/sddm.conf
    chmod u+rwX,g+rwX,o+rX /etc/sddm.conf
    log "Prepared /etc/sddm.conf for $LIVE_USER:sddm"
else
    log "No /etc/sddm.conf in the live profile, skipping"
fi
