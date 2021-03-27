+++
title = "How to use a Raspberry Pi 3 with Apple Home"
draft = false
date = "2018-01-13T12:40:00+01:00"
keywords = [ "Raspberry Pi", "Raspberry Pi 3", "Setup", "How to", "MacOS", "iOS", "HomeKit", "Apple Home", "Homebridge", "MQTT", "Mosquitto" ]
tags = [ "Programming", "Raspberry Pi", "Smart Home" ]
slug = "how_to_use_a_raspberry_pi_3_with_apple_home"
toc = true

[params]
  author = "Jannik Arndt"
+++

“Hey Siri, turn on the bedroom lights!” I want that. Here's how I did it:

- I bought a bunch of Sonoff devices (5€ each, 10€ for a light switch).
- I bought a raspberry pi (33€).
- I installed an MQTT broker and homebridge on the pi.

<!--more-->

## 1. Set up the pi

=> See [How to setup a Raspberry Pi 3 headless, without monitor, mouse or keyboard]({{< ref "How to setup a Raspberry Pi 3 headless, without monitor, mouse or keyboard.md" >}})

## 2. Install `mosquitto` and `homebridge`

…and everything else you need:

```shell
$ sudo apt-get update && sudo apt-get upgrade
$ sudo apt-get install mosquitto
$ sudo apt-get install make
$ sudo apt-get install nodejs
$ sudo apt-get install libavahi-compat-libdnssd-dev
$ sudo apt-get install npm

$ sudo npm install -g homebridge
$ sudo npm install -g homebridge-mqtt-switch-tasmota  # for sonoff devices
```

## 3. Configure `mosquitto`

The default for `mosquitto` is to run without any security. Let's not do this. This creates a user “home” with a password:

```shell
$ sudo mosquitto_passwd -c /etc/mosquitto/passwd home
Password: yourpassword
Reenter password: yourpassword
```

This will create a password file. You can look at it with

```shell
$ cat /etc/mosquitto/passwd
home:$6$yjSnOc95804YRW/E$lokE/zzg4XwKj1BJPOxXDq4njkeovnecAvtYCOmNYgn5v/c8sHP08LnH7rDP0uU59hzmV/5iTXsudDrO6RMWPl+A==
```

Now we need to tell `mosquitto` to use this password file:

```shell
$ sudo nano /etc/mosquitto/mosquitto.conf
```

Add the lines

```ini
password_file /etc/mosquitto/passwd
allow_anonymous false
```

Exit with `ctrl + x`, `y` and `enter`.

Now restart the daemon:

```shell
$ sudo systemctl restart mosquitto
```

You can check the status with

```shell
$ sudo /etc/init.d/mosquitto status
```

## 4. Configure `homebridge`

First we'll create a config file for homebridge and open it:

```shell
$ mkdir ~/.homebridge
$ touch ~/.homebridge/config.json
$ nano ~/.homebridge/config.json
```

![](../pi/homebridge_config.png)

Your config should look something like this:

```json
{
  "bridge": {
    "name": "Raspberry Pi",
    "username": "XX:XX:XX:XX:XX:XX",
    "port": 51826,
    "pin": "XXX-XX-XXX"
  },

  "platforms": [],

  "accessories": [{
      "accessory": "mqtt-switch-tasmota",

      "name": "My Smart Device",

      "url": "mqtt://127.0.0.1",
      "username": "home",
      "password": "your password from step 3",

      "topics": {
        "statusGet": "stat/topic_for_this_device/POWER",
        "statusSet": "cmnd/topic_for_this_device/POWER",
        "stateGet": "tele/topic_for_this_device/STATE"
      }
    },
    {}
  ]
}
```

For more information have a look at the [config.json sample](https://github.com/nfarina/homebridge/blob/master/config-sample.json) or the page of the plugin you're using ([mqtt-switch-tasmota](https://github.com/MacWyznawca/homebridge-mqtt-switch-tasmota/blob/master/config.json) in my case).

If you don't like `nano` you can also copy the file to your computer, edit it there and then copy it back:

```shell
$ scp pi@192.168.31.231:.homebridge/config.json ~/Downloads/homebridge.json
config.json                                         100% 1830   149.2KB/s   00:00
# edit
$ scp ~/Downloads/homebridge.json pi@192.168.31.231:.homebridge/config.json
homebridge.json                                     100% 1457   268.4KB/s   00:00
```

But beware: Do _not_ edit the file in TextEdit, as it changes the format.

You should now be able to start the `homebridge` app:

```shell
$ homebridge
```

![](../pi/homebridge_start.png)

## 5. Start homebridge on startup

Great! Now all that's left is to create a user and a service to run `homebridge` on startup. For this I followed [this guide](https://timleland.com/setup-homebridge-to-start-on-bootup/):

1. Create a file for default parameters
  ```shell
  $ sudo nano /etc/default/homebridge
  ```
  and paste `HOMEBRIDGE_OPTS=-U /var/homebridge` into the file. Quit with `ctrl + x`, `y`, `enter`.

1. Create a service in `systemd`
  ```shell
  $ sudo nano /etc/systemd/system/homebridge.service
  ```
  and paste
  ```ini
  [Unit]
  Description=Node.js HomeKit Server
  After=syslog.target network-online.target
  #
  [Service]
  Type=simple
  User=homebridge
  EnvironmentFile=/etc/default/homebridge
  ExecStart=/usr/local/bin/homebridge $HOMEBRIDGE_OPTS
  Restart=on-failure
  RestartSec=10
  KillMode=process
  #
  [Install]
  WantedBy=multi-user.target
  ```

1. Create a user `homebridge`
  ```shell
  $ sudo useradd --system homebridge
  ```

1. Create a directory for the config
  ```shell
  $ sudo mkdir /var/homebridge
  $ sudo cp ~/.homebridge/config.json /var/homebridge/
  $ sudo cp -r ~/.homebridge/persist /var/homebridge
  ```

1. Start the service
  ```shell
  $ sudo chmod -R 0777 /var/homebridge
  $ sudo systemctl daemon-reload
  $ sudo systemctl enable homebridge
  $ sudo systemctl start homebridge
  $ systemctl status homebridge
  ```

Notice that the `config.json` is now copied to a different folder, so if you change the one in `~/.homebridge/` you need to copy it to `/var/homebridge/` afterwards!

```shell
$ sudo cp ~/.homebridge/config.json /var/homebridge/
$ sudo systemctl restart homebridge
```

## 6. Add smart devices

You now have control center for you smart devices! [Here is a guide on how to connect them!]({{< ref "How to install Tasmota on a Sonoff device without opening it.md" >}})