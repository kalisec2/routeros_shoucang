**各种云安装RouterOS脚本

---已经测试阿里云,腾讯云,Vxx,Bxx...等国内外知名VPS

wget http://download2.mikrotik.com/routeros/6.43.1/chr-6.43.1.img.zip -O chr.img.zip && \

gunzip -c chr.img.zip > chr.img && \

mount -o loop,offset=33554944 chr.img /mnt && \

ADDRESS0=`ip addr show eth0 | grep global | cut -d' ' -f 6 | head -n 1` && \

GATEWAY0=`ip route list | grep default | cut -d' ' -f 3` && \

echo "/ip address add address=$ADDRESS0 interface=[/interface ethernet find where name=ether1]

/ip route add gateway=$GATEWAY0

" > /mnt/rw/autorun.scr && \

umount /mnt && \

echo u > /proc/sysrq-trigger && \

dd if=chr.img bs=1024 of=/dev/vda && \

reboot

命令说明:

1、wget从ros官方下载CHR镜像到本地目录，并命名为chr.img.zip；建议wget下载。自己搭建http下载的地址，比如可以放到阿里云的oss下载路径。


http://lbros.oss-cn-hangzhou.aliyuncs.com

2、gunzip把chr.img.zip解压为chr.img


3、把chr.img镜像释放到/mnt目录下



4、抓取eth0的IP地址，并赋值参数为ADDRESS0



7、抓取ip route里的默认网关，并赋值参数为GATEWAY0



8、echo后面的为ros里的命令，ROS的内网网卡赋值内网IP，并设置默认网关，



并赋值给/mnt/rw/autorun.scr，这里可以干好多事情，大家自由发挥



9、umount /mnt,卸载已经加载的文件系统/mnt



10、echo u > /proc/sysrq-trigger 立即重新挂载所有的文件系统为只读



11、dd：用指定大小的块拷贝一个文件，并在拷贝的同时进行指定的转换。



if=文件名：输入文件名，缺省为标准输入。即指定源文件。



of=文件名：输出文件名，缺省为标准输出。即指定目的文件。



12、reboot重启机器


