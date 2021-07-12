#!/bin/bash

# ui.sh
# Common user interaction elements in shell.

source "tools.sh"

ui_menu_selected="-1"

# Confirm action before proceeding.
ui_confirm() {
  local prompt="${1}"
  local input=""
  
  read -r -n1 -p "${b}${prompt}${n} [Y/N]: " input
  printf "\033[2K\r"
  
  { [ "${input}" = "Y" ] || [ "${input}" = "y" ]; } && return 0
  { [ "${input}" = "N" ] || [ "${input}" = "n" ]; } && return 1
  
  printfn "Invalid choice. Please try again.\n"
  ui_confirm "${prompt}"
}

# Take action on menu input.
ui_menu_action() {
  local input="${1}" && shift
  local actions=("${@}")
  
  eval "${actions[${input}]}"
}

# Select item from menu and return index.
ui_menu_select() {
  local prompt="${1}" && shift
  local items=("${@}") && shift
  local input=""
  
  local rn="100"
  (( ${#items[@]} < 10 )) && rn="1"
  
  read -r -n "${rn}" -p "${b}${prompt}${n} [1-${#items[@]}]: " input
  printf "\033[2K\r"
  
  if [[ ! "${input}" =~ ^[0-9]+$ ]] || 
  [ "${input}" -lt 1 ] || 
  [ "${input}" -gt "${#items[@]}" ]; then
    ui_menu_selected="-1"
    return
  fi
  
  ui_menu_selected=$(( input - 1 ))
}

# Show a menu for item selection.
ui_menu_show() {
  local title="${1}" && shift
  local split_at="${1}" && shift
  local items=("${@}")
  
  printfn ">> ${b}${title}${n}\n"
  for (( i = 0; i < ${#items[@]}; i++ )); do
    local num=$(( i + 1 ))
    printfn "${b}${num}${n}. ${items[${i}]}"
    [ "${num}" = "${split_at}" ] && printfn
  done
  printfn
}