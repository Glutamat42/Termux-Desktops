# Adding docker support to linux system

Getting docker running on android is unlikely as the android kernel gernally does not support all required features. Therefore a VM based approach is chosen.

As of now there is no kvm support on the Xiaomi Pad 6 making the VM too slow. Execution of an already pulled hello-world docker container took around 12s. On my notebook it took 0.6s and on a pixel 6 pro with kvm 0.6 to 1.8s depending on core selection. \
-> i gave up on that approach too.

As i absolutely require docker support i have chosen to run it on my phone (Google Pixel 6 pro). It has kvm support. This has the additional advantage of saving memory on the Tablet.

Docker allows connecting to a remote docker service. This allows being able to work with docker like it is running locally with some limitations. Most notably it is not possible to bind mount local directories into containers.

# Setting up docker
> [!IMPORTANT]
> I wrote this guide during my work in getting this to work but I did not verify the guide afterwards. 
> It is to be expected to encounter some issues.


As i will do this on my phone i will do it directly in termux. With some smal adjustments it is possible to do it in chroot on the tablet.

if /dev/kvm does not exist, it is possible to continue this guide, but the performance will be poor.
In this case, in the qemu-system-aarch64 commands remove -accel=kvm and change -cpu=host to -cpu=max

## Initial setup on chroot

```bash
ssh-keygen -t ed25519
sudo apt-get install docker-cli
```


The generated pubkey will be required later when setting up the vm.

## initial setup on qemu device
About the qemu command:
- sudo required because of missing permissions of normal user
- taskset required because of kvm bug might be fixed with kernel 6.3 https://github.com/Joshua-Riek/ubuntu-rockchip/issues/731
  - using cores 0,1,2,3 should be more efficient (most efficient cores)
  - using cores 4,5 or 6,7 should be (way) faster, but likely consume more power and obviously allows less parallel tasks (less cores) using a mixture results in the vm not starting

```bash
$QEMU_COMMAND="taskset 0,1,2,3 qemu-system-aarch64 -m 2048 -smp 4 -nographic -bios $PREFIX/share/qemu/edk2-aarch64-code.fd -drive if=virtio,file=docker.qcow2,format=qcow2 -netdev user,id=net0,hostfwd=tcp::2222-:22 -device virtio-net-device,netdev=net0 -machine virt -accel kvm -cpu host"

pkg i qemu-system-aarch64-headless qemu-utils

mkdir qemu-docker
cd qemu-docker

# generate start script for starting the vm later
cat << EOF > start.sh
#!/bin/bash
echo Potential ips: 
sudo ip -o -4 addr show | grep 'wlan' | awk '{print $2, $4}' | sed 's#/.*##'
echo
echo Exit qemu by logging in and then running \"poweroff\" or via qemu: ctrl + a then x
sleep 5
sudo $QEMU_COMMAND
EOF
chmod +x start.sh

qemu-img create -f qcow2 docker.qcow2 10G

wget -O alpine.iso https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/aarch64/alpine-virt-3.21.3-aarch64.iso

sudo $QEMU_COMMAND -cdrom alpine.iso

# exiting vm: shutdown: poweroff, or via qemu: ctrl + a then x
# start vm from now on with the same command but without -cdrom

# login as root. root has no password
echo install with \"setup-alpine\". select a disk when prompted (default none) and installation method \"sys\"
echo install without swap partition. If forgotten it will be disabled later, but will waste disk space.
```

## set up the vm
Run these commands inside the vm
```bash
read -p "pubkey generated on tablet: " PUBKEY

# ssh
# ssh server has to be installed. i think this is default
mkdir -p ~/.ssh
echo $PUBKEY > ~/.ssh/authorized_keys 
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
sed -i '/^#\?AllowTcpForwarding/s/.*/AllowTcpForwarding yes/' /etc/ssh/sshd_config
rc-service sshd restart

# docker
sed -i '/community/s/^#//' /etc/apk/repositories
apk add docker
# docker allow network connections
mkdir -p /etc/docker
echo '{"hosts": ["unix:///var/run/docker.sock", "tcp://127.0.0.1:2375"]}' | tee /etc/docker/daemon.json > /dev/null
rc-service docker restart
# docker service activate
rc-service docker start
rc-update add docker default

# disable swap if enabled. We do not want that as it is slow and wears down the internal storage
sudo sed -i '/\bswap\b/d' /etc/fstab
# enable zram
apk add zram-init

mem_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
mem_mb=$((mem_kb / 1024))

cat <<EOF > /etc/conf.d/zram-init
load_on_start=yes
unload_on_stop=yes
num_devices=1
type0=swap
algo0=zstd
size0=${mem_mb}
EOF

rc-update add zram-init
rc-service zram-init start

cat <<EOF > /etc/sysctl.d/99-zram.conf
vm.page-cluster=0
vm.extfrag_threshold=0
vm.swappiness=100
EOF

# reboot system to apply all changes
reboot
```

## Run docker VM
After setup, if not shut down, the vm is already running. To start it after shutting it down, run 

```bash
qemu-docker/start.sh on termux
```

It should print the IPs of all wifi interfaces, one of them should be the IP you'll need later to connect to the docker daemon.


## connect to remote docker
The Docker network hodst does not provide authentication, therefore the connection is tunneld through ssh. The private key should already be in the correct location, it was generated above by the `ssh-keygen` command.

Run the below command to expose the docker daemon on localhost:2375 after inserting the correct IP.
```bash
ssh -NL 2375:localhost:2375 root@<vm-ip-or-host>:2222
```

Then execute 
```bash
export DOCKER_HOST=tcp://localhost:2375
```
in the terminal you want to execute docker commands in. Now it is possible to run docker commands, eg `docker ps`

## Access ports of docker containers
Docker services are only accessible in the vm. To access them from the Tablet they have to be forwarded simmilar tot the port 2375 forward. Alternatively it is possible to start a socks proxy with SSH (`ssh -D 8080 root@<vm-ip-or-host>:2222`)
