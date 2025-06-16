> [!CAUTION]
> READ CAREFULLY! When using Chroot environments to exit completely close the Termux application even from the background apps or if necessary force close it. Otherwise, in case you do some command like "rm -rf chrootFolder" the device will go crazy and you will have to force reboot it.

# 📚 Index

## CHROOT (🍥 DEBIAN)
* 🏁 [First steps](#first-steps-chroot)
* 💻🍥 [Setting Debian chroot - automatic installer](#debian-chroot)
* 🎨 [Customizations (Nerdfonts, XFCE4 terminal color palettes, etc)](#customizations-chroot)
* [Uninstall](#uninstall)

<br>

---  
---  

<br>

> [!NOTE]  
> All the process is described in this [video](https://www.youtube.com/watch?v=EDjKBme0DRI)

## 🏁 First steps <a name=first-steps-chroot></a>


1. First you need to have your device <u>rooted</u>.
2. Enable "Beschränkung für Unterprozesse deaktivieren" in developer settings
3. You need to flash [Busybox](https://github.com/Magisk-Modules-Alt-Repo/BuiltIn-BusyBox/releases) with Magisk.
4. Then you need to install the following packages in Termux: 

```
pkg update
pkg install x11-repo root-repo 
pkg i termux-x11-nightly
pkg update
pkg install pulseaudio sudo wget
```


---  
<br>

## 💻🍥 Setting up Debian chroot - automatic installer <a name=debian-chroot></a>

Please read first [#First Steps section](#first-steps-chroot)

> [!NOTE]
> This script uses a rootfs file prebuilt by me as Debian does not provide an appropriate file. See [Build own rootfs section](#build-own-rootfs) if you prefer to build it by yourself.

* Download the installer with this command: 
```
wget https://raw.githubusercontent.com/Glutamat42/Termux-Desktops/main/scripts/chroot/debian/chroot_debian_installer.sh
```

* Run it with sudo privileges from Termux: 
```
su -c "/bin/sh ./chroot_debian_installer.sh"
```

### Partially unattended setup
It is possible to further automate the setup through environment variables. Usage of all variables is optional.
As of now this will not, depending on the desktop environment you choose, fully automate the installation script.

| Variable | Description |
|----------|-------------|
|CHROOT_NAME|Set if installing multitple chroots using this script. Will be used everywhere where names have to be unique.|
|ROOTFS_DOWNLOAD_URL|Set a custom URL for the rootfs archive|
|CHROOT_USER_NAME|Name of your user in the chroot instance|
|CHROOT_USER_PASSWORD|Passwowrt of your user in the chroot instance|

Usage example: `su -c "CHROOT_USER_NAME=mario CHROOT_USER_PASSWORD=secret /bin/sh ./chroot_debian_installer.sh"`

---  
<br>

## Build own rootfs <a name=build-own-rootfs></a>
My rootfs is available in the release section of this GitHub Project. It also contains the commands I used to create it.
Theoretically it would be possible to run debootstrap directly in the setup script, but it turned out to be unreliable for me. 
I could build Debian bookworm, but not trixie. 

This is how i did build my rootfs archive:
1) Set up Debian trixie VM
2) run these commands:
```bash
sudo apt-get update && sudo apt-get install debootstrap qemu-user-static

sudo debootstrap --arch=arm64 bookworm debian-trixie-arm64 http://deb.debian.org/debian/

cd debian-trixie-arm64/
sudo tar -cv * | xz -9 > debian-trixie-arm64.tar.xz
```

To use your archive instead of mine create the chroot folder manually (`/data/local/tmp/chrootDebian$CHROOT_NAME`) and place the archive directly inside it.
The rootfs archive name has to match `$DOWNLOAD_FILE_NAME` exactly. The script will then skip the download. The archive will be deleted after chroot setup.

Alternatively define `ROOTFS_DOWNLOAD_URL` to contain the full url to your rootfs file before executing the installer script.

## Run AppImages
/dev/fuse is owned by root:root. Run AppImages with sudo.

## 🎨 Further Customizations<a name=customizations-chroot></a>

### Getting rid of the Android bottom bar (gesture bar)
Android shows a pretty useless bar on the bottom called gesture bar. It literally does nothing except being in the way. Trying to click on something at the bottom of the chroot Desktop ... That annoying bar gets in the way. And there is no way to deactivate it in the official settings...

Solution is this Magisk module. Install it and during its setup hide the bottom gesture bar: `https://github.com/DanGLES3/Hide-Navbar`

---  
<br>

## Uninstall <a name=uninstall></a>
To uninstall you have to remove:
1) `/data/local/tmp/<chroot folder>`
2) `/data/local/tmp/<start script>`
3) `/data/data/com.termux/files/usr/bin/<start file>`

The name of the scripts/folders in <> might vary between installs. You can start with file 3. 
`<start file>` equals the command you run to start the chroot. 
View the filecontent before deleting it, it will reveal the name of file 2.
Do the same with file 2. The Variable `DEBIANPATH` contains the path for folder 1.

> [!CAUTION]
> Before deleting "1" first completely exit Termux. 
> Close the terminal through notification and then force close Termux.
> Otherwise you will scew up Android and will have to force reboot your device to make it work again.

## Issues
### ttermux x11 Cannot establish any listening sockets - Make sure an X server isn't already running(EE)

```bash
rm -rf $TMPDIR/*
rm -rf $TMPDIR/.*
```

## XKB: Failed to compile keymap Keyboard initialization failed

This is a known issue in xkeyboard-config version 2.45. Downgrade to version 2.44. You need to get the package from a 3rd party source. This discussions contains such a link (WARNING: random internet source): [Reddit discussion](https://www.reddit.com/r/termux/comments/1l6upzx/termuxx11_error_after_upgrading_to_01190beta3/)