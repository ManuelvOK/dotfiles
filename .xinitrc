# hand DISPLAY and XAUTHORITY to systemd and D-Bus (Arch default)
for f in /etc/X11/xinit/xinitrc.d/?*.sh; do . "$f"; done

# screens, see ~/.config/autorandr/settings.ini. autorandr.service follows
# hotplugs later.
autorandr --change
~/dotfiles/scripts/keyboard_conf.sh
xrdb -merge ~/.Xresources
systemctl --user start dwm-session.target
dwmblocks &
# lock after 10 minutes without input (X screen saver) and before suspend.
# Started here, not as a user service: xss-lock finds its logind session
# through its own PID, and user services run outside the session.
xset s 600
xss-lock -- slock &
dwm
systemctl --user stop dwm-session.target
