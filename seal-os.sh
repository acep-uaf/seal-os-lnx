#!/usr/bin/env bash

# SEAL OS Detector (SEAL-OS) Bash Script
# Description: To provide a universal Linux OS Versions detector for consistent apples to apples os independent comparision using native tool.
# Verson: 1.0.0
# Version_Date: 2024-03-22
# Author: John Haverlack (jehaverlack@alaska.edu)
# License: MIT (Proposed/Pending) / UAF Only
# Source: https://github.com/acep-uaf/seal-os-lnx

# Check if dependancy binaries are installed.
req_binaries=(awk cat cut date df egrep grep jq lsblk mount sed stat tail tr uname uptime wc which)
for i in "${req_binaries[@]}"; do
  if ! which $i > /dev/null 2>&1; then
    echo "Error: $i binary not found or not executable.  Please install $i"
    exit 1
  fi
done

# Determine the directory full path where this seal-os.sh file is located.
rundir=$(realpath $(dirname $0))

# Check to see if the losd-lib.sh file exists and is readable.
if [ ! -r $rundir/losd/losd-lib.sh ]; then
  echo "Error: $rundir/losd/losd-lib.sh file not found or not readable."
  exit 1
fi

source $rundir/losd/losd-lib.sh

losd_json=$(losd)

os_name=$(echo $losd_json | jq '.DISTRO.NAME' | sed -r 's/"//g')
os_version=$(echo $losd_json | jq '.DISTRO.VERSION' | sed -r 's/"//g')
hw_platform=$(echo $losd_json | jq '.HARDWARE.HOSTNAMECTL.Chassis' | sed -r 's/"//g')

echo "OS Name: $os_name"
echo "OS Version: $os_version"
echo "Hardware Platform: $hw_platform"
