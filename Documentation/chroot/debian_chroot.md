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
pkg install x11-repo root-repo termux-x11-nightly
pkg update
pkg install pulseaudio
```


---  
<br>

## 💻🍥 Setting Debian chroot - automatic installer <a name=debian-chroot></a>

Please read first [#First Steps section](#first-steps-chroot)

> [!NOTE]
> This script uses a rootfs file prebuilt by me as Debian does not provide an appropriate file. See [Build own rootfs section](#build-own-rootfs) if you prefer to build it by yourself.

* Download the installer with this command: 
```
wget https://raw.githubusercontent.com/Glutamat42/Termux-Desktops/main/scripts/chroot/debian/chroot_debian_installer.sh
```

* Run it with sudo privileges from Termux: 
```
su
```
```
chmod +x chroot_debian_installer.sh
sh chroot_debian_installer.sh
```

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



## 🎨 Customizations (Nerdfonts, XFCE4 terminal color palettes, etc) <a name=customizations-chroot></a>
* XFCE4 color palettes:
  * [Dracula](https://draculatheme.com/xfce4-terminal)
  * [Nordic](https://github.com/nordtheme/xfce-terminal)     

* Installing NerdFonts on chroot env (Debian, Ubuntu) from this [post](https://medium.com/@almatins/install-nerdfont-or-any-fonts-using-the-command-line-in-debian-or-other-linux-f3067918a88c):
```
sudo apt install wget unzip -y
```
```
wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip \
&& cd ~/.local/share/fonts \
&& unzip JetBrainsMono.zip \
&& rm JetBrainsMono.zip \
&& fc-cache -fv
```

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

