#!/usr/bin/env bash
# usage: media.sh play-pause|pause|next|prev
# Controls the media player that is playing right now, otherwise the first
# one playerctl knows (Spotify, browsers with YouTube, mpv, ...).

player() {
	local p
	for p in $(playerctl -l 2>/dev/null); do
		if [ "$(playerctl -p "$p" status 2>/dev/null)" = Playing ]; then
			echo "$p"
			return
		fi
	done
	playerctl -l 2>/dev/null | head -n 1
}

case "$1" in
	play-pause) cmd=play-pause ;;
	pause)      cmd=pause ;;
	next)       cmd=next ;;
	prev)       cmd=previous ;;
	*)          echo "usage: ${0##*/} play-pause|pause|next|prev" >&2; exit 1 ;;
esac

p=$(player)
[ -n "$p" ] && playerctl -p "$p" "$cmd"

# refresh the music block of dwmblocks (signal 6 in its config.h)
pkill -RTMIN+6 -x dwmblocks
exit 0
