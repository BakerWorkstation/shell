#!/bin/bash

# 清屏操作
clear

#               从本机取出IP地址                  #
#		这个IP地址作为DNS服务器地址	  #
#		这个IP地址作为tftp服务器地址	  #
#		这个IP地址作为dhcp服务器地址	  #
#		这个IP地址作为ftp服务器地址	  #
a=`awk -F"=" '/IPADDR/{print $2}' /etc/sysconfig/network-scripts/ifcfg-eth0 `


#  把IP地址划分为几个段，供配置DNS服务器时方便使用#    
b=`echo $a | awk -F"." '{print $2"."$1}' `
c=`echo $a | awk -F"." '{print $1"."$2}' `
d=`echo $a | awk -F"." '{print $1"."$2"."$3}' `
e=`echo $a | awk -F"." '{print $4}' `


#--------------------------------------------------#
# 	      安装dhcp服务所需的安装包		   #	
#--------------------------------------------------#

rpm -q dhcp &> /dev/null

if [ $? -eq 1 ]
then
	yum install dhcp -y  &> /dev/null  
fi

#------------------------------------------------#
#  	        修改dhcp的主配置文件              #
#------------------------------------------------#

cat << FIN > /etc/dhcp/dhcpd.conf
ddns-update-style interim;
option domain-name-servers $a;
subnet 172.16.0.0 netmask 255.255.0.0{
range 172.16.6.20 172.16.6.40;
next-server $a;
filename "pxelinux.0";
}
FIN

/etc/init.d/dhcpd start &> /dev/null


#--------------------------------------------------#
# 	      安装dns服务所需的安装包		   #	
#--------------------------------------------------#

rpm -q bind &> /dev/null && rpm -q bind-chroot &> /dev/null

if [ $? -eq 1 ]
then
	yum install bind bind-chroot -y  &> /dev/null
fi


/etc/init.d/named start &> /dev/null


#------------------------------------------------#
#  	        修改DNS的主配置文件              #
#------------------------------------------------#

cat << FIN > /var/named/chroot/etc/named.conf
options{
directory "/var/named";
};

zone "up.com"{
type master;
file "up.com.zone";
};

zone "$b.in-addr.arpa"{
type master;
file "$c.rev";
};
FIN


cd /var/named/chroot/var/named/
cp -p named.localhost up.com.zone
cp -p named.loopback $c.rev


#--------------------------------------------------#
# 	         修改正向解析配置文件              #
#--------------------------------------------------#

sed -ri '/^[[:space:]]+NS/s#@#dns.up.com.#' up.com.zone 
sed -i '$d' up.com.zone
sed -ri '/^[[:space:]]+A/s#^#dns#' up.com.zone
sed -ri '/^dns/s#[0-Z.]+$#'$a'#' up.com.zone
sed -i '$a $GENERATE 20-40 stu$ A '$d'.$' up.com.zone



#---------------------------------------------------#
#                修改反向解析配置文件               #
#---------------------------------------------------#

sed -ri '/^[[:space:]]+NS/s#@#dns.up.com.#' $c.rev 
sed -i '$d' $c.rev 
sed -i '$d' $c.rev 
sed -ri '/^[[:space:]]+A/s#^#dns#' $c.rev 
sed -ri '/^dns/s#[0-Z.]+$#'$a'#' $c.rev 
sed -i '$a $GENERATE 20-40 $.'$e' PTR stu$.up.com.' $c.rev 

/etc/init.d/named restart  &> /dev/null


#---------------------------------------------------#
# 	如果DNS服务启动失败，返回值为5              #
#---------------------------------------------------#
if [ $? -eq 1 ]
then
	exit 5;
fi

#---------------------------------------------------#
#	安装ftp服务器软件包
#---------------------------------------------------#

rpm -q vsftpd &> /dev/null
if [ $? -eq 1 ]
then
	yum install vsftpd -y &> /dev/null
fi

mkdir /var/ftp/iso/
mount /dev/cdrom /var/ftp/iso &> /dev/null

/etc/init.d/vsftpd start &> /dev/null
chkconfig vsftpd on

#----------------------------------------------------#
#		安装tftp服务器软件包		     #
#----------------------------------------------------#

rpm -q tftp-server &> /dev/null 

if [ $? -eq 1 ]
then 
	yum install tftp-server -y &> /dev/null
fi
chkconfig tftp on
/etc/init.d/xinetd restart  &> /dev/null
chkconfig xinetd on

#安装bootloader配置文件:pxelinux.0

yum install syslinux -y &> /dev/null

# 把bootloader拷贝到tftp服务器
cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/


#把内核和驱动拷贝到tftp服务器
cd /var/ftp/iso/isolinux/
mkdir /var/lib/tftpboot/pxelinux.cfg/
cp isolinux.cfg /var/lib/tftpboot/pxelinux.cfg/default
cp initrd.img vmlinuz vesamenu.c32 /var/lib/tftpboot/


#--------------------------------------------------#
#		修改tftp到default文件              #
#--------------------------------------------------#

cat <<  EOF >> /var/lib/tftpboot/pxelinux.cfg/default
label ks6464
menu label ^A rhel6464
kernel vmlinuz
append initrd=initrd.img
EOF

#--------------------------------------------------#
#						   #
#--------------------------------------------------#

 clear
 echo "开启无人执守模式"
 echo ""
 echo -n "Servers are going to running   " 
 
  i=1;
 while [ $i -le 15 ]
 do
 
         sleep 0.3;
         echo -en "\e[31m.\e[m "
         let i++
 done
 
 
 
 x=00
 y=00
 z=00
 
 
 while :
 do
  clear
 echo -n "Servers are running   " 
 i=1;
 
          while  [ $i -le 15 ]
          do
                 echo -en "\e[31m.\e[m "
         let i++;
         done
 
 # 31 红色    31-36图案颜色
 # 32 绿色
 
         echo -e "\t\t[ \e[32mOK\e[m ]"
 
 # 增加7个空行
 echo -e "\n\n\n\n\n\n\n"
 #在屏幕上输出运行时间
 echo -n -e "\t\t    服务运行时间："$z时$y分$x秒
         sleep 1
        let x++;
                if [ $x -eq 60 ]
                then
                let x=0
                let y++;
                fi
 
                if [ $y -eq 60 ]
                then
                let y=0
                let z++;
                fi
done
