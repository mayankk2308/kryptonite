#!/bin/bash

# installer.sh
# Initiates Kryptonite setup and configuration.

source "opencore.sh" 
source "resources.sh"
source "requirements.sh"
source "nvram.sh"

version="1.0.0"

start_prompt() {
  clear
  printfc "===${b} Kryptonite Configurator ${version} ${n}===\n"
  printfn "This tool can prepare a disk for a simplified ${b}OpenCore${n}"
  printfn "configuration for your Mac to run ${b}Kryptonite${n}.\n"
  printfn "If you have already configured a ${b}bootloader${n},"
  printfn "this tool can provide you the necessary resources"
  printfn "to enable eGPUs with your existing bootloader.\n"
}

start() {
  superuser
  start_prompt
  requirements_get
}

start