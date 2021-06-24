#!/bin/bash

# nvram.sh
# Manipulate NVRAM variables.

source "tools.sh"

power_prefs="FA4CE28D-B62F-4C99-9CC3-6815686E30F9:gpu-power-prefs"

# Set variable with value.
nvram_set() {
  variable="${1}" && shift
  value="${*}"
  
  nvram "${variable}=${value}"
}

# Set mux.
nvram_mux() {
  local val="${1}"
  
  nvram_set "${power_prefs}" "${val}"
  exit_if_failed "Unable to set mux."
}

# Set mux to integrated GPU.
nvram_muxigpu() {
  nvram_mux "%01%00%00%00"
}

# Set mux to discrete GPU.
nvram_muxdgpu() {
  nvram_mux "%00%00%00%00"
}