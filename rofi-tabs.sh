#!/bin/env bash

# This script is a simple tab switcher for rofi. It uses the brotab command to manage tabs

detect_wm() {
  # Detect the currently running window manager
  if [ ! -z "$XDG_CURRENT_DESKTOP" ]; then
    echo "$XDG_CURRENT_DESKTOP"
  elif [ ! -z "$DESKTOP_SESSION" ]; then
    echo "$DESKTOP_SESSION"
  else
    wmctrl -m | grep -oP '(?<=Name: )\w+'
  fi
}

focus_window() {
  # Focus the window with the given title using the appropriate command for the detected window manager
  local title="$1"
  local wm="$2"
  local escaped_title

  escaped_title=$(echo "$title" | sed 's/"/\\"/g')

  case "$wm" in
    i3|i3wm)
      i3-msg "[title=\"$escaped_title\"] focus" &> /dev/null
      ;;
    sway)
      swaymsg "[title=\"$escaped_title\"] focus" &> /dev/null
      ;;
    GNOME|gnome)
      wmctrl -a "$title"
      ;;
    KDE|kde|plasma)
      qdbus org.kde.KWin /KWin org.kde.KWin.activateWindow "$(qdbus org.kde.KWin /KWin org.kde.KWin.windowForTitle "$title")"
      ;;
    *)
      echo "Window manager not supported: $wm" >&2
      ;;
  esac
}

get_tabs() {
  # brotab list returns:
  # <prefix> <tab title> <url>
  # return only tab title

  local tabs
  tabs=$(bt list | awk -F '\t' '{print $2}')
  
  echo "$tabs"
}

switch_to_tab() {
  local tab_title="$1"
  local wm="$2"

  local prefix
  prefix=$(bt list | grep -F "$tab_title" | awk '{print $1}')
  if [ -n "$prefix" ]; then
    bt activate "$prefix"
    focus_window "$tab_title" "$wm"
  else
    echo "Tab not found: $tab_title" >&2
    exit 1
  fi
}

# Detect the current window manager
wm=$(detect_wm)

# if the script gets called with a non-empty argument then we want to switch to that tab
if [ -n "$1" ]; then
  switch_to_tab "$1" "$wm"
else
  # if the script is called without an argument then we want to list the tabs
  get_tabs
fi

