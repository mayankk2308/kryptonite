#!/bin/bash

# opencore.sh
# Configure OpenCore properties for Kryptonite.

source "plists.sh"

kext_fields=("Arch" "BundlePath" "ExecutablePath" "PlistPath" "Enabled")
kext_field_types=("string" "string" "string" "string" "bool")
bootargs_key=":NVRAM:Add:7C436110-AB2A-4BBB-A880-FE41995C9F82:boot-args"

opencore_existing_bootargs=()

# Inject missing kernel extension configuration.
opencore_inject_kext() {
  local pfile="${1}" && shift
  local key="${1}" && shift
  local vals=("${@}")
  
  for (( i = 0; i < ${#kext_fields[@]}; i++ )); do
    plists_add "${key}:${kext_fields[${i}]}" "${kext_field_types[${i}]}" "${vals[${i}]}" "${pfile}"
  done
}

# Update existing configuration with kext injections.
opencore_add_kry_injections() {
  local pfile="${1}"
  printfn "${b}Configuring kext injections...${n}"
  
  [ ! -e "${pfile}" ] && exit_err "OpenCore configuration not found."
  
  local base_key=":Kernel:Add"
  
  plists_get "${base_key}" "${pfile}"
  exit_if_failed "Unable to retrieve kext information from OC configuration."
  
  local kcount
  kcount=$(printfn "${plists_getval}" | grep -c "Dict")
  
  local lilu_index=-1
  local kry_index=-1
  local cindex=0
  
  for (( i = 0; i < kcount; i++ )); do
    plists_get "${base_key}:${i}:BundlePath" "${pfile}"
    exit_if_failed "OpenCore kext configuration seems to be invalid."
    
    local kbundle="${plists_getval}"
    
    [ "${kbundle}" = "Lilu.kext" ] && lilu_index="${i}"
    [ "${kbundle}" = "Kryptonite.kext" ] && kry_index="${i}"
    cindex=$(( i + 1 ))
  done
  
  if [ "${lilu_index}" != -1 ]; then
    printfn "${b}Enabling Lilu...${n}"
    plists_set "${base_key}:${lilu_index}:Enabled" "true" "${pfile}"
  else
    local vals=("Any" "Lilu.kext" "Contents/MacOS/Lilu" 
    "Contents/Info.plist" "true")
    
    opencore_inject_kext "${pfile}" "${base_key}:${cindex}" "${vals[@]}"
    cindex=$(( cindex + 1 ))
  fi
  
  if [ "${kry_index}" != -1 ]; then
    printfn "${b}Enabling Kryptonite...${n}"
    plists_set "${base_key}:${kry_index}:Enabled" "true" "${pfile}"
  else
    local vals=("Any" "Kryptonite.kext" "Contents/MacOS/Kryptonite" 
    "Contents/Info.plist" "true")
    
    opencore_inject_kext "${pfile}" "${base_key}:${cindex}" "${vals[@]}"
    cindex=$(( cindex + 1 ))
  fi
  
  printfn "Kext injections configured."
}

# Retrieve existing boot arguments in OpenCore configuration.
opencore_get_bootargs() {
  local pfile="${1}"
  
  plists_get "${bootargs_key}" "${pfile}"
  opencore_existing_bootargs=($plists_getval)
}

# Set provided boot arguments in OpenCore configuration if absent.
opencore_set_bootargs() {
  printfn "${b}Setting boot-args...${n}"
  local pfile="${1}" && shift
  local args=("${@}")
  
  opencore_get_bootargs "${pfile}"
  
  local args_to_set=("${opencore_existing_bootargs[@]}")
  
  for new_arg in "${args[@]}"; do
    local match=0
    for arg in "${opencore_existing_bootargs[@]}"; do
      local trimmed_arg="${arg%%=*}"
      
      if [[ "${new_arg}" == "${trimmed_arg}"* ]]; then
        match=1
        break
      fi
      
    done
    [ "${match}" = 0 ] && args_to_set+=("${new_arg}")
  done
  
  plists_set "${bootargs_key}" "$(printfn "${args_to_set[@]}" | xargs)" "${pfile}"
  printfn "Boot-args configured."
}

# Disable GPU device in configuration.
opencore_disable_gpudevice() {
  local dev_properties=":DeviceProperties:Add"
  
  local pfile="${1}"
  local device="${2}"
  
  plists_get "${dev_properties}:${device}" "${pfile}"
  [ -n "${plists_getval}" ] && printfn "Some device configuration already present." && return 0
  
  local tmp_classcode_bin="tmp-class-code.bin"
  base64 -D <<< "/////w==" > "${tmp_classcode_bin}"
  plists_import "${dev_properties}:${device}:class-code" "${tmp_classcode_bin}" "${pfile}"
  rm "${tmp_classcode_bin}"
  
  plists_add "${dev_properties}:${device}:IOName" "string" "#display" "${pfile}"
  plists_add "${dev_properties}:${device}:name" "data" "#display" "${pfile}"
}