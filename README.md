# seal-os-lnx
Linux OS Sealer for creating Linux VM OS Templates from which other VMs can be uniquely cloned.

- **Version**: 1.0.1 2025-01-22

## Distro's Tested
- Debian 12
- Ubuntu 22.04
- Rocky 9
- Zorin OS 17


## Usage

**Install Deps**
```
apt -y install git jq
```

**Git Clone**
```
cd /opt
```

```
git clone https://github.com/acep-uaf/seal-os-lnx.git
```

**Seal an VM for a Template**

```
/opt/seal-os-lnx/seal-os.sh
```

> NOTE:  You will be prompted to appove the OS Seal Process.

- Do not boot the newly sealed VM Template (or it will be re-initialized)
- Following the seal process you can clone new VM's from this template.
- Upon booting newly cloned VMs they will setup new SSH keys and Machine ID's on first boot.
- Besure to set a new hostname (/etc/hostname) on newly cloned systems.

