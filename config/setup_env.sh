#!/usr/bin/env bash
# Setup script used for use settings after i3 launch 

# Disable natural scrolling
NATURAL_SCROLL_ID=$(xinput list-props 8 | grep '^.*Natural Scrolling Enabled (' | sed 's/.*(\(.*\)).*/\1/g')
xinput set-prop 8 ${NATURAL_SCROLL_ID} 0

# Increase mouse acceleration speed
MOUSE_ACCEL_ID=$(xinput list-props 8 | grep '^.*Accel Speed (' | sed 's/.*(\(.*\)).*/\1/g')
xinput set-prop 8 ${MOUSE_ACCEL_ID} 0.75

# Swap ctrl and cmd(win)
#xmodmap ~/.config/xmodmap/.xmodmap

# Set caps_lock to ctrl as modifier, esc as default
setxkbmap -option 'caps:ctrl_modifier'
xcape -e 'Caps_Lock=Escape;Control_L=Escape;Control_R=Escape'
