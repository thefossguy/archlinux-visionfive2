# README

**This is a very minimal image that may not even display anything over HDMI.
This image is used for "server-like" applications where you already have a
serial conosole (over UART).**

**Please refer to the releases section and make sure that your board firmware
matches with what is expected.**

Build your own `.img` file using the `create-image.sh` shell script. Otherwise,
just `dd` the provided image like so:

```bash
sudo dd conv=sync status=progress if=archlinux-*-riscv64.img \
    of=DEVICE_PATH
```

**You will still need to expand the last (root) partition.**

To do so, run the `post-dd.sh` shell script using **only the device path**
(not the partition number).

For example, if your drive is called `/dev/sdz`, do this:

```bash
sudo ./post-dd.sh /dev/sdz
```


## User accounts info:

```
username: riscv
password: changeme
---
username: root
password: starfive
```


## TODO

 - [x] [Switch from `dash` to `bash`](https://github.com/thefossguy/archlinux-visionfive2/commit/d6373144f211f8bef89b777b632edac30c9fde96)
 - [x] [Add check to see if script is running as root](https://github.com/thefossguy/archlinux-visionfive2/commit/2c978ffc45cf6ee1f688bccb23d59d386d2314ff)
 - [x] [Set timezone to UTC](https://github.com/thefossguy/archlinux-visionfive2/commit/177921dcfd7279d929459a23c295097ba437c359)
 - [ ] Enable NTP
 - [x] [Use `archlinux` as machine hostname](https://github.com/thefossguy/archlinux-visionfive2/commit/303901a8da75f6c415adcd9a4938f4653956f6e2)
 - [ ] Check if all necessary packages are installed, to make use of utilities
 - [ ] Reduce image size
 - [x] [Don't set `root`'s password to `root`. As per Ankur's suggestion, `starfive` sounds like a good way to go.](https://github.com/thefossguy/archlinux-visionfive2/commit/ca57334e3b5419845197a3c83cde9d017baf3af2)
 - [x] [Disable `root` login over `ssh`](https://github.com/thefossguy/archlinux-visionfive2/commit/616316f926dc7854153bd1126f35e40e29cabdfa)
 - [x] [Allow user to use `sudo` and not strictly use `doas`](https://github.com/thefossguy/archlinux-visionfive2/commit/292283f0e7bff4e105ed1c9f776ef71d37f4410c)


---

If you wish to modify any aspect of this image, everything except for the image
creation is similar to a typical Arch Linux installation.

To modify the user that is created, search and replace `riscv` with your user's
username in the `chroot-setup.sh` file. To change the password, search and
replace the string `changeme` with whatever you want.
