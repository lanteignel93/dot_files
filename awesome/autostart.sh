#!/bin/zsh

run() {
    if ! pgrep -f "$1"; then
        "$@" &
    fi
}
run "xrandr" --output DP-2 --right-of HDMI-1 
run "nitrogen" --restore
run "compton"
