#!/bin/bash

# hardware.sh
# Retrieve and handle mac hardware information.

source "tools.sh"

hardware_tbver=""
hardware_isdesktop=1
hardware_discretegpu="None"

# Retrieve thunderbolt NHI type for system.
hardware_get_tbver() {
  hardware_tbver="$(ioreg | grep AppleThunderboltNHIType)"
  hardware_tbver="${hardware_tbver##*+-o AppleThunderboltNHIType}"
  hardware_tbver="${hardware_tbver::1}"
  exit_if_val_empty "${hardware_tbver}" "Unable to retrieve Thunderbolt NHI type."
  
  return 0
}

# Retrieve mac type.
hardware_get_isdesktop() {
  local model_id
  model_id="$(system_profiler SPHardwareDataType 2>/dev/null | awk '/Model Identifier/ {print $3}')"
  
  [[ "${model_id}" == *"MacBook"* ]] && hardware_isdesktop=0
  
  return 0
}

# Retrieve discrete GPU details, if present.
hardware_get_discretegpu() {
  local ioreg
  ioreg="$(ioreg -n GFX0@0)"
  
  local vendor
  vendor="$(printfn "${ioreg}" | grep \"vendor-id\" | cut -d "=" -f2 | sed 's/ <//' | sed 's/>//' | cut -c1-4 | sed -E 's/^(.{2})(.{2}).*$/\2\1/')"
  
  local id
  id="$(printfn "${ioreg}" | grep \"device-id\" | cut -d "=" -f2 | sed 's/ <//' | sed 's/>//' | cut -c1-4 | sed -E 's/^(.{2})(.{2}).*$/\2\1/')"
  
  [ -z "${vendor}" ] && return 0
  
  hardware_discretegpu="$(curl -s "http://pci-ids.ucw.cz/read/PC/${vendor}/${id}" |
   grep -i "itemname" | 
   sed -E "s/.*Name\: (.*)$/\1/" |
   tail -1 | 
   cut -d '[' -f2 |
   cut -d ']' -f1)"
   
   if [ -z "${hardware_discretegpu}" ]; then
     hardware_discretegpu="${id}:${vendor}"
   fi
}

# Retrieve all necessary hardware details.
hardware_getdetails() {
  printfn "${b}Retrieving hardware details...${n}"
  hardware_get_tbver
  hardware_get_isdesktop
  hardware_get_discretegpu
  printfn "Hardware details retrieved."
}