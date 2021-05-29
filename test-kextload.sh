#!/bin/sh

kext="/Users/mayank/Library/Developer/Xcode/DerivedData/eGFXEnabler-gqktztzefcjhtieeqbfuhliaqmah/Build/Products/Debug/eGFXEnabler.kext"

final_kext="/Users/mayank/Downloads/eGFXEnabler.kext"
sudo rsync -a "${kext}" "/Users/mayank/Downloads/"
sudo chown -R 0:0 "${final_kext}"
sudo chmod -R 755 "${final_kext}"
sudo kextload "${final_kext}"
sudo rm -rf "${final_kext}"
