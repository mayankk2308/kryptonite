#!/usr/bin/env bash

# ui.sh
# Common user interaction elements in shell.

source "tools.sh"

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
  
  printf "\033[2K\r"
  
  if [[ "${input}" =~ ^[0-9]+$ ]] && 
  [ "${input}" -gt 0 ] && 
  [ "${input}" -le "${#actions[@]}" ]; then
    eval "${actions[(($input - 1))]}"
    return $?
  fi
  
  printfn "Invalid choice."
  return 1
}

# Select item from menu.
ui_menu_select() {
  local prompt="${1}" && shift
  local caller="${1}" && shift
  local actions=("${@}") && shift
  local input=""
  
  local rn1=""
  (( ${#actions[@]} < 10 )) && rn1="-n1"
  
  read -r "${rn1?}" -p "${b}${prompt}${n} [1-${#actions[@]}]: " input
  ui_menu_action "${input}" "${actions[@]}"
  if ui_confirm "Back to menu?"; then
    eval "${caller}"
    return 0
  fi
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