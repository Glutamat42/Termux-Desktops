# Graphics Hardware Acceleration and x86/x86_64 emulation

## Graphics driver

Mesa has a driver for Adreno GPUs called Turnip. But there are still some patches required to make it work at least in this scenario (i am aware of dri3 patches, maybe others too). Therefore, it is not possible to use the system packages for full performance.

It is also not possible to use the drivers used for emulators and Winlator as they are built with Androids Bionic c library and therefore not compatible with this glibc based chroot. A bionic based chroot would make the driver situation better, but will cause issues with most Linux software.

## Setup
### Preparations
I did try out a lot before getting it to work. I do not know if some of these steps were rerquired to make it work. These are some of the things i did:

- `sudo apt install libvulkan1 vulkan-tools mesa-vulkan-drivers mesa-utils libgl1-mesa-dri libegl1 libgles2 libgbm1 libdrm2 libxcb-dri3-0 libxshmfence1 libx11-xcb1`
- added user to groups aid_graphics video render

### Install patched mesa driver
I am not aware of many patched drivers and all i found were not built for Debian 13, but it is still possible to make them work.

> [!WARNING]
> This will break the system package management for mesa. Expect issues when updating mesa packages through apt. To restore the original state, delete the copied files and restore the backup of freedreno_icd.json

1) Downloaded this package: https://www.reddit.com/r/termux/comments/19dpqas/proot_linux_only_dri3_patch_mesa_turnip_driver/
2) Extracted the deb package: `dpkg-deb -R mesa-vulkan-kgsl_24.1.0-devel-20240120_arm64.deb .`
3) manually install it
- `sudo cp /usr/share/vulkan/icd.d/freedreno_icd.json /usr/share/vulkan/icd.d/freedreno_icd.json.bak`
- `sudo cp usr/share/vulkan/icd.d/freedreno_icd.aarch64.json /usr/share/vulkan/icd.d/freedreno_icd.json`
- `sudo cp usr/lib/aarch64-linux-gnu/libvulkan_freedreno.so /usr/lib/aarch64-linux-gnu/`
- `sudo cp usr/lib/aarch64-linux-gnu/liblua.so* /usr/lib/aarch64-linux-gnu/`
4) Test it by running: `MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform glmark2` \
It should show
```
    OpenGL Information
    GL_VENDOR:      Mesa
    GL_RENDERER:    zink Vulkan 1.3(Turnip Adreno (TM) 650 (MESA_TURNIP))
    GL_VERSION:     4.6 (Compatibility Profile) Mesa 25.0.7-2
```
5) UNTESTED: If it works, you can make it permanent by adding the following lines to `~/.bashrc` or `/etc/profile`:
```bash
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
```

## x86/x86_64 emulation
> [!IMPORTANT]
> This will and cannot work properly on the Xiaomi Pad 6 because the kernel does not support `binfmt`. Without this it is still possible to run x86 apps, but as soon as this application calls another x86 application (indirerctly through an arm application) it will fail (eg steam). I did not find a kernel with binfmt support.

To execute x86 applications box64 is used. It is getting i386 integration too, so it is not requireed anymore to install box86 seperately.

Building will follow the [COMPILE.md](https://github.com/ptitSeb/box64/blob/main/docs/COMPILE.md) of box64. It is a good read especially when trying to continue from here on with a kernel supporting binfmt.

To download, build and install run the following. I did it without `-DBAD_SIGNAL=ON`, but according to the docs it is recommended in this usecase.
```
git clone https://github.com/ptitSeb/box64
cd box64
mkdir build; cd build; cmake .. -D ARM_DYNAREC=ON -D CMAKE_BUILD_TYPE=RelWithDebInfo -D BOX32=ON -D BOX32_BINFMT=ON -D SD845=1 -DBAD_SIGNAL=ON
make -j4  
sudo make install
```

Now it is possible to run x86 applications by prefixing the command with `box64`. For example `box64 glxinfo`.

Combined with wine it is possible to run x86 windows applications as well.

Using [hangover](https://github.com/AndreRH/hangover) might simplify a lot of the subsequent setup to run windows applications/games.

I did not continue here as without `binfmt` I cannot practically use it without doing things like x86 chroot or wine prefix.

## Outlook
To continue from here on and actually run x86 applications like games i see the following options:

### Custom kernel with binfmt support
I did only find one kernel that worked for me with pixelos, but it did not provide binfmt support. I will document it here as the process should be the same for other kernels.

1) Download [kernel flasher](https://github.com/fatalcoder524/KernelFlasher)
2) Download kernel [GitHub](https://github.com/Matrixx-Devices/android_kernel_xiaomi_pipa/releases/tag/v1.5) [xda](https://xdaforums.com/t/bloodreaper-kernel-v4-19-332-aosp-miui-hos-sukisu-ultra-xiaomi-pad-6.4737156/)
3) Flash it with the flasher app (Flash AK3 Zip)
4) Reboot to the new kernel

