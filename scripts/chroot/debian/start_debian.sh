#!/bin/sh

# REPLACEME strings will be replaced by installer script automatically
DEBIANPATH=REPLACEME_DEBIANPATH
START_DESKTOP_CMD=REPLACEME_START_DESKTOP_CMD
CHROOT_USERNAME=REPLACEME_CHROOT_USERNAME

busybox mount -o remount,dev,suid /data

busybox mount --bind /dev $DEBIANPATH/dev
busybox mount --bind /sys $DEBIANPATH/sys
busybox mount --bind /proc $DEBIANPATH/proc
busybox mount -t devpts devpts $DEBIANPATH/dev/pts

mkdir -p $DEBIANPATH/dev/shm
busybox mount -t tmpfs -o size=256M tmpfs $DEBIANPATH/dev/shm

mkdir -p $DEBIANPATH/sdcard
busybox mount --bind /sdcard $DEBIANPATH/sdcard

# Check if we're starting bash only or a desktop environment
if [ "$START_DESKTOP_CMD" = "bash" ]; then
    # For bash only, start a simple bash session
    busybox chroot $DEBIANPATH /bin/su - $CHROOT_USERNAME
else
    # For desktop environments, use dbus-launch with display
    busybox chroot $DEBIANPATH /bin/su - $CHROOT_USERNAME -c "export DISPLAY=:0 && export PULSE_SERVER=127.0.0.1 && dbus-launch --exit-with-session $START_DESKTOP_CMD"
fi
