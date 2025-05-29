# Adding docker support to linux system

Getting docker running on android is unlikely as the android kernel gernally does not support all required features. Therefore a VM based approach is chosen.

As of now there is no kvm support on the Xiaomi Pad 6 making the VM too slow. Execution of an already pulled hello-world docker container took around 12s. On my notebook it took 0.6s and on a pixel 6 pro with kvm 0.6 to 1.8s depending on core selection. \
-> i gave up on that approach too.

As i absolutely require docker support i have chosen to run it on my phone (Google Pixel 6 pro). It has kvm support. This has the additional advantage of saving memory on the Tablet.

Docker allows connecting to a remote docker service. In theory this should result in being able to work with docker like it is running locally. I do not yet know whether or not this actually works for my development scenario.

# Setting up docker

As i will do this on my phone i will do it directly in termux. With some smal adjustments it is possible to do it in chroot on the tablet.

Install qemu: pkg i qemu-system-aarch64-headless qemu-utils

# if /dev/kvm does not exist, it is possible to continue this guide, but the performance will be very bad.
# in the qemu-system-aarch64 commands remove -accel=kvm and change -cpu=host to -cpu=max

mkdir qemu-docker
cd qemu-docker

qemu-img create -f qcow2 docker.qcow2 10G

wget -O alpine.iso https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/aarch64/alpine-virt-3.21.3-aarch64.iso

# sudo required because of missing permissions of normal user
# taskset required because of kvm bug might be fixed with kernel 6.3 https://github.com/Joshua-Riek/ubuntu-rockchip/issues/731
# using cores 0,1,2,3 should be more efficient (most efficient cores)
# using cores 4,5 or 6,7 should be (way) faster, but likely consume more power and obviously allows less parallel tasks (less cores)  
# using a mixture results in the vm not starting
sudo taskset 0,1 qemu-system-aarch64 -m 1536 -smp 2 -nographic -bios $PREFIX/share/qemu/edk2-aarch64-code.fd -drive if=virtio,file=docker.qcow2,format=qcow2 -cdrom alpine.iso -netdev user,id=net0,hostfwd=tcp::2222-:22 -device virtio-net-device,netdev=net0 -machine virt -accel kvm -cpu host

# exiting vm: shutdown: poweroff, or via qemu: ctrl + a then x
# start vm from now on with the same command but without -cdrom

# login as root. root has no password
# install with setup-alpine. select a disk when prompted (default none) and installation method "sys"


# now in vm
sed -i '/community/s/^#//' /etc/apk/repositories
apk add docker
rc-service docker start
rc-update add docker default