Aside from the kernel above I tried the magictime kernel as it was recommended in a xda thread of the above kernel. Getting information for it is pretty hard. Kernel and all documentation is only available in a telegram group with mostly russian chats and a documentation that can only be accessed by spamming in the chat. I tried multiple recent kernels but got none working. There is also a vendor_boot specifically for "pixel experience" but flashing it made my tablet not boot anymore.

#### Recovery
If bootlooping or having other boot issues you can recover as follows:
1) Boot to pixelos recovery (Power + volume up)
2) Active sideload (maybe you have to press the back button top left or press on advanced)
3) Flash boot, vendor_boot and dtbo (`fastboot flash boot boot.img`, ...) from pixelos.net
4) If Magisk was used, flash it again as described in the [Documentation](https://blog.pixelos.net/docs/guides/HowToRoot)
5) Reboot

If recovery is broken too
1) Boot to fastboot (Power + volume down)
2) Fastboot flashing as above is now possible. On Windows i had the issue that the device did not show up in `fastboot devices`. Reason was a driver issue. I did update drivers to the latest one from google but still not detected. Issue was Windows is using a wrong driver. Open device manager, finde "Android" device with a warning sign. Update driver, select manually and select "Android Bootloader Interface". After that it should show up in fastboot.
3) For Magisk boot into recovery (now working again) and continue as described above.

### x86 chroot
The idea is to run the whole chroot with box64. Not sure if this is actually possible and how to do it. I did not explore this path. Chatty once told me it should be possible.

### x86 wine
The idea here is to run only wine with box64. Chroot stays on arm. This is working and as i understand it the approach used by [winlator](https://github.com/brunodev85/winlator) and [box64droid](https://github.com/Ilya114/Box64Droid). Everyting run in wine will likely be x86 anyways so this approach is fine and worth to follow. I did manage to get steam to fully start with this approach, but then did not continue following it. Have a look on [hangover](https://github.com/AndreRH/hangover) when following this path.

It might also be interesting to set up a bionic c library based chroot for this usecase. This should allow to use all the emulator/winlator drivers for gpu acceleration. As this chroot would only run wine, the compatibility issues with bionic should be minimal.

### PostmarketOS
[PostmarketOS pipa wiki](https://wiki.postmarketos.org/wiki/Xiaomi_Pad_6_(xiaomi-pipa))

This follows a different approach as this whole project. Instead of setting up a Linux chroot on Android it is a Linux system with the ability to run Android apps. No idea how well it works as I was not yet able to get it running. There was some initial work done to get Post markets running on pipa but the efforts seem to have been abandoned. The code from the unmerged pull request (see wiki) does not work anymore. I did port some recent changes to the pr (not puplic) and did get a successfull build without systemd but it still fails with systemd. Also did not yet flash it.

This approach might solve some issues the Android based approach has, most notably:
- Kernel may support binfmt
- Kernel may support zstd for zram
- Better memory management (how Android manages memory is not beneficial for chroot. It always has a high memory usage which is not bad by itself as unused memory is wasted memory. Also for some reasons android did rarely use more than 4GB zram when increasing the size to 8GB)
- Chroot not being terminated because android closes termux (happens rarely but very annoying and happens more often when using memory hungy applications)
