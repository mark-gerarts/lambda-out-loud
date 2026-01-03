---
title: "Alpine Linux Desktop Setup"
date: 2026-01-03T14:53:22+01:00
draft: true
summary: "Setting up Alpine Linux as a daily driver."
tags:
    - Linux
    - Alpine
---

With me returning to academia, I find myself having to dust off an IdeaPad
to bridge the following months. My usual Linux desktop setup,
[NixOS](https://github.com/mark-gerarts/m), feels a bit sluggish on this old
hardware. [Alpine Linux](https://www.alpinelinux.org/) is famous for its low
memory usage and disk size, making it the perfect candidate to revive my laptop.

![Alpine Linux running several applications on Xfce](/static/img/alpine-desktop.png)

## Why Alpine

- Low resource requirements
- APK package manager
- Philosophy

Con:

- Musl
- Small userbase

## Initial Setup

- setup-alpine and simply follow the steps
- community repos, [1], create user, cryptsys

## Terminal Bleep

```sh
rmmod pcspkr
echo "blacklist pcspkr" >> /etc/modprobe.d/blacklist.conf
```

## Xfce Install

```sh
# Fix for loss of networking after xfce install
# See https://gitlab.alpinelinux.org/alpine/aports/-/issues/9079
echo "rc_need=udev-settle" > /etc/conf.d/networking
```

```sh
setup-desktop
```

## Log in Automatically

LightDM config

## Disable DHCP on Boot

Hugo [^hugo]

```sh
sed -i 's/iface wlan0 inet dhcp/# iface wlan0 inet dhcp/' /etc/network/interfaces
sed -i 's/iface eth0 inet dhcp/# iface eth0 inet dhcp/' /etc/network/interfaces
rc-update -q add dhcpcd default
```

## Bluetooth

```sh
apk add blueman
rc-update -q add bluetooth default
```

## Bash as Default Shell

```sh
apk add shadow
chsh mark --shell /bin/bash
```

## Qwerty-fr Keyboard

## Reboot & Shutdown as a Regular User

## NetworkManager

## GPU

## Dotfiles & User Configuration

home/setup.sh

## Setup Script

- See mark-gerarts/m/alpine/setup.sh

## Conclusion

[^hugo]: https://whynothugo.nl/journal/2023/11/19/setting-up-an-alpine-linux-workstation/
