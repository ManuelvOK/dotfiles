~/dotfiles/scripts/rescreen.sh --start
~/dotfiles/scripts/keyboard_conf.sh
xrdb -merge ~/.Xresources
systemctl --user import-environment DISPLAY XAUTHORITY
dbus-update-activation-environment --systemd DISPLAY XAUTHORITY
slstatus &
xautolock -time 10 -locker slock &
exec dwm
