# Adding docker support to linux system

Getting docker running on android is unlikely as the android kernel gernally does not support all required features. Therefore a VM based approach is chosen.

As of now there is no kvm support on the Xiaomi Pad 6 making the VM too slow. Execution of an already pulled hello-world docker container took around 12s. On my notebook it took 0.6s. \
-> i gave up on that approach too.

As i absolutely require docker support i have chosen to run it on my phone (Google Pixel 6 pro). It has kvm support. This has the additional advantage of saving memory on the Tablet.

Docker allows connecting to a remote docker service. In theory this should result in being able to work with docker like it is running locally. I do not yet know whether or not this actually works for my development scenario.

# Setting up docker

As i will do this on my phone i will do it directly in termux. With some smal adjustments it is possible to do it in chroot on the tablet.

Install qemu: pkg i qemu-system-aarch64-headless

# if /dev/kvm does not exist, it is possible to continue this guide, but the performance will be very bad.
# in the qemu-system-aarch64 commands remove -accel=kvm and change -cpu=host to -cpu=max

mkdir qemu-docker
cd qemu-docker

qemu-img create -f qcow2 docker.qcow2 10G

wget -O alpine.iso https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/aarch64/alpine-virt-3.21.3-aarch64.iso

qemu-system-aarch64 -m 512 -smp 4 -nographic -bios /usr/share/qemu-efi-aarch64/QEMU_EFI.fd -drive if=virtio,file=docker.qcow2,format=qcow2 -cdrom alpine.iso -netdev user,id=net0,hostfwd=tcp::2222-:22 -device virtio-net-device,netdev=net0 -device virtio-balloon -machine virt -cpu max
# if /dev/kvm exists - kvm is supported use this
# qemu-system-aarch64 -m 512 -smp 4 -nographic -bios /usr/share/qemu-efi-aarch64/QEMU_EFI.fd -drive if=virtio,file=docker.qcow2,format=qcow2 -cdrom alpine.iso -netdev user,id=net0,hostfwd=tcp::2222-:22 -device virtio-net-device,netdev=net0 -device virtio-balloon -machine virt,accel=kvm -cpu=host

# login as root. root has no password
# install with setup-alpine. select installation method "sys"


# now in vm
sed -i '/community/s/^#//' /etc/apk/repositories
apk add docker
rc-service docker start
rc-update add docker default
