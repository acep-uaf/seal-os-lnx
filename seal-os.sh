#!/usr/bin/env bash

# SEAL OS Detector (SEAL-OS) Bash Script
# Description: To provide a universal Linux OS Versions detector for consistent apples to apples os independent comparision using native tool.
# Verson: 1.0.0
# Version_Date: 2024-03-25
# Author: John Haverlack (jehaverlack@alaska.edu)
# License: MIT (Proposed/Pending) / UAF Only
# Source: https://github.com/acep-uaf/seal-os-lnx

# See: https://github.com/DanHam/packer-virt-sysprep
# See: https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox

# TODO: 
# - Dry Run Mode


# Check if dependancy binaries are installed.
req_binaries=(awk cat cut date df egrep grep jq lsblk mount sed stat tail tr uname uptime wc which)
for i in "${req_binaries[@]}"; do
  if ! which $i > /dev/null 2>&1; then
    echo "Error: $i binary not found or not executable.  Please install $i"
    exit 1
  fi
done

# Verify that this script is being run as root.
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root."
    exit 1
fi

# Determine the directory full path where this seal-os.sh file is located.
rundir=$(realpath $(dirname $0))

# Check to see if the losd-lib.sh file exists and is readable.
if [ ! -r $rundir/losd/losd-lib.sh ]; then
  echo "Error: $rundir/losd/losd-lib.sh file not found or not readable."
  exit 1
fi

# Defined supported OS
supported_os=("Ubuntu" "Debian")

# Source the losd-lib.sh file.
source $rundir/losd/losd-lib.sh

losd_json=$(losd)

os_name=$(echo $losd_json | jq '.DISTRO.NAME' | sed -r 's/"//g')
os_version=$(echo $losd_json | jq '.DISTRO.VERSION' | sed -r 's/"//g')
hw_platform=$(echo $losd_json | jq '.HARDWARE.HOSTNAMECTL.Chassis' | tr -dc '[:print:]' | sed -r 's/\s//g' | sed -r 's/"//g')


echo "OS Name: $os_name"
echo "OS Version: $os_version"

# Check if the OS is supported
if [[ ! " ${supported_os[@]} " =~ " ${os_name} " ]]; then
    echo "ERROR: Unsupported OS detected: $os_name $os_version"
    exit 1
fi

echo "WARNING: Do not run this script on production systems!!!"
echo "This script [seal-os.sh] will *seal* this system image for cloning purposes."
echo "By continuing to run this script, host SSH and other identity settings will be permanently deleted."
echo "Once finished, this script will power off the host, making it a clonable template."
echo "Upon reboot of this image, new SSH keys and other host identifiers will be generated."
read -p "Continue [y/N]:" ans

if [[ "$ans" != "y" && "$ans" != "Y" ]]; then
    echo "INFO: Aborting Script."
    exit 1
fi

echo "Proceeding to Seal Host ..."


# Case statement to determine the OS version to customize OS Sealing Steps.
case $os_name in
    "Ubuntu")

    # Check if the hardware platform is a virtual machine.
    if [ "$hw_platform" != "vm" ]; then
        echo "ERROR: This script is intended to be run on a virtual machine. [$hw_platform] detected."
        exit 1
    fi

    # Run Apt Clean
    apt clean

    # Set /etc/hostname to localhost
    echo "localhost" > /etc/hostname

    # Update PATH_DIR in $rundir/post-clone-first-boot.service
    # Copy $rundir/post-clone-first-boot.service to /etc/systemd/system/post-clone-first-boot.service
    cat $rundir/post-clone-first-boot.service | sed "s|PATH_DIR|$rundir|g" > /etc/systemd/system/post-clone-first-boot.service

    # systemctl enable post-clone-first-boot.service
    systemctl enable post-clone-first-boot.service

    # rm /etc/ssh/ssh_host_*
    rm /etc/ssh/ssh_host_*

    # rm /etc/machine-id
    rm /etc/machine-id

    # rm /var/lib/dbus/machine-id
    rm /var/lib/dbus/machine-id

    # find /var/log -type f -delete
    find /var/log -type f -delete


        ;;

    "Debian")

    # Check if the hardware platform is a virtual machine.
    if [ "$hw_platform" != "vm" ]; then
        echo "ERROR: This script is intended to be run on a virtual machine. [$hw_platform] detected."
        exit 1
    fi

    # Run Apt Clean
    apt clean

    # Set /etc/hostname to localhost
    echo "localhost" > /etc/hostname

    # Update PATH_DIR in $rundir/post-clone-first-boot.service
    # Copy $rundir/post-clone-first-boot.service to /etc/systemd/system/post-clone-first-boot.service
    cat $rundir/post-clone-first-boot.service | sed "s|PATH_DIR|$rundir|g" > /etc/systemd/system/post-clone-first-boot.service

    # systemctl enable post-clone-first-boot.service
    systemctl enable post-clone-first-boot.service

    # rm /etc/ssh/ssh_host_*
    rm /etc/ssh/ssh_host_*

    # rm /etc/machine-id
    rm /etc/machine-id

    # rm /var/lib/dbus/machine-id
    rm /var/lib/dbus/machine-id

    # find /var/log -type f -delete
    find /var/log -type f -delete
        ;;

    *)
        echo "UnSupported OS detected: $os_name $os_version"
        exit 1
        ;;
esac


# Shutdown Host - Commented Out for testing
shutdown -h now
