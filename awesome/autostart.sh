#!/bin/zsh

run() {
    if ! pgrep -f "$1"; then
        "$@" &
    fi
}
run "nitrogen" --restore
run "compton"
