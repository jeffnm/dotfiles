#!/bin/bash

# Runs polybar

killall polybar &>/dev/null;

polybar -c ~/.config/polybar/config bar1 &
polybar -c ~/.config/polybar/config bar2 &

exit 0
