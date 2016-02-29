# Docker Phan rootfs Builder

This builder image constructs a `rootfs.tar.gz` that is applied on a base Alpine
Linux image to build Phan images. The `mkimage-phan.bash` script does all
of the heavy lifting. During the configuration of the image the entrypoint is
added to the image.

## Options

The builder takes several options:

  * `-r <release>`: The phan release tag to use (such `0.2`) or the special
    `edge` to build the tip of master.
  * `-m <mirror>`: The Alpine Linux mirror base. Defaults to
    `http://nl.alpinelinux.org/alpine`.
  * `-s`: Outputs the `rootfs.tar.gz` to stdout.
