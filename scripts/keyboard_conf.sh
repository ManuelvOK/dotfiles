#!/usr/bin/env bash
#
# Keyboard setup for the X session, run by keyboard.service:
# - the DYGMA DEFY at the home dock gets eu as it is
# - every other keyboard gets gb with y and z swapped
#   (~/.config/xkb/keycodes/yz) and Caps Lock as Ctrl
# - key repeat after 300 ms, 55 per second
# With --watch it keeps running and does it all again whenever an input
# device comes or goes, because a new keyboard starts with the server
# defaults.

# keyboards with their own layout and nothing else, by the name `xinput list`
# shows
declare -A layouts=(["DYGMA DEFY Keyboard"]=eu)

apply() {
	local id name keycodes options

	xinput list --short |
	sed -n 's/^.*↳ \(.*[^[:space:]]\)[[:space:]]*id=\([0-9]*\)[[:space:]]*\[slave  keyboard.*/\2 \1/p' |
	while read -r id name; do
		[[ $name == *XTEST* ]] && continue
		keycodes=+yz\(swap\) options=ctrl:nocaps
		[[ ${layouts[$name]} ]] && keycodes= options=
		# the keymap setxkbmap would load, with the swap added, for this
		# device only
		setxkbmap -layout "${layouts[$name]:-gb}" -option -option "$options" -print |
		sed "s/\(xkb_keycodes *{ *include \"[^\"]*\)\"/\1$keycodes\"/" |
		xkbcomp -w0 -I"$HOME/.config/xkb" -i "$id" - "$DISPLAY"
	done
	xset r rate 300 55
}

apply
[[ $1 == --watch ]] || exit 0

# test-xi2 prints every event on the root window, grep keeps the device
# changes. Plugging in a keyboard adds several devices: wait a second and
# drop the events that came in meanwhile.
xinput test-xi2 --root | grep --line-buffered '(HierarchyChanged)' |
while read -r _; do
	sleep 1
	while read -r -t 0.1 _; do :; done
	apply
done
