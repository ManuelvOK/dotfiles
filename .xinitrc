~/dotfiles/scripts/rescreen.sh
xrdb -merge ~/.Xresources
slstatus &
exec dwm
