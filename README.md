# Hyprland UWSM Arch live ISO

An Archiso `releng` profile customized with a Hyprland desktop session launched
through UWSM. It is a separate profile; the existing `anarchy-iso` tree is not
used as the build source.

## Build

Install `archiso`, then run from this directory:

```sh
sudo mkarchiso -v -w work -o out .
```

The generated ISO is written to `out/`.

## Live session

- SDDM starts automatically and signs in as `liveuser` to
  `hyprland-uwsm.desktop`.
- The live account is created at boot with an empty password and passwordless
  sudo. This is intended only for a disposable live environment; do not reuse
  the configuration for an installed system.
- Hyprland starts Waybar and a PolicyKit agent. `Super+Enter` opens Kitty,
  `Super+D` opens Wofi, `Super+Q` closes the focused window, and `Super+M`
  exits the session.
