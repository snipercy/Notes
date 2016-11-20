# 网络
无线：wifi-menu 
pacman -S wpa_supplicant dialog



# swap 分区

> Swap partitions are typically designated as type 82. Even though it is possible to 
use any partition type as swap, it is recommended to use type 82 in most cases since 
systemd will automatically detect it and mount it (see below).

设置/创建swap分区会用到的一些命令：

```lsblk```: 列出所有块(block)信息

```swapon --show``` 或 `free -h` : 查看 swap 分区

##  利用 fdisk 创建/设置swap分区：

### 对sda进行分区
```
fdisk /dev/sda
```

### 列出 sda 下已经建立的分区
```
Command (m for help): p
```

### 删除已有分区
```
Command (m for help): d
Partition number (1-4): 1
```

### 新建 swap 分区：分区大小一般设置为 内存大小 * 125%
```
Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
   Partition number (1-4):1
   First cylinder (0-1060, default 0):0
   Last cylinder or +size or +sizeM or +sizeK (0-1060, default 1060):+64M

设置为swap分区
Command (m for help): t
选择swap分区
输入82 (type)
```

### 新建主分区 : 与 建立 swap 分区类似

最后，键入'w'保存设置并推出 fdisk

### 格式化分区：
```
mkfs.ext4 /dev/sda2
```

注意：也可以通过创建swap文件来达到同样的效果
具体操作可以参考 [archWiki](https://wiki.archlinux.org/index.php/Swap)

