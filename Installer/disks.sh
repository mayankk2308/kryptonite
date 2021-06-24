#!/bin/bash

# disks.sh
# Provide and manage available disks for bootloader.

source "plists.sh"
source "ui.sh"

disks_primary_names=()
disks_primary_ids=()

disks_selection="-1"
disks_bootloader_maindir=""

# Retrieve all suitable volumes (HFS+, ExFAT, and FAT32).
disks_get() {
  disks_primary_names=()
  disks_primary_ids=()
  
  mkdir -p "${support_dir}"
  local dplist="${support_dir}/disks.plist"
  diskutil list -plist > "${dplist}"
  
  plists_get ":WholeDisks" "${dplist}"
  exit_if_failed "Failed to retrieve whole disks."
  local disk_count
  disk_count="$(printfn "${plists_getval}" | grep -ic disk)"
  
  for (( i = 0; i < disk_count; i++ )); do
    local pstart=0
    local base_key=":AllDisksAndPartitions:${i}:Partitions"
    
    plists_get ":AllDisksAndPartitions:${i}:Content" "${dplist}"
    exit_if_failed "Failed to retrieve partition content."
    local content="${plists_getval}"
    
    if [ "${content}" = "Apple_HFSX" ]; then
      base_key=":AllDisksAndPartitions"
      pstart="${i}"
    fi
    
    plists_get "${base_key}" "${dplist}"
    exit_if_failed "Failed to retrieve partitions."
    local pcount
    pcount="$(printfn "${plists_getval}" | 
    sed -e 1d -e '$d' | 
    grep -oic "Dict")"
    
    [ "${pstart}" != 0 ] && pcount=$(( pstart + 1 ))
    
    for (( j = pstart; j < pcount; j++ )); do
      local pcontent
      plists_get "${base_key}:${j}:Content" "${dplist}"
      exit_if_failed "Failed to retrieve partition content."
      pcontent="${plists_getval}"
      
      { [ "${pcontent}" = "EFI" ] || 
      [ "${pcontent}" = "Apple_APFS" ] ||
      [ "${pcontent}" = "Apple_CoreStorage" ] ||
      [ "${pcontent}" = "Apple_Boot" ]; } && continue
      
      plists_get "${base_key}:${j}:VolumeName" "${dplist}"
      exit_if_failed "Failed to retrieve partition volume name."
      local pname="${plists_getval}"
      
      plists_get "${base_key}:${j}:DeviceIdentifier" "${dplist}"
      exit_if_failed "Failed to retrieve partition volume identifier."
      local pid="${plists_getval}"
      
      disks_primary_names+=("${pname} (${b}${pid}${n})")
      disks_primary_ids+=("${pid}")
    done
  done
}

# Format selected disk to MS-DOS FAT32 volume.
disks_format() {
  printfn "${b}Selected Disk${n}: ${disks_primary_names[${disks_selection}]}\n"
  ! ui_confirm "Format disk?" && exit_err "Aborting format."
  
  local target_disk="${disks_primary_ids[${disks_selection}]}"
  printfn "${b}Formatting disk (${target_disk})...${n}"
  
  local diskerase_io="$(diskutil eraseVolume FAT32 KRYPTONITE "${target_disk}" 2>/dev/null)"
  exit_if_failed "Failed to erase volume."
  
  local new_disk_id="${diskerase_io#*Finished erase on }"
  new_disk_id="/dev/${new_disk_id% *}"
  
  disks_bootloader_maindir="$(diskutil info "${new_disk_id}" | 
  grep -i "mount point" |
  cut -d':' -f2 |
  awk '{$1=$1};1')"
  
  if [ ! -e "${disks_bootloader_maindir}" ]; then
    exit_err "Failed to find formatted volume root."
  fi
  
  printfn "Disk ready."
}

# Show available disks and request selection.
disks_show() {
  disks_get
  local disk_count=${#disks_primary_ids[@]}
  
  printfn "Make sure you have a ${u}FAT32${n}, ${u}HFS+${n}, or ${u}ExFAT${n} volume available."
  printfn "APFS volumes are not supported. ${b}The selected volume will"
  printfn "be formatted for use with Kryptonite${n}.\n"
  
  if [ "${disk_count}" -lt 1 ]; then
    printf "No valid disks found. "
     ui_confirm "Refresh disks?"
     if [ $? = 0 ]; then
       disks_show
       return
     fi
     exit 1   
   fi
     
  disk_count=$(( disk_count + 2 ))
  disks_primary_names+=("Refresh" "Quit")
  
  ui_menu_show "Available Disks" $(( disk_count - 2 )) "${disks_primary_names[@]}"
  
  ui_menu_select "Which disk to format?" "${disks_primary_names[@]}"
  disks_selection="${ui_menu_selected}"
  
  if [ "${disks_selection}" = "-1" ]; then
    printfn "Invalid selection. Please retry.\n"
    disks_show
    return
  fi
  
  if [ "${disks_selection}" = $(( ${#disks_primary_names[@]} - 2 )) ]; then
    printfn "${b}Refreshing disks...${n}\n"
    disks_show
    return
  fi
  
  if [ "${disks_selection}" = $(( ${#disks_primary_names[@]} - 1 )) ]; then
    printfn "Quitting as requested."
    exit 0
  fi
  
  disks_format
}

# Bless the bootloader directory with given label.
disks_bless() {
  local label="${1}"
  
  printfn "${b}Blessing bootloader...${n}"
  
  exit_if_val_empty "${label}" "No label provided for bless."
  [ ! -e "${disks_bootloader_maindir}" ] && exit_err "Could not find bootloader."
  
  bless --folder "${disks_bootloader_maindir}/EFI/BOOT" --label "${label}"
  exit_if_failed "Failed to bless bootloader."
  
  printfn "Disk blessed."
}