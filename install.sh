#!/bin/sh
set -e

# ==========================================
# 安装配置：直接安装至 GL.iNet 内置存储
# ==========================================
INSTALL_DIR="/usr/share/open-box"
REQUIRED_SPACE_MB=50  # 可根据实际核心大小调整门槛（你的设备剩余 185MB，完全足够）

echo "=========================================="
echo "   Open-Box (GL.iNet 本地存储免内存检测版)  "
echo "=========================================="

# 1. 检查是否为 OpenWrt / GL.iNet 环境
if [ ! -f "/etc/openwrt_release" ]; then
    echo "错误: 当前系统不是 OpenWrt/GL.iNet，终止安装。"
    exit 1
fi

# 2. 检测系统内置 overlay 存储空间
echo "--> 检查系统内置存储空间..."
# 提取 /overlay 挂载点的可用空间(KB)
if df -k /overlay >/dev/null 2>&1; then
    AVAILABLE_SPACE_KB=$(df -k /overlay | awk 'NR==2 {print $4}')
else
    AVAILABLE_SPACE_KB=$(df -k / | awk 'NR==2 {print $4}')
fi

AVAILABLE_SPACE_MB=$((AVAILABLE_SPACE_KB / 1024))
echo "内置存储剩余可用空间: ${AVAILABLE_SPACE_MB} MB"

if [ "$AVAILABLE_SPACE_MB" -lt "$REQUIRED_SPACE_MB" ]; then
    echo "错误: 系统内置存储空间不足！需要至少 ${REQUIRED_SPACE_MB} MB 空间。"
    exit 1
fi

# ==========================================
# [已注销/删除 内存 (RAM) 检测]
# 不再检查 free -m 或 /proc/meminfo
# ==========================================

# 3. 创建本地安装目录
echo "--> 准备安装路径 (${INSTALL_DIR})..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo "--> 开始在 GL.iNet 内置存储中下载并配置 Open-Box..."

# ==========================================
# (在此处接 Open-Box 官方脚本原本的下载与配置逻辑)
# ==========================================

echo "=========================================="
echo " Open-Box 已成功安装至 GL.iNet 内置存储！"
echo "=========================================="
