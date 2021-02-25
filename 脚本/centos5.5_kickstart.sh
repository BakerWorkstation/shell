#!/bin/bash
a=`awk -F"=" '/IPADDR/{print $2}' /etc/sysconfig/network-scripts/ifcfg-eth0 `
b=`echo $a | awk -F"." '{print $2"."$1}' `
c=`echo $a | awk -F"." '{print $1"."$2}' `
d=`echo $a | awk -F"." '{print $1"."$2"."$3}' `
e=`echo $a | awk -F"." '{print $4}' `
rpm -q dhcp &> /dev/null
if [ $? -eq 1 ]
then
        yum install dhcp -y  &> /dev/null
fi
#------------------------------------------------#
#               ÐÞ¸ÄdhcpµÄÖ÷ÅäÖÃÎÄ¼þ              #
#------------------------------------------------#

cat << FIN > /etc/dhcpd.conf
ddns-update-style interim;
option domain-name-servers $a;
subnet 172.16.0.0 netmask 255.255.0.0{
range 172.16.6.20 172.16.6.40;
next-server $a;
filename "pxelinux.0";
}
FIN

/etc/init.d/dhcpd start &> /dev/null
chkconfig dhcpd on


#--------------------------------------------------#
#             °²×°dns·þÎñËùÐèµÄ°²×°°ü              #    
#--------------------------------------------------#

#---------------------------------------------------#
#       °²×°ftp·þÎñÆ÷Èí¼þ°ü
#---------------------------------------------------#

rpm -q vsftpd &> /dev/null
if [ $? -eq 1 ]
then
        yum install vsftpd -y &> /dev/null
fi

mkdir /var/ftp/iso/
mount /dev/cdrom /var/ftp/iso &> /dev/null
echo "mount /dev/cdrom /var/ftp/iso &> /dev/null" >> /etc/rc.local

/etc/init.d/vsftpd start &> /dev/null
chkconfig vsftpd on
#----------------------------------------------------#
#               °²×°tftp·þÎñÆ÷Èí¼þ°ü                 #
#----------------------------------------------------#

rpm -q tftp-server &> /dev/null

if [ $? -eq 1 ]
then
        yum install tftp-server -y &> /dev/null
fi
chkconfig tftp on
/etc/init.d/xinetd restart  &> /dev/null
chkconfig xinetd on

#°²×°bootloaderÅäÖÃÎÄ¼þ:pxelinux.0

yum install syslinux -y &> /dev/null

# °Ñbootloader¿½±´µ½tftp·þÎñÆ÷
cp /usr/lib/syslinux/pxelinux.0 /tftpboot/


#°ÑÄÚºËºÍÇý¶¯¿½±´µ½tftp·þÎñÆ÷
cd /var/ftp/iso/isolinux/
mkdir /tftpboot/pxelinux.cfg/
cp isolinux.cfg /tftpboot/pxelinux.cfg/default
cd /var/ftp/iso/images/pxeboot
cp initrd.img vmlinuz  /tftpboot/



#--------------------------------------------------#
#               ÐÞ¸Ätftpµ½defaultÎÄ¼þ              #
#--------------------------------------------------#

cat <<  EOF >> /tftpboot/pxelinux.cfg/default
label ks5u5
menu label ^A centos5u5
kernel vmlinuz
append ks=ftp://172.16.30.30/pub/ks.cfg initrd=initrd.img
EOF

sed -ri 's#(^default)(.*$)#\1 ks5u5#' /tftpboot/pxelinux.cfg/default
sed -ri  's#(^prompt)(.*$)#\1 0#'     /tftpboot/pxelinux.cfg/default

cat << EOF > /var/ftp/pub/ks.cfg
#platform=x86, AMD64, or Intel EM64T
# System authorization information
auth  --useshadow  --enablemd5 
# System bootloader configuration
bootloader --location=mbr
# Partition clearing information
clearpart --all --initlabel 
# Use graphical install
graphical
# Firewall configuration
firewall --disabled
# Run the Setup Agent on first boot
firstboot --disable
# System keyboard
keyboard us
# System language
lang en_US
# Installation logging level
logging --level=info
# Use network installation
url --url=ftp://172.16.30.30/iso
# Network information
network --bootproto=dhcp --device=eth0 --onboot=on
# Reboot after installation
reboot
#Root password
rootpw redhat

# SELinux configuration
selinux --disabled
# Do not configure the X Window System
skipx
# System timezone
timezone  Asia/Shanghai
# Install OS instead of upgrade
install
# Disk partitioning information
part /boot --bytes-per-inode=4096 --fstype="ext3" --size=100
part / --bytes-per-inode=4096 --fstype="ext3" --size=10240
part swap --bytes-per-inode=4096 --fstype="swap" --size=1024
%post  --nochroot
%post
!/bin/bash

mkdir /mnt/cdrom

echo "/dev/cdrom		/mnt/cdrom		iso9660	defaults	0 0" >> /etc/fstab
rm -f /etc/yum.repos.d/CentOS-Base.repo
cat  << FI >/etc/yum.repos.d/CentOS-Base.repo
[base]
name=CentOS-$releasever - Base
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os
baseurl=file:///mnt/cdrom
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5

#released updates
[updates]
name=CentOS-$releasever - Updates
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates
baseurl=file:///mnt/cdrom
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
enabled=0
#packages used/produced in the build but not released
[addons]
name=CentOS-$releasever - Addons
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=addons
baseurl=file:///mnt/cdrom
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
enabled=0

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras
baseurl=file:///mnt/cdrom
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
enabled=0

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus
baseurl=file:///mnt/cdrom
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
#contrib - packages by Centos Users
[contrib]
name=CentOS-$releasever - Contrib
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=contrib
baseurl=file:///mnt/cdrom
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
FI
echo "enter your ip address: "
read  -p  'enter your id address: '  a
sed -i '/BOOTPROTO/s#dhcp#static#' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '$a IPADDR='$a' ' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '$a NETMASK=255.255.0.0' /etc/sysconfig/network-scripts/ifcfg-eth0


%packages
@base
@base-x
@chinese-support
EOF
