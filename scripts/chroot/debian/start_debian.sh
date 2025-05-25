#!/bin/bash

DEBIANPATH="/data/local/tmp/chrootDebian"

# Kill all old prcoesses
killall -9 termux-x11 Xwayland pulseaudio virgl_test_server_android termux-wake-lock

## Start Termux X11
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity

sudo bash -c "busybox mount --bind $PREFIX/tmp $DEBIANPATH/tmp"
sudo bash -c "busybox chroot $DEBIANPATH /bin/su - root -c 'chmod 777 /tmp'"  # tmp had invalid permissions after first setup. There is probably a easier way to solve this (without chrot), but i know this works.

XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :0 -ac &

sleep 3

# Start Pulse Audio of Termux
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1

# Start virgl server
#virgl_test_server_android &


sudo bash -c "
busybox mount -o remount,dev,suid /data

busybox mount --bind /dev $DEBIANPATH/dev
busybox mount --bind /sys $DEBIANPATH/sys
busybox mount --bind /proc $DEBIANPATH/proc
busybox mount -t devpts devpts $DEBIANPATH/dev/pts

mkdir -p $DEBIANPATH/dev/shm
busybox mount -t tmpfs -o size=256M tmpfs $DEBIANPATH/dev/shm

mkdir -p $DEBIANPATH/sdcard
busybox mount --bind /sdcard $DEBIANPATH/sdcard

busybox chroot $DEBIANPATH /bin/su - CHROOT_USERNAME -c 'export DISPLAY=:0 && export PULSE_SERVER=127.0.0.1 && dbus-launch --exit-with-session START_DESKTOP_CMD'
"
