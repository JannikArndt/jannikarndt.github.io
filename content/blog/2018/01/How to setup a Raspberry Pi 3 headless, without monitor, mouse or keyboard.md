+++
title = "How to setup a Raspberry Pi 3 headless, without monitor, mouse or keyboard"
draft = false
date = "2018-01-13T12:00:00+01:00"
keywords = [ "Raspberry Pi", "Raspberry Pi 3", "Setup", "How to", "Headless", "Raspbian", "SSH", "MacOS" ]
slug = "raspberry_pi_3_headless_setup"
toc = true

[params]
  author = "Jannik Arndt"
+++

I bought a raspberry pi as a smart home automation server. Here's how to set it up without connecting a monitor, mouse or keyboard. All you need is an ethernet cable.

<!--more-->

## 1. Prepare the SD card

1. Download Raspbian from <https://www.raspberrypi.org/downloads/raspbian/>
1. Copy it to the SD card, using
   - [ApplePi Baker](https://www.tweaking4all.com/software/macosx-software/macosx-apple-pi-baker/) or
   - [Etcher](https://etcher.io) or
   - your Terminal:
  ```bash
  sudo dd bs=1m if=[path to img file, e.g. "2017-08-16-raspbian-stretch.img"] of=[path to rdisk, e.g. "/dev/rdisk2"] conv=sync
  ```
1. Enabled `ssh` access _for one start_ by creating an `ssh` file in the `boot` folder:
  ```bash
  touch /Volumes/boot/ssh
  ```
1. Eject the SD card (via the button in Finder or `diskutil eject /dev/disk2`)

## 2. Prepare your Mac

You need to enabled _Internet Sharing_ on MacOS so the Pi can connect to it. Go to _System Settings_ > _Sharing_:
![](../pi/sharing_pane.png)

## 3. Configure SSH access

This assumes that you have an ssh key. If not or you don't know what that is: An ssh key consist of two files: A private and a public one. The private one (`id_rsa`) is on _your_ computer and works like a password (so do _not_ share it!). The public one (`id_rsa.pub`) is on _other_ computers and identifies you. It only works together with your private key, so don't loose it. Your public key is on your computer as well so you can easily share it.

You can find both keys with

```bash
$ ls -l ~/.ssh
total 120
-rw-------  1 jannikarndt  staff  1766 Jan  3  2017 id_rsa
-rw-r--r--@ 1 jannikarndt  staff   403 Jan  3  2017 id_rsa.pub
```

If you don't have a key, GitHub has a [great article on how to create one](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/).

1. Copy your ssh key to the pi:
  ```bash
  cat ~/.ssh/id_rsa.pub | ssh pi@raspberrypi.local "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
  ```

1. SSH into the pi:
  ```bash
  ssh pi@192.168.2.2
  pi@192.168.2.2's password: raspberry
  ```
  The preconfigured password is `raspberry`. A good reason to change it right away:

1. Change your root password:
  ```bash
  sudo raspi-config
  ```
  ![](../pi/raspi-config.png)

1. Add your wifi credentials in `2 Network Options` > `N2 Wi-fi`

1. Permanently enable ssh access in `5 Interfacing Options` > `P2 SSH`.

## 4. Install `oh-my-zsh`

And now, for the grand finale, you can (should / will want to) install a proper shell, i.e. [oh my zsh](http://ohmyz.sh):

```bash
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install git zsh
chsh -s /bin/zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

## 5. Continue

Great! Now you can use your Pi, for example

- with Apple Home and Sonoff devices to [control your smart home]({{< ref "How to use a Raspberry Pi 3 with Apple Home.md" >}}) or
- as an alternative to [Apples 329€ Time Capsule](https://www.apple.com/de/shop/product/ME177Z/A) [for Time Machine backups over wifi]({{< ref "How to use a Raspberry Pi for your Time Machine backups.md" >}}).