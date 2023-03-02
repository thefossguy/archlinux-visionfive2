# README

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

**NOTE: Please use `doas` as an alterntive to `sudo`.

## CHECKSUMS

```
# SHA512

# SHA256

# MD5
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
