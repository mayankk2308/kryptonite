#!/bin/bash

# kryptonite.sh
# Version: 1.0.0
# Author: @mayankk2308 github.com / @mac_editor egpu.io
script="$0"

configure_environment() {
  b="$(tput bold)"
  n="$(tput sgr0)"
  version="1.0.0"
  pb="/usr/libexec/PlistBuddy"
  work_dir="/Library/Application Support/Kryptonite"
  mkdir -p "${work_dir}"
  disk_plist="${work_dir}/disks.plist"
  userinput=""
  pnames=()
  pids=()
  bootargs_plist_ref=":NVRAM:Add:7C436110-AB2A-4BBB-A880-FE41995C9F82:boot-args"
  bootloader_exists=0
  debug_resources=0
}

printfn() {
  printf '%b\n' "${@}"
}

printfc() {
  printf "\033[2K\r"
  printfn "${@}"
}

exit_if_failed() {
  if [ $? != 0 ]; then
    printfn "$1"
    exit 1
  fi
}

yesno_action() {
  prompt="${1}"
  read -n1 -p "${prompt} [Y/N]: " userinput
  printf "\033[2K\r"
  if [ "${userinput}" = "Y" ] || [ "${userinput}" = "y" ]; then return 0; fi
  if [ "${userinput}" = "N" ] || [ "${userinput}" = "n" ]; then return 1; fi
  printfn "Invalid choice. Please try again.\n"
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
  [ $macos_primary_ver -gt 10 ] && return
  if [ $macos_major_ver -lt 13 ] || 
  ( [ ${macos_major_ver} -eq 13 ] && [ ${macos_minor_ver} -lt 4 ] ); then
    printfn "${b}macOS 10.13.4${n} or newer required.\n"
    exit 1
  fi
}

populate_disks() {
  printfn "${b}Populating disks...${n}"
  diskutil list -plist > "${disk_plist}"
  whole_disk_count=$($pb -c "Print :WholeDisks" "${disk_plist}" | grep -i disk | wc -l | xargs)
  
  for (( i = 0; i < ${whole_disk_count}; i++ ))
  do
    pstart=0
    base_cmd="Print :AllDisksAndPartitions:${i}:Partitions"
    if [ "$($pb -c "Print :AllDisksAndPartitions:${i}:Content" "${disk_plist}")" = "Apple_HFSX" ]; then
      base_cmd="Print :AllDisksAndPartitions"
      pstart=$i
    fi
    pcount=$($pb -c "${base_cmd}" "${disk_plist}" | 
    sed -e 1d -e '$d' | grep -o -i "Dict" | wc -l)
    [ $pstart != 0 ] && pcount=$(( $pstart + 1 ))
    for (( j = $pstart; j < ${pcount}; j++ ))
    do
      pcontent="$($pb -c "${base_cmd}:${j}:Content" "${disk_plist}")"
      ([ "${pcontent}" = "EFI" ] || 
      [ "${pcontent}" = "Apple_APFS" ] ||
      [ "${pcontent}" = "Apple_CoreStorage" ] ||
      [ "${pcontent}" = "Apple_Boot" ]) && continue
      
      pname="$($pb -c "${base_cmd}:${j}:VolumeName" "${disk_plist}")"
      exit_if_failed "Failed to retrieve volume name. Exiting."
      pid="$($pb -c "${base_cmd}:${j}:DeviceIdentifier" "${disk_plist}")"
      exit_if_failed "Failed to retrieve volume identifier. Exiting."
      pnames+=("${pname}")
      pids+=("${pid}")
    done
  done
  
  printfn "Total valid partitions found: ${b}${#pids[@]}${n}\n"
}

list_disks() {
  printfn ">> ${b}Detected Volumes${n}\n"
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
  printfn "\n  ${b}R${n}. Refresh"
  printfn "  ${b}0${n}. Quit"
}

