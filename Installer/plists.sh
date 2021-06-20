#!/bin/bash

# plists.sh
# Alter and handle plist files.

source "tools.sh"

pb="/usr/libexec/PlistBuddy"
check_dependencies "${pb}"

plists_getval=""

# Retrieve value for key in plist file.
plists_get() {
  local key="${1}"
  local pfile="${2}"
  
  plists_getval="$("${pb}" -c "Print ${key}" "${pfile}" 2>/dev/null)"
  
  local err_msgpart="File Doesn't Exist"
  if [ "${plists_getval#${err_msgpart}}" != "${plists_getval}" ]; then
    plists_getval=""
  fi
}

# Add value for key in plist if not present.
plists_add() {
  local key="${1}"
  local type="${2}"
  local value="${3}"
  local pfile="${4}"
  
  "${pb}" -c "Add ${key} ${type} ${value}" "${pfile}"
  exit_if_failed "Failed to add ${key} in ${pfile}."
}

# Set value for key in plist if present.
plists_set() {
  local key="${1}"
  local value="${2}"
  local pfile="${3}"
  
  "${pb}" -c "Set ${key} ${value}" "${pfile}"
  exit_if_failed "Failed to set ${key} in ${pfile}."
}

# Delete value for key in plist.
plists_delete() {
  local key="${1}"
  local pfile="${2}"
  
  "${pb}" -c "Delete ${key}" "${pfile}"
  exit_if_failed "Failed to delete ${key} in ${pfile}."
}

# Import value from binary file.
plists_import() {
  local key="${1}"
  local binfile="${2}"
  local pfile="${3}"
  
  [ ! -e "${binfile}" ] && exit_err "Binary file does not exist."
  
  "${pb}" -c "Import ${key} ${binfile}" "${pfile}"
}