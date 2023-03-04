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
 - [ ] Add check to see if script is running as root
 - [ ] Set timezone to UTC
 - [ ] Enable NTP
 - [ ] Use `archlinux` as machine hostname
 - [ ] Check if all necessary packages are installed, to make use of utilities
 - [ ] Reduce image size
 - [ ] Don't set `root`'s password to `root`. As per Ankur's suggestion,
 `starfive` sounds like a good way to go.
 - [ ] Disable `root` login over `ssh`


---

If you wish to modify any aspect of this image, everything except for the image
creation is similar to a typical Arch Linux installation.

To modify the user that is created, search and replace `riscv` with your user's
username in the `chroot-setup.sh` file. To change the password, search and
replace the string `changeme` with whatever you want.
