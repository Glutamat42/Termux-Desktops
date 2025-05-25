# Zram on pipa

- Default configuration is 4GB zram. \
  `cat /proc/swaps` \
  No idea where it is configured

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