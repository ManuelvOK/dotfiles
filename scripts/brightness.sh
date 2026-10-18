#!/usr/bin/env bash
# usage: brightness.sh up|down
step=25

case "$1" in
	up)   brightnessctl -q set "+$step" ;;
	down) brightnessctl -q set "$step-" ;;
	*)    echo "usage: ${0##*/} up|down" >&2; exit 1 ;;
esac
