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

WARNING: This will break the system package management for mesa. Expect issues when updating mesa packages through apt. To restore the original state, delete the copied files and restore the backup of freedreno_icd.json

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

