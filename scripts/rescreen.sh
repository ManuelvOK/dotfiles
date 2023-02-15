#!/bin/bash
#
readarray -td$'\n' connected_devices <<<"$(xrandr | grep " connected " | awk '{ print$1 }')"

if [[ $1 == "--start" ]] ;then
    cmd=(xrandr
        --output "${connected_devices[0]}" --mode 1920x1080 --pos 0x1080 --rotate normal
        --output "${connected_devices[1]}" --off
        --output "${connected_devices[2]}" --off
    )
    "${cmd[@]}"
fi

cmd=(xrandr
     --output "${connected_devices[0]}" --mode 1920x1080 --pos 0x1080 --rotate normal
     --output "${connected_devices[1]}" --primary --mode 1920x1080 --pos 1255x0 --rotate normal
     --output "${connected_devices[2]}" --mode 1920x1080 --pos 3175x0 --rotate normal
)

readarray -td$'\n' disconnected_devices <<<"$(xrandr | grep " disconnected " | awk '{ print $1 }')"
for device in "${disconnected_devices[@]}"; do
    cmd+=(--output "$device" --off)
done

"${cmd[@]}"

xset r rate 300 55
setxkbmap -option 'ctrl:nocaps'
a=52;b=29;c=xmodmap;d="$c -e '";$c -pke | sed -nr "s/^(keycode *)$b(.*)/$d\1$a\2'/p;t;s/^(keycode *)$a(.*)/$d\1$b\2'/p" | sh
