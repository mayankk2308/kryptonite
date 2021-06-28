#!/bin/bash

# requirements.sh
# Computes the necessary requirements for Kryptonite configuration.

source "hardware.sh"
source "ui.sh"

requirements_nvgpu=0
requirements_disabledgpu=0
requirements_oc_existing=0
requirements_oc_existing_vol="None"
requirements_oc_existing_config=""
requirements_oc_debug=0

requirements_macos_version=""

# Compute macOS version requirements.
requirements_get_macos_version() {
  local macos_ver
  macos_ver="$(sw_vers -productVersion)"
  requirements_macos_version="${macos_ver}"

  local macos_primary_ver
  macos_primary_ver="$(printfn "${macos_ver}" | cut -d '.' -f1)"
  local macos_major_ver
  macos_major_ver="$(printfn "${macos_ver}" | cut -d '.' -f2)"

  local macos_minor_ver
  macos_minor_ver="$(printfn "${macos_ver}" | cut -d '.' -f3)"
  [ -z "${macos_minor_ver}" ] && macos_minor_ver=0

  [ "${macos_primary_ver}" -gt 10 ] && return

  if [ "${macos_major_ver}" -lt 13 ] ||
  { [ "${macos_major_ver}" -eq 13 ] && [ "${macos_minor_ver}" -lt 4 ]; }; then
    exit_err "${b}macOS 10.13.4${n} or newer required.\n"
  fi
}

# Request information on existing OpenCore configuration.
requirements_request_oc_existing() {
  printfn "If you are using ${b}OpenCore${n} for any other purposes (such as OCLP), press ${b}Y${n}."
  printfn "Otherwise press ${b}N${n}, even if you already have a Kryptonite-created bootloader.\n"
  ui_confirm "${b}Are you already using OpenCore${n}?" && requirements_oc_existing=1
}

# Request information on location of existing OpenCore configuration.
requirements_request_oc_existing_vol() {
  [ "${requirements_oc_existing}" != 1 ] && return

  printfn "${b}Drag and drop${n} your OpenCore disk here. Then press ${b}RETURN${n}."
  read -r -p "${b}Disk Path${n}: " requirements_oc_existing_vol
  printfn

  requirements_oc_existing_config="${requirements_oc_existing_vol}/EFI/OC/config.plist"

  if { [ ! -e "${requirements_oc_existing_vol}" ] ||
  [ ! -e "${requirements_oc_existing_config}" ]; }; then
    printfn "Unable to locate existing bootloader volume. Try again.\n"
    requirements_oc_existing=0
    requirements_oc_existing_vol="None"
    requirements_request_oc_existing
    requirements_request_oc_existing_vol
    return $?
  fi

  printfn "Existing OpenCore configuration located.\n"
}

# Request information on whether to use debug resources.
requirements_request_oc_debug() {
  printfn "If you want to ${b}emit logs for testing${n}, please use"
  printfn "${b}DEBUG${n} resources. Otherwise, press ${b}N${n} to get ${b}RELEASE${n} resources.\n"

  ui_confirm "${b}Use DEBUG resources${n}?" && requirements_oc_debug=1
}

# Request information on eGPU being used.
requirements_request_nvgpu() {
  printfn "${b}RTX GPUs${n} not supported. ${b}9/10 series${n} only supported on ${b}macOS High Sierra${n}."
  printfn "${b}GTX 6/7 series${n} may work with limited support on the latest versions of macOS.\n"
  ui_confirm "Are you using an ${b}NVIDIA eGPU${n}?" && requirements_nvgpu=1
}

# Request decision to disable discrete GPU where applicable.
requirements_request_disabledgpu() {
  { [ "${hardware_dgpuvendor}" != "10de" ] ||
  [ "${hardware_isdesktop}" = 1 ]; } && return 0
  printfn "Because your discrete GPU is ${b}NVIDIA${n}, it is not currently possible"
  printfn "to use external displays with eGPUs. If you choose to disable it, eGPU"
  printfn "displays will work, but you will be unable to adjust internal display"
  printfn "${u}brightness${n} and your mac will be unable to wake from ${u}sleep${n}.\n"

  ui_confirm "${b}Disable Discrete GPU${n}?" && requirements_disabledgpu=1
}

# Summarize requirements and request confirmation before proceeding.
requirements_summarize() {
  local state=("NO" "YES")
  printfn ">> ${b}Requirements Summary${n}\n"
  printfn "${b}macOS Version${n}               ${requirements_macos_version}"
  printfn "${b}Thunderbolt NHI${n}             ${hardware_tbver}"
  printfn "${b}Is Desktop Mac${n}              ${state[${hardware_isdesktop}]}"
  printfn "${b}Discrete GPU${n}                ${hardware_discretegpu}"
  printfn "${b}Disable Discrete GPU${n}        ${state[${requirements_disabledgpu}]}"
  printfn "${b}OpenCore Legacy Patcher${n}     ${state[${requirements_oc_existing}]}"
  printfn "${b}OCLP Volume${n}                 ${requirements_oc_existing_vol}"
  printfn "${b}NVIDIA eGPU${n}                 ${state[${requirements_nvgpu}]}"
  printfn "${b}DEBUG Mode${n}                  ${state[${requirements_oc_debug}]}"
  printfn

  ! ui_confirm "${b}Proceed${n}?" && exit_msg "Stopping."

  return 0
}

# Retrieve all requirements before proceeding to install Kryptonite.
requirements_get() {
  requirements_get_macos_version
  hardware_getdetails
  printfn
  requirements_request_oc_existing
  requirements_request_oc_existing_vol
  requirements_request_oc_debug
  requirements_request_nvgpu
  requirements_request_disabledgpu
  requirements_summarize
}
