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

OUTPUT1_MODE=1920x1080
OUTPUT0_POS=0x1080
OUTPUT2_POS=3175x0
xrandr --dryrun --output "${connected_devices[1]}" --mode 2560x1440 >/dev/null 2>&1
if [[ $? -ne 1 ]] ;then
    echo "output 1 is big"
    OUTPUT1_MODE=2560x1440
    OUTPUT0_POS=0x1440
    OUTPUT2_POS=3815x0
fi

cmd=(xrandr
     --output "${connected_devices[0]}" --mode 1920x1080 --pos "$OUTPUT0_POS" --rotate normal
     --output "${connected_devices[1]}" --primary --mode "$OUTPUT1_MODE" --pos 1255x0 --rotate normal
     --output "${connected_devices[2]}" --mode 1920x1080 --pos "$OUTPUT2_POS" --rotate normal
)

readarray -td$'\n' disconnected_devices <<<"$(xrandr | grep " disconnected " | awk '{ print $1 }')"
for device in "${disconnected_devices[@]}"; do
    cmd+=(--output "$device" --off)
done

"${cmd[@]}"
