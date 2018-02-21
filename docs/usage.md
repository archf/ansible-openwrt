## User guide

### Requirements

None. This roles uses a custom non-native Ansible module to run `uci` commands
on target host.

### Usage

This role can perform multiple tasks that can be selected passing an extra_vars
boolean flag.

In this examples, we will be usig a playbook `openwrt.yml` of the like:

```yml
---

- hosts: all
  gather_facts: false
  roles:
    - openwrt.yml
```

**Step 1 (optional): Create an extroot (a.k.a. pivot-overlay)**

For this to work you need to stick in the router a pre-partionned flashed
drive where:

```
/dev/sda1 -> swap partition LABEL="swapfs"
/dev/sda2 -> ext4 partition (overlay) LABEL="overlayfs"
```

- The *overlayfs* partition will be formatted as* ext4*.
- The overlay data will be copied to this new partition
- `/etc/config/fstab` entries will be generated (partitions will be automount)
- `fstab` service will be enabled (just to make sure)
- device reboot

```
ansible-playbook -i '<fqdn | ip >,' openwrt.yml -e openwrt_extroot=True
```

or for a simple 1-liner:

```
ansible -i '<fqdn | ip >,' -m script -a files/extroot.sh
```

**Step 2 (optional): Install packages**

Install a basic list of packages of your choosing. I only use this with an
*extroot* and/or when I know I have enough storage and/or I know I don't want to
install python.

```
ansible-playbook -i '<fqdn | ip >,' openwrt.yml -e openwrt_packages=True
```

or for a simple 1-liner:

```
ansible -i '<fqdn | ip >,' -m script -a files/packages.sh
```

**Step 3: Configure OpenWRT subsystems (Default behavior)**

Configure various OpenWRT subsystems. Available subsystems are: dnsmasq, dropbear,
firewall, fstab, network, qos, samba, system, wireless. However I use it only
for those at the current moment.

- dropbear
- system
  - timezone
  - ntp
- dnsmasq
  - dnsmasq settings
  - dhcp.@host[i] -> (mac reservation)
  - dhcp.@domain[i] -> (dns entries)

That leaves other this like

- ddns
- qos
- firewall
- wireless
- network
- services (etherwake, ddns...)

to be done manually for the moment. Since this is the default configuration
you can plainly run this command to perform configuration tasks:

```
ansible-playbook -i <inventory file> openwrt.yml
```

### Alternatives

This is somewhat inspired from the work of lefant. I gathered all his work on a
single module wich i slightly modified. See [this
role]("https://github.com/lefant/ansible-openwrt").
