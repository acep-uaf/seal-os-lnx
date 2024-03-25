#!/usr/bin/env bash

# Post Clone First Boot OS Initialization Bash Script
# Description: Post Clone First Boot OS Initialization Bash Script
# Verson: 1.0.0
# Version_Date: 2024-03-25
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
  exit 1echo "WARNING: Do not run this script on production systems!!!"
fi

# Defined supported OS
supported_os=("Ubuntu" "Debian")

# Source the losd-lib.sh file.
source $rundir/losd/losd-lib.sh

losd_json=$(losd)

os_name=$(echo $losd_json | jq '.DISTRO.NAME' | sed -r 's/"//g')
os_version=$(echo $losd_json | jq '.DISTRO.VERSION' | sed -r 's/"//g')
hw_platform=$(echo $losd_json | jq '.HARDWARE.HOSTNAMECTL.Chassis' | tr -dc '[:print:]' | sed -r 's/\s//g' | sed -r 's/"//g')
ts=$(echo $losd_json | jq '.OS.NOW' | sed -r 's/"//g')

# echo "OS Name: $os_name"
# echo "OS Version: $os_version"
# echo "Hardware Platform: $hw_platform"

# Check if the OS is supported
if [[ ! " ${supported_os[@]} " =~ " ${os_name} " ]]; then
    echo "ERROR: Unsupported OS detected: $os_name $os_version"
    exit 1
fi


# Case statement to determine the OS version to Initialize.

case $os_name in
    "Ubuntu")

    # Check if SSH keys are already present befor generating new ones.
    if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
        # Check if the hardware platform is a virtual machine.
        if [ "$hw_platform" != "vm" ]; then
            echo "ERROR: This script is intended to be run on a virtual machine."
            exit 1
        fi

        # Generate the SSH keys
        dpkg-reconfigure openssh-server

        # Regenerate a new machine-id
        systemd-machine-id-setup
        systemctl restart dbus

        # If hostname is 'localhost' then notify users to change it upon logging in.
        # if [ "$(hostname)" == "localhost" ]; then
        #     echo "WARNING: Hostname is set to 'localhost'.  Please edit /etc/hostname."
        # fi

        # systemctl disable post-clone-first-boot.service
        systemctl disable post-clone-first-boot.service
#        rm /etc/systemd/system/post-clone-first-boot.service
#        systemctl daemon-reload

        # Logging Setup
        $rundir/losd/losd.sh > $rundir/post-clone-first-boot.$ts.json

        # Reboot the system
        shutdown -r now
    fi

    ;;

    "Debian")

    # Check if the hardware platform is a virtual machine.
    if [ "$hw_platform" != "vm" ]; then
        echo "ERROR: This script is intended to be run on a virtual machine."
        exit 1
    fi

    # Check if SSH keys are already present befor generating new ones.
    if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
        # Generate the SSH keys
        dpkg-reconfigure openssh-server

        # Regenerate a new machine-id
        systemd-machine-id-setup
        systemctl restart dbus

        # If hostname is 'localhost' then notify users to change it upon logging in.
        # if [ "$(hostname)" == "localhost" ]; then
        #     echo "WARNING: Hostname is set to 'localhost'.  Please edit /etc/hostname."
        # fi

        # systemctl disable post-clone-first-boot.service
        systemctl disable post-clone-first-boot.service
#        rm /etc/systemd/system/post-clone-first-boot.service
#        systemctl daemon-reload

        # Logging Setup
        $rundir/losd/losd.sh > $rundir/post-clone-first-boot.$ts.json

        # Reboot the system
        shutdown -r now
    ;;

    *)
        echo "UnSupported OS detected: $os_name $os_version"
        exit 1
    ;;
esac