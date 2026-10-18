#!/bin/bash
#
xset r rate 300 55
setxkbmap -option 'ctrl:nocaps'
a=52;b=29;c=xmodmap;d="$c -e '";$c -pke | sed -nr "s/^(keycode *)$b(.*)/$d\1$a\2'/p;t;s/^(keycode *)$a(.*)/$d\1$b\2'/p" | sh
