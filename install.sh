#!/bin/sh
set -e

# ==========================================
# GL-BE3600 专属：USB 3.0 存储挂载点配置
# ==========================================
USB_MOUNT_DIR="/tmp/mountd/disk1_part1"
INSTALL_DIR="${USB_MOUNT_DIR}/open-box"
LINK_DIR="/usr/share/open-box"
REQUIRED_SPACE_MB=512

echo "=========================================="
echo "    Open-Box (GL-BE3600 USB3.0) 安装脚本   "
echo "=========================================="

# 1. 检查是否为 OpenWrt / GL.iNet 系统
if [ ! -f "/etc/openwrt_release" ]; then
    echo "错误: 当前系统不是 OpenWrt/GL.iNet，终止安装。"
    exit 1
fi

# 2. 检查 USB 3.0 挂载点是否存在
echo "--> 检查 USB 存储挂载点..."
if [ ! -d "$USB_MOUNT_DIR" ]; then
    echo "错误: 未找到 USB 挂载路径 ${USB_MOUNT_DIR}！"
    echo "请确认 U 盘已成功插入并在 GL.iNet 后台识别。"
    exit 1
fi

# 3. 检查 U 盘剩余空间
echo "--> 检查 USB 存储剩余空间..."
AVAILABLE_SPACE_KB=$(df -k "$USB_MOUNT_DIR" | awk 'NR==2 {print $4}')
AVAILABLE_SPACE_MB=$((AVAILABLE_SPACE_KB / 1024))

echo "USB 挂载点 (${USB_MOUNT_DIR}) 剩余可用空间: ${AVAILABLE_SPACE_MB} MB"

if [ "$AVAILABLE_SPACE_MB" -lt "$REQUIRED_SPACE_MB" ]; then
    echo "错误: U 盘空间不足！Open-Box 需要至少 ${REQUIRED_SPACE_MB} MB 空间。"
    exit 1
fi

# 4. 创建 USB 安装目录与软链接
echo "--> 准备安装目录..."
mkdir -p "$INSTALL_DIR"

# 清理旧的系统路径，并绑定软链接到 U 盘
if [ -L "$LINK_DIR" ] || [ -d "$LINK_DIR" ]; then
    rm -rf "$LINK_DIR"
fi
ln -s "$INSTALL_DIR" "$LINK_DIR"
echo "已建立系统链接: $LINK_DIR -> $INSTALL_DIR"

# 5. 切换到 U 盘目录执行后续安装
cd "$INSTALL_DIR"
echo "--> 正在 U 盘目录 (${INSTALL_DIR}) 中执行安装步骤..."

# ==========================================
# (在此处拼接 Open-Box 原脚本的下载与启动逻辑)
# ==========================================

echo "=========================================="
echo "Open-Box 已成功安装到 U 盘 ($INSTALL_DIR)！"
echo "=========================================="
