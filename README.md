# ansible-lede

A role to manage LEDE/Openwrt configuration.

## Ansible requirements

### Ansible version

Minimum required ansible version is 2.0.

### Ansible role dependencies

None.

## Installation

### Install with Ansible Galaxy

```shell
ansible-galaxy install archf.lede
```

Basic usage is:

```yaml
- hosts: all
  roles:
    - role: archf.lede
```

### Install with git

If you do not want a global installation, clone it into your `roles_path`.

```shell
git clone git@github.com:archf/ansible-lede.git /path/to/roles_path
```

But I often add it as a submdule in a given `playbook_dir` repository.

```shell
git submodule add git@github.com:archf/ansible-lede.git <playbook_dir>/roles/lede
```

As the role is not managed by Ansible Galaxy, you do not have to specify the
github user account.

Basic usage is:

```yaml
- hosts: all
  roles:
  - role: lede
```
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


## Role Variables

Variables are divided in three types.

The [default vars](#default-vars) section shows you which variables you may
override in your ansible inventory. As a matter of fact, all variables should
be defined there for explicitness, ease of documentation as well as overall
role manageability.

The [mandatory variables](#mandatory-variables) section contains variables that
for several reasons do not fit into the default variables. As name implies,
they must absolutely be defined in the inventory or else the role will
fail. It is a good thing to avoid reach for these as much as possible and/or
design the role with clear behavior when they're undefined.

The [context variables](#context-variables) are shown in section below hint you
on how runtime context may affects role execution.

### Default vars

Role default variables from `defaults/main.yml`.

```yaml
######################
# Action to perform.
######################

# Create an extroot by running script `files/extroot.sh`.
openwrt_extroot: False

# Ansible bootstrap. Install Ansible dependencies using the raw module.
openwrt_ansible_bootstrap: False

# Install packages by running script 'files/packages.sh'
openwrt_packages: False

# dhcp subsystem
openwrt_dhcp:
  dnsmasq: |
    # Don't forward DNS-Requests without DNS-Name
    set dhcp.@dnsmasq[0].domainneeded='1'
    set dhcp.@dnsmasq[0].boguspriv='1'
    set dhcp.@dnsmasq[0].localise_queries='1'
    # Discard upstream RFC1918 responses
    set dhcp.@dnsmasq[0].rebind_protection='1'
    # Allow upstream responses in the 127.0.0.0/8 range, e.g. for RBL services
    set dhcp.@dnsmasq[0].rebind_localhost='1'
    # Local domain specification. Names matching this domain are never forwarded
    # and are resolved from DHCP or hosts files only.
    set dhcp.@dnsmasq[0].local='/lan/'
    # Local domain suffix appended to DHCP names and hosts file entries
    set dhcp.@dnsmasq[0].domain='lan'
    # Add the domain to simple names (without a period) in /etc/hosts in the
    # same way as for DHCP-derived names. Note that this does not apply to
    # domain names in cnames, PTR records, TXT records etc.
    set dhcp.@dnsmasq[0].expandhosts='1'
    # This is the only DHCP in the local network
    set dhcp.@dnsmasq[0].authoritative='1'
    # Read /etc/ethers for information about hosts for the DHCP server.
    set dhcp.@dnsmasq[0].readethers='1'
    # List of DNS servers to forward requests to
    # set dhcp.@dnsmasq[0].server=''
    # Limit DNS service to subnets interfaces on which we are serving DNS.
    set dhcp.@dnsmasq[0].localservice='0'
    #  Bind only to specific interfaces rather than wildcard address.
    set dhcp.@dnsmasq[0].nonwildcard='1'

  # DNS entries. This works well with updating existing entries only.
  domains: null
   # set dhcp.@domain[0]=domain
   # set dhcp.@domain[0].name=example.org
   # set dhcp.@domain[0].ip=192.168.2.145

  # mac reservation
  # The format of /etc/ethers is a hardware address, followed by either a
  # hostname or an address. Better use that instead.
  hosts: |
    set dhcp.@host[0]=host
    set dhcp.@host[0].mac=78:24:af:38:9b:df
    set dhcp.@host[0].ip=192.168.2.205
    set dhcp.@host[0].name=ds00.lan

  interfaces:
    - lan: |
        set dhcp.lan=dhcp
        set dhcp.lan.interface='lan'
        set dhcp.lan.start='100'
        set dhcp.lan.limit='150'
        set dhcp.lan.leasetime='12h'
        set dhcp.lan.dhcpv6='server'
        set dhcp.lan.ra='server'
        set dhcp.lan.ra_management='2'

    # - wan: |
    #     set dhcp.wan=dhcp
    #     set dhcp.wan.interface='wan'
    #     set dhcp.wan.ignore='1'
    #     set dhcp.odhcpd=odhcpd
    #     set dhcp.odhcpd.maindhcp='0'

# dropbear
openwrt_dropbear: |
  # lan
  set dropbear.@dropbear[0].PasswordAuth='on'
  set dropbear.@dropbear[0].Interface='lan'
  set dropbear.@dropbear[0].Port='22222'
  # Allow remote hosts to connect to local SSH forwarded ports
  set dropbear.@dropbear[0].GatewayPorts='on'
  # wan
  # set dropbear.@dropbear[1]=dropbear
  set dropbear.@dropbear[1].PasswordAuth='on'
  set dropbear.@dropbear[1].Interface='wwan'
  set dropbear.@dropbear[1].Port='22222'
  # Allow remote hosts to connect to local SSH forwarded ports
  set dropbear.@dropbear[0].GatewayPorts='on'

# System
openwrt_system:
  hostname: gw00
  # see https://lede-project.org/docs/user-guide/system_configuration
  timezone: |
    set system.@system[0].zonename='utc'
    set system.@system[0].timezone=''
  ntp: |
    set system.ntp.enabled='1'
    set system.ntp.enable_server='1'
    set system.ntp.server='resolver1.level3.net' 'alpha.codatory.net' 'ntp1.torix.ca' 'ntp3.torix.ca'

# firewall:
#   # zone 0 is wan
#   # zone 1 is lan
#   # zone 2 is guest
#   policies:
#     - chain: output
#       policy: ACCEPT
#       zone: [0,1,2]

#     - chain: input
#       policy: ACCEPT
#       zone: [1]
#     - chain: input
#       policy: REJECT
#       zone: [0,2]

#     - chain: forward
#       policy: ACCEPT
#       zone: [1]
#     - chain: forward
#       policy: REJECT
#       zone: [0,2]

#   forwarding:
#     - index: 0
#       settings:
#       - key: src
#         value: guest
#       - key: dest
#         value: wan

#   redirect: []

# # lede_pkgs:
# #   - vim
# #   - tmux
# #   - git
# #   - tcpdump
# #   - nmap
# #   - mtr
# #   - rsync
# #   - zsh
# #   - shadow
# #   - sudo
# #   - bind-dig
# #   - python3
# #   - python3-pip
# #   - block-mount
# #   - kmod-usb-storage
# #   - kmod-fs-ext4
# #   - wget
# #   - curl
# #   - less
# #   - zsh
# #   - wol
# #   - etherwake
# #   # - ca-certificates
# #   # - openssh-client
# #   # - openssh-server
# #   # - openssh-keygen
# #   # - openssh-sftp-server
# #   # - openssh-client-utils
# #   # - python3-openssl

```

### Mandatory variables

None.

### Context variables

None.



## License

BSD.

## Author Information

Felix Archambault.

---
Please do not edit this file. This role `README.md` was generated using the
'ansidoc' python tool available on pypi!

*Installation:*

```shell
pip3 install ansidoc
```

*Basic usage:*

Validate output by running a dry-run (will output result to stdout)
```shell
ansidoc --dry-run <rolepath>
```

Generate you role readme file. Will write a `README.md` file under
`<rolepath>/README.md`.
```shell
ansidoc <rolepath>
```

Also usable programatically from Sphinx.