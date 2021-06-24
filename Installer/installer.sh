#!/bin/bash

# installer.sh
# Initiates Kryptonite setup and configuration.

source "disks.sh"
source "opencore.sh" 
source "resources.sh"
source "requirements.sh"
source "nvram.sh"

version="1.0.0"

# Present information at start.
start_prompt() {
  clear
  printfc "===${b} Kryptonite Configurator ${version} ${n}===\n"
  printfn "This tool can prepare a disk for a simplified ${b}OpenCore${n}"
  printfn "configuration for your Mac to run ${b}Kryptonite${n}.\n"
  printfn "If you have already configured a ${b}bootloader${n},"
  printfn "this tool can provide you the necessary resources"
  printfn "to enable eGPUs with your existing bootloader.\n"
}

# Fetch Kryptonite resources.
fetch_resources() {
  local filter="RELEASE"
  
  [ "${requirements_oc_debug}" = 1 ] && filter="DEBUG"
  
  resources_retrieve "${filter}" "${support_dir}"
}

# Conclude installation.
conclude_setup() {
  cleanup "${support_dir}"
  printfn "${b}Setup complete${n}. Booting via the bootloader will enable eGPUs."
  printfn "To boot a clean system, simply boot without the bootloader.\n"
  printfn "${b}More configuration${n}: ${u}https://github.com/mayankk2308/kryptonite#post-install${n}"
}

# Prepare and set boot arguments.
set_bootargs() {
  local gpu=("AMD" "NVDA")
  local config="${1}"
  
  local bootargs=("-lilubeta" "-krybeta" "krygpu=${gpu[${requirements_nvgpu}]}" "krytbtv=${hardware_tbver}")
  
  if [ "${requirements_oc_debug}" = 1 ]; then
    bootargs+=("-liludbg" "-krydbg" "liludump=60")
  fi
  
  opencore_set_bootargs "${config}" "${bootargs[@]}"
}

# Disable discrete GPU if requested.
disable_dgpu() {
  if [ "${requirements_disabledgpu}" = 0 ]; then
    printfn "Not disabling discrete GPU if present, as configured."
    return 0
  fi
  
  resources_get_gfxutil "${support_dir}"
  
  local pcidevice="$("${resources_gfxutil}" -f GFX0 | sed 's/.*=//')"
  pcidevice="${pcidevice##*( )}"
  pcidevice="${pcidevice%%*( )}"
  exit_if_val_empty "${pcidevice}" "Unable to locate GPU EFI device path."
  
  opencore_disable_gpudevice "${requirements_oc_existing_config}" "${pcidevice}"
}

# Common setup protocols.
common_setup() {
  disable_dgpu
  printfn
  conclude_setup
}

# Modify existing OpenCore configuration.
prep_existing_oc() {
  fetch_resources
  printfn
  resources_move_kextsonly "${requirements_oc_existing_vol}"
  printfn
  opencore_add_kry_injections "${requirements_oc_existing_config}"
  printfn
  set_bootargs "${requirements_oc_existing_config}"
  printfn
  common_setup
}

# Install OpenCore minimal configuration for Kryptonite.
prep_fresh_oc() {
  disks_show
  printfn
  fetch_resources
  printfn
  resources_move "${disks_bootloader_maindir}"
  printfn
  disks_bless "Kryptonite"
  printfn
  set_bootargs "${disks_bootloader_maindir}/EFI/OC/config.plist"
  printfn
  common_setup
}

begin_prep() {
  mkdir -p "${support_dir}"
  
  if [ "${requirements_oc_existing}" = 1 ]; then
    prep_existing_oc
  else
    prep_fresh_oc
  fi
}

start() {
  superuser
  start_prompt
  requirements_get
  begin_prep
}

start

trap "cleanup ${support_dir}" EXIT