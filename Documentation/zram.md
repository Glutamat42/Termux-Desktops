# Zram on pipa

- Default configuration is 4GB zram. \
  `cat /proc/swaps` \
  Configured in `/vendor/bin/init.qcom.post_boot.sh`, but cant be changed there

- Supported compression algorithms: lzo \
  `cat /sys/block/zram0/comp_algorithm` \
  I dont think it is possible to add support for zstd without a custom kernel. There are some kernels available on xda, but the community isn't big. No idea if there are any with zstd support.

- It is **not** possible to add additional zram devices during runtime via `/sys/class/zram-control/hot_add` (permission denied)

## resize zram
It is possible to resize zram during runtime, but the `swapoff` command can take a long time if zram is full.

```bash
swapoff /dev/block/zram0
zramctl --reset /dev/block/zram0
echo 8192M > /sys/block/zram0/disksize
mkswap /dev/block/zram0
swapon /dev/block/zram0
```

## Automate zram resize with Magisk
Create a magisk service with the following command in Termux as root: 
```bash
cat <<EOF > /data/adb/service.d/0010zram_resize
swapoff /dev/block/zram0
zramctl --reset /dev/block/zram0
echo 8G > /sys/block/zram0/disksize
# echo 1 > /sys/block/zram0/use_dedup  # not supported on current kernel
# echo zstd > /sys/block/zram0/comp_algorithm  # not supported on current kernel
mkswap /dev/block/zram0
swapon /dev/block/zram0 -p 32758
EOF
chmod 755 /data/adb/service.d/0010zram_resize
```