#!/usr/bin/env bash

# make-installer.sh
# Creates compiled installer binary for Kryptonite installation.

if ! command -v "shc" 1>/dev/null; then
  echo "Need tool 'shc'. Please install via brew."
  exit 1
fi

target_script="installer.sh"
executable="kryptonite.x"

if [ ! -e "${target_script}" ]; then
  echo "Could not find install script."
  exit 1
fi

shc -f "${target_script}" -o "${executable}"
rm "${target_script}.x.c"