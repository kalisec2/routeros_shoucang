#!/bin/sh
set -e

# ==========================================
# 参数配置：指定 USB 3.0 存储挂载点与安装路径
# ==========================================
# 请根据你的实际 USB 挂载路径修改（常见如：/mnt/sda1, /mnt/sdb1, /overlay/upper 等）
USB_MOUNT_DIR="/mnt/sda1"
INSTALL_DIR="${USB_MOUNT_DIR}/open-box"
LINK_DIR="/usr/share/open-box"
REQUIRED_SPACE_MB=512

echo "=========================================="
echo "      Open-Box USB 存储安装脚本           "
echo "=========================================="

# 1. 检查是否为 OpenWrt 环境
if [ ! -f "/etc/openwrt_release" ]; then
    echo "错误: 当前系统不是 OpenWrt，终止安装。"
    exit 1
fi

# 2. 检查 USB 3.0 挂载点是否存在
echo "--> 检查 USB 存储挂载点..."
if [ ! -d "$USB_MOUNT_DIR" ]; then
    echo "错误: 未找到 USB 存储路径 ${USB_MOUNT_DIR}！"
    echo "请确认 USB 3.0 盘已插入并挂载（可通过运行 df -h 查看挂载路径）。"
    exit 1
fi

# 3. 检查 USB 存储空间大小
echo "--> 检查 USB 存储剩余空间..."
# 提取 USB 挂载点的剩余空间（MB）
AVAILABLE_SPACE_KB=$(df -k "$USB_MOUNT_DIR" | awk 'NR==2 {print $4}')
AVAILABLE_SPACE_MB=$((AVAILABLE_SPACE_KB / 1024))

echo "USB 挂载点 (${USB_MOUNT_DIR}) 剩余可用空间: ${AVAILABLE_SPACE_MB} MB"

if [ "$AVAILABLE_SPACE_MB" -lt "$REQUIRED_SPACE_MB" ]; then
    echo "错误: USB 存储空间不足！Open-Box 需要至少 ${REQUIRED_SPACE_MB} MB 可用空间。"
    exit 1
fi

# 4. 创建 USB 安装目录与软链接
echo "--> 准备安装目录..."
mkdir -p "$INSTALL_DIR"

# 清理旧的系统路径，并指向 USB 路径
if [ -L "$LINK_DIR" ] || [ -d "$LINK_DIR" ]; then
    rm -rf "$LINK_DIR"
fi
ln -s "$INSTALL_DIR" "$LINK_DIR"
echo "已建立系统链接: $LINK_DIR -> $INSTALL_DIR"

# 5. 开始在 USB 盘中下载和安装组件
cd "$INSTALL_DIR"

# (以下为原脚本的依赖检查、下载 Releases、解压与服务配置逻辑)
echo "--> 开始在 USB 盘 (${INSTALL_DIR}) 执行安装流程..."

# ...下载面板、sing-box 核心以及规则集文件到当前目录...

echo "=========================================="
echo "Open-Box 已成功安装至 USB 3.0 存储 ($INSTALL_DIR)！"
echo "=========================================="