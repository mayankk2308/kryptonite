#!/bin/bash

# tools.sh
# Defines common shell tools to use for scripts.

# Bold, underlined, and normal text.
b="$(tput bold)"
u="$(tput smul)"
n="$(tput sgr0)"

support_dir="/Library/Application Support/Kryptonite"

# Simple print with new line.
printfn() {
  printf '%b\n' "${@}"
}

# Clear print with new line.
printfc() {
  printf "\033[2K\r"
  printfn "${@}"
}

# Exit with error message.
exit_err() {
  printfn "${@}"
  exit 1
}

# Exit if previous command returned non-zero exit code.
exit_if_failed() {
  if [ $? != 0 ]; then
    exit_err "${@}"
  fi
}

# Exit if provided value is empty.
exit_if_val_empty() {
  local value="${1}"
  local message="${2}"
  [ -z "${value}" ] && exit_err "${message}"
}

# Check if a particular dependency exists.
check_dependency_exists() {
  local dependency="${1}"
  command -v "${dependency}" 1>/dev/null
}

# Check if dependencies exist and exit if missing.
check_dependencies() {
  local dependencies=("${@}")
  for i in "${dependencies[@]}"; do
    check_dependency_exists "${i}"
    exit_if_failed "Dependency ${b}${i}${n} not found."
  done
}

# Clean up resoures forcefully.
cleanup() {
  local resources=("${@}")
  rm -rf "${resources[@]}" 2>/dev/null
}

# Escalate to superuser mode if required.
superuser() {
  local target="${0}"
  if [ "$(id -u)" != 0 ]
  then
    sudo "${target}" 
    exit $?
  fi
}