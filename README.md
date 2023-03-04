# README

**This is a very minimal image that may not even display anything over HDMI.
This image is used for "server-like" applications where you already have a
serial conosole (over UART).**

**Please refer to the releases section and make sure that your board firmware
matches with what is expected.**

Build your own `.img` file using the `create-image.sh` shell script. Otherwise, just
`dd` the provided image like so:

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

**NOTE: Please use `doas` as an alterntive to `sudo`.**

## CHECKSUMS

```
# SHA512
6c172f623e387801b248847246437aa74756908824500fa1381cbf51e2f24966f6e9e7822a5a564dca25b0ff696cb1bac51d52366e19881f33f49b65057c2
f37  archlinux-2023.03.02-riscv64.img
9064c83af1c081c9a3de4c4f02e8212a9730c30e19041ad9e0618d6fbf40e71cbf33e96a47ee6965f0cd1f616ef366db14c93f47328840bbb02ec2276289e
54b  archlinux-2023.03.02-riscv64.img.zst

# SHA256
50673a26991357422a8c35bd082a79ea1276b6de1d11c8a221b13d23a783e13a  archlinux-2023.03.02-riscv64.img
c92e60af5e70790e6859904f772d247e30c8d13d8fade6e4cd87bef08d7d9663  archlinux-2023.03.02-riscv64.img.zst

# MD5
03495db4f2523f5e92740cae7f19f215  archlinux-2023.03.02-riscv64.img
7a2822f85bfbd10817b8f60f9a4c538b  archlinux-2023.03.02-riscv64.img.zst
```


## User accounts info:

```
username: riscv
password: changeme
---
username: root
password: root
```

---

If you wish to modify any aspect of this image, everything except for the image
creation is similar to a typical Arch Linux installation.

To modify the user that is created, search and replace `riscv` with your user's
username in the `chroot-setup.sh` file. To change the password, search and
replace the string `changeme` with whatever you want.
