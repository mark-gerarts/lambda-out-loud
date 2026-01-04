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

This post documents how I set up Alpine with the Xfce desktop. By definition,
setting up a personal PC is very opinionated, but hopefully this post can be a
starting point for others who want to do the same.

![Alpine Linux running several applications on Xfce](/static/img/alpine-desktop.png)

## Why Alpine

Alpine's beauty lies in its simplicity. I fell in love with it because of how
easy it is to understand all the moving parts, as opposed to more bulky
distributions.

There are other advantages as well:

- Alpine is *tiny* --- a minimal installation only takes 130MB of storage.
- It has low resource requirements, not only for disk size but for RAM as well.
- Alpine's package manager, APK, is best-in-class. It is fast and intuitive to
  use, and easy to configure. I especially love how only root dependencies are
  added to a `world` file; APK figures other dependencies out itself.
- The init system, [OpenRC](https://wiki.alpinelinux.org/wiki/OpenRC), is simple
  and fast.

The biggest cons are closely related to the advantages:

- Because Alpine is tiny and simple, it requires a lot of extra work to set up
  something as complex as a desktop OS --- hence this blog post.
- Alpine is built on musl libc. I admire this effort, but this means that
  proprietary binaries are mostlikely compiled for glibc and thus won't work.
- Alpine's userbase is small, meaning fewer packages and less people to ask for
  help.

## Initial Setup

After booting Alpine from a USB, you can log in as the root user without a
password. From here, run `setup-alpine` and answer the prompts. I enable the
community repository, create a user for myself, and enable full disk encryption
(FDE) by opting for `cryptsys` when prompted for the installation method. After
this, unplug the USB and reboot into Alpine.

## Terminal Bleep

When using tab-completion, I am confronted with an uncomfortably loud terminal
bleep. I silence it by removing the kernel module and blacklist it to make
the change permanent[^bleep]:

```sh
rmmod pcspkr
echo "blacklist pcspkr" >> /etc/modprobe.d/blacklist.conf
```

## Xfce

Alpine has a `setup-desktop` script to easily install and configure a desktop
environment. However, this script caused an issue with my network drivers on my
first installation attempt, making me unable to connect to the internet. This is
a [known issue](https://gitlab.alpinelinux.org/alpine/aports/-/issues/9079). The
workaround is to first add the following config:

```sh
echo "rc_need=udev-settle" > /etc/conf.d/networking
```

And only then run the `setup-desktop` script. I like Xfce as my desktop, as it
lies close to Alpine's small-and-simple philosophy.

```sh
setup-desktop xfce
```

## Log in Automatically

At this point I reboot again to see if the display manager (LightDM) works. As
expected, it does! However, it is a bit tedious to have to type my password to
decrypt the disk and again to unlock the display manager. That's why I prefer to
configure autologin for LightDM. This is done in the `[Seat:*]` section of
`/etc/lightdm/lightdm.conf`:

```ini
# ...
[Seat:*]
autologin-user=mark
autologin-user-timeout=0
# ...
```

## Disable DHCP on Boot

When I rebooted, I also noticed that Alpine waits for DHCP to finish before
continuing the boot process. This is good for servers, but not really needed for
a desktop PC. Hugo Osvaldo Barrera solves this problem by removing the dhcp
lines from
`/etc/network/interfaces`[^hugo]:

```sh
auto lo
iface lo inet loopback

auto eth0
# v Remove/comment this line v
# iface eth0 inet dhcp

auto wlan0
# v Remove/comment this line v
iface wlan0 inet dhcp
```

And then configure [dhcpcd](https://wiki.archlinux.org/title/Dhcpcd) instead:

```sh
apk add dhcpcd
rc-update add dhcpcd default
```

## Bluetooth

Setting up bluetooth is as easy as adding a package and enabling the service:

```sh
apk add blueman
rc-update add bluetooth default
```

## Bash as Default Shell

Alpine ships the [ash](https://wiki.alpinelinux.org/wiki/Shell_management) shell
by default. I prefer Bash for portability across servers. I can change this by
editing the `/etc/passwd` manually, but I opt for `chsh` from the `shadow`
package because this is easier to script (more on that later).

```sh
apk add bash shadow
chsh mark --shell /bin/bash
```

## Qwerty-fr Keyboard

I live in Belgium, which means I often have to use French accents.
[QWERTY-fr](https://qwerty-fr.org/) is a fantastic keyboard layout that uses the
right alt key to type special characters, but is a standard QWERTY layout
otherwise.

Since Xfce still uses X11, we can use `setxkbmap` to configure this layout.
First, download it and install the symbols file:

```sh
wget -q https://raw.githubusercontent.com/qwerty-fr/qwerty-fr/master/linux/us_qwerty-fr \
  -O /usr/share/X11/xkb/symbols/us_qwerty-fr
```

Then I add a startup application that activates this layout:

```sh
mkdir -p /home/mark/.config/autostart
    cat <<EOF > /home/mark/.config/autostart/qwerty-fr.desktop
[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=setxkbmap
Comment=
TryExec=setxkbmap
Exec=setxkbmap us_qwerty-fr
OnlyShowIn=XFCE;
RunHook=0
StartupNotify=false
Terminal=false
Hidden=false
EOF
```

Wayland: https://github.com/qwerty-fr/qwerty-fr/issues/49#issuecomment-1405254634

## Reboot & Shutdown as a Regular User

## NetworkManager

## GPU

## Packages

List of random packages /etc/apk/world

## Dotfiles & User Configuration

home/setup.sh

## Setup Script

- See mark-gerarts/m/alpine/setup.sh

## Conclusion

[^bleep]: https://unix.stackexchange.com/a/453018
[^hugo]: https://whynothugo.nl/journal/2023/11/19/setting-up-an-alpine-linux-workstation/