select_disk() {
  printfc
  printfn "Note that ${b}APFS containers and volumes${n} are not shown."
  printfn "If you want to use an internal volume, create a FAT32 partition"
  printfn "via ${b}Disk Utility${n}, after which it should show up here.\n"
  read -p "${b}Choose disk to format${n}: " userinput
  if [ "${userinput}" = "R" ] || [ "${userinput}" = "r" ]; then
    printfn
    list_disks
    select_disk
    return 0
  fi
  if [ -z "${userinput}" ] || 
  ! [ $userinput -eq $userinput 2>/dev/null ] ||
  [ $userinput -lt 0 ] || 
  [ $userinput -gt ${#pids[@]} ]; then
    printfn "Invalid choice. Please re-select."
    printfn
    list_disks
    select_disk
    return 0
  fi
  if [ $userinput -eq 0 ]; then
    printfc "Quitting as requested."
    exit 1
  fi
  
  userinput=$(( $userinput - 1 ))
  disk_to_format="${pids[$userinput]}"
  
  printfn "\nSelected Disk: ${b}${pnames[$userinput]}${n}"
  printfn "Disk Identifier: ${b}${disk_to_format}${n}"
}

erase_disk() {
  printfc
  yesno_action "${b}Format disk${n}?"
  exit_if_failed "Aborting disk format."
  printfn "${b}Formatting disk (${disk_to_format})...${n}"
  diskutil eraseVolume FAT32 KRYPTONITE "${disk_to_format}" 1>/dev/null
  exit_if_failed "Failed to erase volume. Exiting."
  main_dir="$(diskutil info "${disk_to_format}" | grep -i "mount point" | cut -d':' -f2 | awk '{$1=$1};1')"
  if [ ! -e "${main_dir}" ]; then
    printfn "Failed to find formatted volume root. Exiting."
    exit 1
  fi
  config_plist="${main_dir}/EFI/OC/config.plist"
  printfn "Disk ready."
}

format_disk() {
  yesno_action "${b}Already using OpenCore?${n}"
  if [ $? = 0 ]; then
    printfn "${b}Drag and drop${n} your OpenCore disk here. Then press ${b}RETURN${n}."
    read -p "${b}Disk Path${n}: " main_dir
    printfn
    config_plist="${main_dir}/EFI/OC/config.plist"
    if [ ! -e "${main_dir}" ] ||
    [ ! -e "${config_plist}" ]; then
      printfn "Failed to find bootloader volume root. Exiting."
      exit 1
    fi
    bootloader_exists=1
    printfn "Bootloader path set."
    return 0
  fi
  
  populate_disks
  list_disks
  select_disk
  erase_disk
}

retrieve_kryptonite_resources() {
  release_data="$(curl -qs "https://api.github.com/repos/mayankk2308/kryptonite/releases/latest")"
  filter="RELEASE"
  [ $debug_resources = 1 ] && filter="DEBUG"
  bootloader_url="$(printfn "${release_data}" | grep '"browser_download_url":' | 
  grep "${filter}" | sed -E 's/.*"([^"]+)".*/\1/' 2>/dev/null)"
  
  if [ -z "${bootloader_url}" ]; then
    printfn "Unable to retrieve download URL for bootloader. Exiting."
    exit 1
  fi
}

cleanup_archive_data() {
  rm -rf "${object}" 2>/dev/null
  rn -rf "${destination}/__MACOSX" 2>/dev/null
}

download_kryptonite() {
  printfn "${b}Downloading kryptonite resources...${n}"
  destination="$1"
  if [ ! -e "${destination}" ]; then
    printfn "Invalid download destination."
    exit 1
  fi
  retrieve_kryptonite_resources
  object="${destination}/bootloader.zip"
  cleanup_archive_data
  curl -qLs -o "${object}" "${bootloader_url}"
  exit_if_failed "Failed to download resources. Exiting."
  unzip -q -d "${destination}" -o "${object}"
  exit_if_failed "Failed to unzip resources. Exiting."
  rm -rf "${destination}/__MACOSX"
  printfn "Download complete."
}

bless_kryptonite() {
  printfn "${b}Blessing disk...${n}"
  bless --folder "${main_dir}/EFI/BOOT" --label "Kryptonite"
  exit_if_failed "Failed to bless bootloader. Exiting."
  printfn "Disk blessed."
}

get_tb_version() {
  tb_version="$(ioreg | grep AppleThunderboltNHIType)"
  tb_version="${tb_version##*+-o AppleThunderboltNHIType}"
  tb_version="${tb_version::1}"
}

configure_boot_args() {
  get_tb_version
  gpu="AMD"
  debug_args=""
  [ $debug_resources = 1 ] && debug_args="-liludbg liludump=60"
  printfn
  yesno_action "Are you using an ${b}NVIDIA eGPU${n}?"
  [ $? = 0 ] && gpu="NVDA"
  bootargs="krygpu=${gpu} krytbtv=${tb_version} ${debug_args}"
}

get_existing_boot_args() {
  printfn "${b}Retrieving existing boot-args...${n}"
  existing_bootargs="$($pb -c "Print ${bootargs_plist_ref}" "${config_plist}" 2>/dev/null)"
  if [ "${existing_bootargs#Error}" != "${existing_bootargs}" ]; then
    existing_bootargs=""
  fi
  if [ $? != 0 ] && [ -n "${existing_bootargs}" ]; then
    printfn "Failed to retrieve existing ${b}boot-args${n} from configuration.\nExiting."
    exit 1
  fi
  if [ "${existing_bootargs#*kry}" != "$existing_bootargs" ]; then
    printfn "${b}Existing boot-args${n}: ${existing_bootargs}"
    printfn "\nKryptonite configuration already exists."
    printfn "If required, please configure manually.\n"
    return 1
  fi
  printfn "Existing boot-args retrieved."
  return 0
}

move_kry_kexts() {
  printfn "${b}Adding kryptonite dependencies...${n}"
  rsync -a "${work_dir}/EFI/OC/Kexts/" "${main_dir}/EFI/OC/Kexts/"
  printfn "Kryptonite dependencies added."
}

update_kext_injections() {
  printfn "${b}Configuring kext injections...${n}"
  kext_count="$($pb -c "Print :Kernel:Add" "${config_plist}" | grep "Dict" | wc -l)"
  lilu_index=-1
  kry_index=-1
  c_index=0
  for (( i = 0; i < $kext_count; i++ )); do
    base_cmd="Print :Kernel:Add:"
    kext_bundlepath="$($pb -c "Print :Kernel:Add:${i}:BundlePath" "${config_plist}")"
    [ "${kext_bundlepath}" = "Lilu.kext" ] && printfn "${b}Lilu${n} already present." && lilu_index=$i
    [ "${kext_bundlepath}" = "Kryptonite.kext" ] && printfn "${b}Kryptonite${n} already present." && kry_index=$i
    c_index=$i
  done
  
  if [ $lilu_index != -1 ]; then
    $pb -c "Set :Kernel:Add:${lilu_index}:Enabled true" "${config_plist}"
    exit_if_failed "Failed to enable existing Lilu kext in configuration. Exiting."
  else
    $pb -c "Add :Kernel:Add:${c_index}:Arch string Any" "${config_plist}"
    exit_if_failed "Failed to update kext injection configuration. Exiting."
    $pb -c "Add :Kernel:Add:${c_index}:BundlePath string Lilu.kext" "${config_plist}"
    exit_if_failed "Failed to update kext injection configuration. Exiting."
    $pb -c "Add :Kernel:Add:${c_index}:ExecutablePath string Contents/MacOS/Lilu" "${config_plist}"
    exit_if_failed "Failed to update kext injection configuration. Exiting."
    $pb -c "Add :Kernel:Add:${c_index}:PlistPath string Contents/Info.plist" "${config_plist}"
    exit_if_failed "Failed to update kext injection configuration. Exiting."
    $pb -c "Add :Kernel:Add:${c_index}:Enabled bool true" "${config_plist}"
    exit_if_failed "Failed to update kext injection configuration. Exiting."
    c_index=$(( $c_index + 1 ))
  fi
  if [ $kry_index != -1 ]; then
    $pb -c "Set :Kernel:Add:${kry_index}:Enabled true" "${config_plist}"
    exit_if_failed "Failed to enable existing Kryptonite kext in configuration. Exiting."
  else
    $pb -c "Add :Kernel:Add:${c_index}:Arch string Any" "${config_plist}"
    exit_if_failed "Failed to update kext injection configuration. Exiting."
    $pb -c "Add :Kernel:Add:${c_index}:BundlePath string Kryptonite.kext" "${config_plist}"
    exit_if_failed "Failed to update kext injection configuration. Exiting."
    $pb -c "Add :Kernel:Add:${c_index}:ExecutablePath string Contents/MacOS/Kryptonite" "${config_plist}"
    exit_if_failed "Failed to update kext injection configuration. Exiting."
    $pb -c "Add :Kernel:Add:${c_index}:PlistPath string Contents/Info.plist" "${config_plist}"
    exit_if_failed "Failed to update kext injection configuration. Exiting."
    $pb -c "Add :Kernel:Add:${c_index}:Enabled bool true" "${config_plist}"
    exit_if_failed "Failed to update kext injection configuration. Exiting."
    c_index=$(( $c_index + 1 ))
  fi
  
  printfn "Kext injections configured."
}

update_boot_args() {
  $pb -c "Set ${bootargs_plist_ref} ${bootargs} ${existing_bootargs}" "${config_plist}" 2>/dev/null
  exit_if_failed "Failed to configure boot-args. Exiting."
  printfn "${b}Final boot-args${n}: ${bootargs} ${existing_bootargs}"
  printfn "\nIf you have duplicate boot-args, consider fixing them manually."
  printfn "You can do this by editing ${b}config.plist${n} on the bootloader disk.\n"
}

update_existing_plist() {
  printfn "${b}Updating existing configurations...${n}"
  update_kext_injections
  configure_boot_args
  get_existing_boot_args
  [ $? = 0 ] && update_boot_args
  printfn "Configurations updated."
}

setup_plist() {
  configure_boot_args
  update_boot_args
}

setup_kry_dependencies() {
  printfn "${b}Setting up kryptonite dependencies...${n}"
  download_kryptonite "${work_dir}"
  move_kry_kexts
  update_existing_plist
  printfn "Setup complete."
}

install_kryptonite() {
  download_kryptonite "${main_dir}"
  bless_kryptonite
  setup_plist
}

use_debug_resources() {
  printfn "If you want to ${b}emit logs for testing${n}, please use"
  printfn "${b}DEBUG${n} resources. Otherwise, press ${b}N${n} to get ${b}RELEASE${n} resources.\n"
  yesno_action "Use ${b}DEBUG${n} resources?"
  [ $? = 0 ] && debug_resources=1
}

setup_kryptonite() {
  printfn "\n${b}Installing Kryptonite...${n}\n"
  retrieve_kryptonite_resources
  use_debug_resources
  if [ $bootloader_exists = 1 ]; then
    setup_kry_dependencies
    return 0
  fi
  
  install_kryptonite
  printfn "Installation complete.\n"
  printfn "To use ${b}Kryptonite${n}, press ${b}OPTION${n} while booting"
  printfn "and select the \"Kryptonite\" boot disk."
}

start_prompt() {
  clear
  printfc "===${b} Kryptonite Configurator ${version} ${n}===\n"
  printfn "This tool can prepare a disk for a simplified ${b}OpenCore${n}"
  printfn "configuration for your Mac to run ${b}Kryptonite${n}.\n"
  printfn "If you have already configured a ${b}bootloader${n},"
  printfn "this tool can provide you the necessary resources"
  printfn "to enable eGPUs with your existing bootloader.\n"
}

cleanup() {
  rm -rf "${work_dir}" 2>/dev/null
  rm -rf "${main_dir}/bootloader.zip" 2>/dev/null
}

start() {
  validate_macos_version
  elevate_privileges
  configure_environment
  start_prompt
  format_disk
  setup_kryptonite
  cleanup
}

trap cleanup EXIT

start