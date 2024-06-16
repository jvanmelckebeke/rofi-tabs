#!/bin/env bash

# This script is a simple tab switcher for rofi. It uses the brotab command to manage tabs

get_clients() {
  # brotab clients returns:
  # <prefix> <host> <pid> <browser>
  # example:
  # a.	localhost:4625	11992	chrome/chromium
  #
  # we need to return prefix and browser
  echo $(bt clients | awk '{print $1, $4}')
}

focus_window() {
  # uses i3-msg to focus the window with the given title
  # $1 is the title of the window
  
  escaped_title=$(echo "$1" | sed 's/"/\\"/g')

  output=$(i3-msg "[title=\"$escaped_title\"] focus")
}

get_tabs() {
  # brotab list returns:
  # <prefix> <tab title> <url>
  # return only tab title

  tabs=$(bt list | awk -F '\t' '{printf "%s\n", $2}')

  echo "New Tab"

  echo "$tabs"

}

# if the script gets called with a non-empty argument then we want to switch to that tab
if [ -n "$@" ] && [ ! -z "$@" ]; then

  # check if the argument is not empty

  # get the tab title
  tab_title=$(echo "$@")

  # if the tab title is "New Tab" then we want to open a new tab
  if [ "$tab_title" = "New Tab" ]; then
    bt new
  else
    # otherwise we want to switch to the tab
    # first we need to get the prefix
    prefix=$(bt list | grep "$tab_title" | awk '{print $1}')
    bt activate "$prefix"
    focus_window "$tab_title"
  fi
  exit 0
else
  # if the script is called without an argument then we want to list the tabs
  get_tabs

fi
