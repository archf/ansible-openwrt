# ansible-openwrt

A role to manage your openwrt configuration.

## Requirements

### Ansible version

Minimum required ansible version is 2.0.

### Other considerations

All you need is a ssh acces to your target openwrt system. Run your play by
with "remote_user: root".


## Description

A role to configure openwrt. It works using a custom shell module to avoid requiring python on the target.
This is greatly inspired from the work of lefant. I gathered all his work on a single module
wich i slightly modified.

See [this role]("https://github.com/lefant/ansible-openwrt") or ansible-openwrt on ansible-galaxy


## Role Variables

### Variables conditionally loaded

None.

### Default vars

Defaults from `defaults/main.yml`.

```yaml
# defaults file for openwrt
hostname: OpenWrt

ntpconf:
  enabled: 1
  enable_server: 1

# uci: command=set key="dropbear.@dropbear[0]
dropbear:
  port: 22222

ntp_servers:
  - 0.openwrt.pool.ntp.org
  - 1.openwrt.pool.ntp.org
  - 2.openwrt.pool.ntp.org
  - 2.openwrt.pool.ntp.org

# system.@system[0].zonename
timezone: utc

# network.lan
lan:
  ipaddr: 192.168.1.1
  netmaks: 255.255.255.0

# dhcp.lan
dhcp:
  start: 100
  limit: 150
  leasetime: 12h

ddns: {}

wireless:
  - key: ssid
    value: myssid
    ifaces: [0]
  - key: ssid
    value: myssid-guest
    ifaces: [1]
  - key: ssid
    value: myssid5
    ifaces: [3]
  - key: ssid
    value: myssid-guest5
    ifaces: [4]
  - key: encryption
    value: psk2
    ifaces: [0,3,4]
  - key: key
    value: mysecret
    ifaces: [0,3,4]

    # defaults file for openwrt
wireless:
  - key: ssid
    value: CEROwrt
    ifaces: [0]
  - key: ssid
    value: CEROwrt5
    ifaces: [3]
  - key: encryption
    value: psk2
    ifaces: [0,3]
  - key: key
    value: Beatthebloat
    ifaces: [0,3]
  - key: ssid
    value: CEROwrt-guest
    ifaces: [1]
  - key: ssid
    value: CEROwrt-guest5
    ifaces: [4]
  - key: encryption
    value: none
    ifaces: [1,4]
  - key: key
    value: ""
    ifaces: [1,4]

# defaults file for openwrt
ddns: {}

dnsmasq:
  server: []

firewall:
  redirect:
    - index: 0
      settings:
        - key: target
          value: DNAT
        - key: src
          value: wan
        - key: dest
          value: lan
        - key: proto
          value: tcp
        - key: src_dport
          value: 22
        - key: dest_ip
          value: 172.30.42.16
        - key: dest_port
          value: 22
        - key: name
          value: ssh_lanbox

# defaults file for openwrt
firewall:
  # zone 0 is wan
  # zone 1 is lan
  # zone 2 is guest
  policies:
    - chain: output
      policy: ACCEPT
      zone: [0,1,2]

    - chain: input
      policy: ACCEPT
      zone: [1]
    - chain: input
      policy: REJECT
      zone: [0,2]

    - chain: forward
      policy: ACCEPT
      zone: [1]
    - chain: forward
      policy: REJECT
      zone: [0,2]

  forwarding:
    - index: 0
      settings:
      - key: src
        value: guest
      - key: dest
        value: wan

  redirect: []

```


## Installation

### Install with Ansible Galaxy

```shell
ansible-galaxy install archf.openwrt
```

Basic usage is:

```yaml
- hosts: all
  roles:
    - role: archf.openwrt
```

### Install with git

If you do not want a global installation, clone it into your `roles_path`.

```shell
git clone git@github.com:archf/ansible-openwrt.git /path/to/roles_path
```

But I often add it as a submdule in a given `playbook_dir` repository.

```shell
git submodule add git@github.com:archf/ansible-openwrt.git <playbook_dir>/roles/openwrt
```

As the role is not managed by Ansible Galaxy, you do not have to specify the
github user account.

Basic usage is:

```yaml
- hosts: all
  roles:
  - role: openwrt
```

## Ansible role dependencies

None.

## License

BSD.

## Author Information

Felix Archambault.

## Role stack

This role was carefully selected to be part an ultimate deck of roles to manage
your infrastructure.

All roles' documentation is wrapped in this [convenient guide](http://127.0.0.1:8000/).


---
This README was generated using ansidoc. This tool is available on pypi!

```shell
pip3 install ansidoc

# validate by running a dry-run (will output result to stdout)
ansidoc --dry-run <rolepath>

# generate you role readme file
ansidoc <rolepath>
```

You can even use it programatically from sphinx. Check it out.