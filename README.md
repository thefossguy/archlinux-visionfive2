# NO LONGER MAINTAINED

Since there is no need of the vendor kernel to boot on the VisionFive 2, an image like this is no longer necessary. You can build one using the standard process now:


1. Create an image using `truncate -s <SIZE> <FILE>`.
2. Mount it to loopback.
3. Partition it.
4. Mount loopback devices to `/mnt/{,boot/{,efi}}`.
5. <standard Arch Linux installation procedure from here>
6. Profit
