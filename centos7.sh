wget https://download.mikrotik.com/routeros/7.16.1/chr-7.16.1.img.zip -O chr.img.zip && \
gunzip -c chr.img.zip > chr.img && \
mount -o loop,offset=512 chr.img /mnt && \
ADDR0=`ip addr show eth0 | grep global | cut -d' ' -f 6 | head -n 1` && \
GATE0=`ip route list | grep default | cut -d' ' -f 3` && \
mkdir -p /mnt/rw && \
echo "/ip address add address=$ADDR0 interface=[/interface ethernet find where name=ether1]
/ip route add gateway=$GATE0
" > /mnt/rw/autorun.scr && \
umount /mnt && \
echo u > /proc/sysrq-trigger && \
dd if=chr.img bs=1024 of=/dev/vda && reboot
