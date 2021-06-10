#!/bin/sh

# kryptonite.sh
# Version: 1.0.0
# Author: @mayankk2308 github.com / @mac_editor egpu.io
script="$0"

configure_environment() {
  b="$(tput bold)"
  n="$(tput sgr0)"
  version="1.0.0"
  pb="/usr/libexec/PlistBuddy"
  work_dir="/Library/Application Support/Kryptonite/"
  disk_plist="${work_dir}disks.plist"
  userinput=""
  pnames=()
  pids=()
}

printfn() {
  printf '%b\n' "${@}"
}

printfc() {
  printf "\033[2K\r"
  printfn "${@}"
}

yesno_action() {
  prompt="${1}"
  read -n1 -p "${prompt} [Y/N]: " userinput
  printf "\033[2K\r"
  ([ $userinput = "Y" ] || [ $userinput = "y" ]) && return 0
  ([ $userinput = "N" ] || [ $userinput = "n" ]) && return 1
  printfn "Invalid choice. Please try again."
  yesno_action "${prompt}"
}

elevate_privileges() {
  if [ $(id -u) != 0 ]
  then
    sudo /bin/sh "${script}"
    exit
  fi
}

validate_macos_version() {
  macos_ver="$(sw_vers -productVersion)"
  macos_primary_ver="$(printfn "${macos_ver}" | cut -d '.' -f1)"
  macos_major_ver="$(printfn "${macos_ver}" | cut -d '.' -f2)"
  macos_minor_ver="$(printfn "${macos_ver}" | cut -d '.' -f3)"
  [ -z "${macos_minor_ver}" ] && macos_minor_ver=0
  (( $macos_primary_ver > 10 )) && return
  if ( (( $macos_major_ver < 13 )) || 
  ( (( ${macos_major_ver} = 13 )) && 
  (( ${macos_minor_ver} < 4 )) ) ); then
    printfn "${b}macOS 10.13.4${n} or newer required.\n"
    exit 1
  fi
}

populate_disks() {
  mkdir -p "${work_dir}"
  printfn "${b}Populating disks...${n}"
  diskutil list -plist > "${disk_plist}"
  whole_disk_count=$($pb -c "Print :WholeDisks" "${disk_plist}" | grep -i disk | wc -l | xargs)
  
  for (( i = 0; i < ${whole_disk_count}; i++ ))
  do
    base_cmd="Print :AllDisksAndPartitions:${i}:Partitions"
    pcount=$($pb -c "${base_cmd}" "${disk_plist}" | 
    sed -e 1d -e '$d' | grep -o -i "Dict" | wc -l)
    for (( j = 0; j < ${pcount}; j++ ))
    do
      pcontent="$($pb -c "${base_cmd}:${j}:Content" "${disk_plist}")"
      ([ "${pcontent}" = "EFI" ] || [ "${pcontent}" = "Apple_APFS" ]) && continue
      
      pname="$($pb -c "${base_cmd}:${j}:VolumeName" "${disk_plist}")"
      pid="$($pb -c "${base_cmd}:${j}:DeviceIdentifier" "${disk_plist}")"
      pnames+=("${pname}")
      pids+=("${pid}")
    done
  done
  
  printfn "Total valid partitions found: ${b}${#pids[@]}${n}\n"
}

list_disks() {
  disk_count=${#pnames[@]}
  if (( $disk_count < 1 )); then
    printfn "No valid partitions found. Exiting."
    exit 1
  fi
  for (( i = 0; i < $disk_count; i++ ))
  do
    disk_no=$(( $i + 1 ))
    printfn "  ${b}${disk_no}${n}. ${pnames[$i]}"
  done
  printfn "  ${b}0${n}. Quit"
}

select_disk() {
  printfc
  read -p "${b}Choose disk to format${n}: " userinput
  if ( [ -z $userinput ] || [ $userinput -lt 1 ] ||
   [ $userinput -gt ${#pids[@]} ] ); then
    printfn "Invalid choice. Aborting."
    exit 1
  fi
  if [ $userinput -eq 0 ]; then
    printfc "Quitting as requested."
    exit 1
  fi
  
  userinput=$(( $userinput - 1 ))
  
  printfn "\nSelected Disk: ${b}${pnames[$userinput]}${n}"
  printfn "Disk Identifier: ${b}${pids[$userinput]}${n}"
}

erase_disk() {
  printfc
  yesno_action "${b}Format disk${n}?"
  if [ $? != 0 ]; then
    printfc "Aborting disk format."
    exit 1
  fi
  
  printfn "${b}Formatting disk...${n}"
  diskutil eraseVolume FAT32 KRYPTONITE "${pids[$userinput]}"
  main_dir="/Volumes/KRYPTONITE/"
  if [ ! -e "${main_dir}" ]; then
    printfn "Failed to format disk. Exiting."
    exit 1
  fi
  printfn "Disk ready."
}

format_disk() {
  yesno_action "${b}Do you already have a bootloader?${n}"
  if [ $? = 0 ]; then
    printfn "${b}Skipping disk management...${n}"
    return 0
  fi
  
  populate_disks
  list_disks
  select_disk
  erase_disk
}

start_prompt() {
  clear
  printfc "===${b} Kryptonite Configurator ${version} ${n}===\n"
  printfn "This tool can prepare a disk for a simplified ${b}OpenCore${n}"
  printfn "configuration for your Mac to run ${b}Kryptonite${n}.\n"
  printfn "If you are have already configured a ${b}bootloader${n},"
  printfn "this tool can provide you the necessary resources"
  printfn "to enable eGPUs with your existing bootloader.\n"
}

start() {
  validate_macos_version
  elevate_privileges
  configure_environment
  start_prompt
  format_disk
}

start