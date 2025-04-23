#!/bin/bash

# 参数校验
if [ -z "$1" ]; then
    echo "用法: $0 <网络接口名称>，例如 eth0 或 ens18"
    exit 1
fi

NIC="$1"

# 多个下载源
URL1="https://download.mikrotik.com/routeros/7.16.1/chr-7.16.1.img.zip"
URL2="https://cdn1.mikrotik.com/chr/7.16.1/chr-7.16.1.img.zip"
URL3="https://mirror.example.com/routeros/7.16.1/chr-7.16.1.img.zip"

echo "请选择要使用的 CHR 镜像下载链接："
echo "1) 官方主站: $URL1"
echo "2) CDN 镜像: $URL2"
echo "3) 自定义镜像: $URL3"
read -p "请输入序号 (默认 1): " CHOICE

case "$CHOICE" in
    2) IMG_URL="$URL2" ;;
    3) IMG_URL="$URL3" ;;
    *) IMG_URL="$URL1" ;;
esac

IMG_ZIP="chr.img.zip"
IMG="chr.img"

# 自动判断挂载偏移量
if [[ "$NIC" == "eth0" ]]; then
    OFFSET=512
else
    OFFSET=33554944
fi

# 下载并解压
wget "$IMG_URL" -O "$IMG_ZIP" || { echo "下载失败"; exit 1; }
gunzip -c "$IMG_ZIP" > "$IMG" || { echo "解压失败"; exit 1; }

# 选择目标磁盘
echo "检测到以下可用磁盘（不包括分区）:"
DISKS=$(lsblk -nd -e 7,11 -o NAME,SIZE | grep -v "loop" | awk '{print $1}')
i=1
declare -A DISK_MAP
for disk in $DISKS; do
    SIZE=$(lsblk -nd -o SIZE /dev/$disk)
    echo "$i) /dev/$disk ($SIZE)"
    DISK_MAP[$i]="/dev/$disk"
    ((i++))
done

read -p "请输入要写入的磁盘编号，例如 1: " DNUM
TARGET_DISK="${DISK_MAP[$DNUM]}"

if [ -z "$TARGET_DISK" ]; then
    echo "无效选择，退出"
    exit 1
fi

echo "你选择的目标磁盘是：$TARGET_DISK"
read -p "确认要擦写这个磁盘吗？这将清空所有数据！(yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "已取消操作"
    exit 0
fi

# 挂载镜像
mount -o loop,offset=$OFFSET "$IMG" /mnt || { echo "挂载失败"; exit 1; }

# 获取网络信息
ADDRESS=$(ip addr show "$NIC" | grep global | cut -d ' ' -f 6 | head -n 1)
GATEWAY=$(ip route list | grep default | cut -d ' ' -f 3)

if [[ -z "$ADDRESS" || -z "$GATEWAY" ]]; then
    echo "获取网络信息失败"
    umount /mnt
    exit 1
fi

# 写入 autorun.scr
mkdir -p /mnt/rw
cat > /mnt/rw/autorun.scr <<EOF
/ip address add address=$ADDRESS interface=[/interface ethernet find where name=ether1]
/ip route add gateway=$GATEWAY
/ip service disable telnet
/user set 0 name=root password=YourStrongPasswordHere
EOF

umount /mnt

# 写入磁盘
echo "开始写入镜像到 $TARGET_DISK..."
echo u > /proc/sysrq-trigger
dd if="$IMG" bs=1024 of="$TARGET_DISK" status=progress || { echo "写入失败"; exit 1; }

# 同步与重启
echo "同步磁盘"
echo s > /proc/sysrq-trigger
echo "等待 5 秒..."
sleep 5
echo "准备重启..."
echo b > /proc/sysrq-trigger
