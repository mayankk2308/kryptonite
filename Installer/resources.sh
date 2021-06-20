#!/bin/bash

# resources.sh
# Retrieve and manage Kryptonite resources.

source "tools.sh"

resources_oc_efi_dir=""

# Retrieve resources from Github.
resources_retrieve() {
  printfn "${b}Downloading kryptonite resources...${n}"
  local filter="${1}"
  filter="${filter:=RELEASE}"
  
  local dest="${2}"
  dest="${dest:=$(pwd)}"
  
  local data
  data="$(curl -qLs "https://api.github.com/repos/mayankk2308/kryptonite/releases/latest")"
  exit_if_val_empty "${data}" "Unable to retrieve resource metadata."
  
  local dwld_url
  dwld_url="$(printfn "${data}" | grep '"browser_download_url":' | 
  grep "${filter}" | sed -E 's/.*"([^"]+)".*/\1/' 2>/dev/null)"
  exit_if_val_empty "${dwld_url}" "Unable to retrieve download URL."
  
  local object="${dest}/bootloader.zip"
  
  curl -qLs -o "${object}" "${dwld_url}"
  exit_if_failed "Failed to download resources."
  
  unzip -q -d "${dest}" -o "${object}"
  exit_if_failed "Failed to extract resources."
  
  rm -rf "${dest}/__MACOSX" "${object}" 2>/dev/null
  
  resources_oc_efi_dir="${dest}/EFI"
  
  [ ! -e "${resources_oc_efi_dir}" ] && exit_err "Failed to retrieve resources."
  
  printfn "Download complete."
}

# Move only kryptonite kexts to target disk.
resources_move_kextsonly() {
  local target_disk="${1}"
  printfn "${b}Adding kryptonite dependencies...${n}"
  
  [ ! -e "${target_disk}/EFI/OC/" ] && exit_err "Failed to find target disk for bootloader."
  [ ! -e "${resources_oc_efi_dir}" ] && exit_err "Failed to find resources."
  
  mkdir -p "${target_disk}/EFI/OC/Kexts/"
  rsync -a "${resources_oc_efi_dir}/OC/Kexts/" "${target_disk}/EFI/OC/Kexts/"
  exit_if_failed "Failed to copy dependencies to bootloader."
  
  rm -rf "${resources_oc_efi_dir}" 2>/dev/null
  
  printfn "Dependencies added."
}

# Move downloaded resources to target disk.
resources_move() {
  local target_disk="${1}"
  printfn "${b}Moving resources to bootloader disk...${n}"
  
  [ ! -e "${target_disk}" ] && exit_err "Failed to find target disk for bootloader."
  [ ! -e "${resources_oc_efi_dir}" ] && exit_err "Failed to find resources."
  
  rsync -a "${resources_oc_efi_dir}" "${target_disk}/"
  exit_if_failed "Failed to copy bootloader resources."
  
  rm -rf "${resources_oc_efi_dir}" 2>/dev/null
  
  printfn "Move complete."
}