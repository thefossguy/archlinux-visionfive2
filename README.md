# Arch Linux riscv64 image builder

Build your own custom riscv64 Arch linux image. Whilst this image aims to be
minimal, the configuration is customisable allowing you to tailor it to your
needs.

The configuration here targets the StarFive VisionFive 2 SBC however with a
different kernel, firmware and u-boot, you could potentially support
other devices.

**This is a very minimal image that may not even display anything over HDMI.
This image is used for "server-like" applications where you already have a
serial conosole (over UART).**

**Please refer to the releases section and make sure that your board firmware
matches with what is expected.**

## Instructions
Build your own `.img` file using the `create-image.sh` shell script. `sudo` is
necessary as the creation of the image requires mounting filesystems and
`chroot`.
```bash
sudo ./create-image.sh
```

Thereafter,
just `dd` the provided image like so:
```bash
sudo dd conv=sync status=progress if=IMAGE_NAME \
    of=DEVICE_PATH
```

**You will still need to expand the last (root) partition.**

To do so, run the `post-dd.sh` shell script using **only the device path**
(not the partition number).

For example, if your drive is called `/dev/sdz`, do this:

```bash
sudo ./post-dd.sh /dev/sdz
```

**You need to change a few environment variables in uboot.**
As the board boots up, you will soon be greeted with the following
message:

```
Hit any key to stop autoboot:
```

**Immediately press any key to stop autoboot! You only have 2 seconds!**
Once you are in the uboot shell, run the following commands:

```
setenv boot_targets 'mmc0 mmc1 dhcp'
setenv bootcmd 'run load_distro_uenv; run distro_bootcmd'
setenv bootpart '0:1'
setenv fatbootpart '0:1'
setenv fdt_addr_r '0x88000000'
setenv fdtfile 'starfive/jh7110-visionfive-v2.dtb'
setenv kernel_addr_r '0x84000000'
setenv kernel_comp_addr_r '0x90000000'
setenv kernel_comp_size '0x10000000'
setenv load_distro_uenv 'fatload mmc ${devnum}:1 ${distroloadaddr} /${bootenv}; setenv fatbootpart ${devnum}:1; env import ${distroloadaddr} 200;'
setenv mmcpart '1'
setenv ramdisk_addr_r '0x88300000'
setenv scriptaddr '0x88100000'
```


Finally, run the `saveenv` command and then reset the board using the `reset` command.
If the board doesn't boot back up, manually reset its power.

## User accounts
```
username: riscv
password: changeme
```
The default username is `riscv` and specified in `image.conf` as `CONF_USER`
The default password is `changeme` and also specific in `image.conf` as
`CONF_PASSWORD`. Upon first login, you'll be prompted to change this password.

### Root access
The `root` account is disabled as a security measure. To elevate to `root`,
you need to use `sudo`

## Out of the box setup
The image is configured to setup networking via ethernet and the ssh server is
started on boot. This should provide headless access via ssh out of the box.
The default machine name is `archlinux-riscv` but this can be customised via
`image.conf`.

## Custom configuration
The default configuration for the image is stored in `image.conf`. The
`create-image.sh` script accepts an argument allowing you to specify your
own config. If a config file is not provided, the script will default to
`image.conf`. To use your own config, run:
```bash
sudo ./create-image.sh [<CONFIG>]
```
### Configuration parameters
| Parameter                     | Description                                         |
| ----------------------        | --------------------------------------------------- |
| `CONF_TIMEZONE`               | Timezone.                                           |
| `CONF_LOCALE`                 | Locale                                              |
| `CONF_HOSTNAME`               | Name of machine on the network.                     |
| `CONF_USER`                   | Username of sudo-capable user.                      |
| `CONF_USER_PASSWORD`          | Initial password for user. Forced change on login.  |
| `CONF_GROUPS`                 | Groups that the user is a part of. `wheel` for sudo |
| `CONF_PKGS_TO_INSTALL`        | Installed pacakges within image.                    |
| `KERN_REL_URL`                | Where to get kernel packages, if not in `lfs` dir.  |
| `KERNEL_PKG`                  | Kernel package filename. Look in `lfs` dir first.   |
| `KERNEL_PKG_SHA512SUM`        | Kernel package sha512 checksum.                     |
| `KERNEL_HEADER_PKG`           | Kernel headers package. Look in `lfs` dir first.    |
| `KERNEL_HEADER_PKG_SHA512SUM` | Kernel headers package sha512 checksum.             |
| `IMAGE_NAME`                  | Filename of image to be created.                    |

