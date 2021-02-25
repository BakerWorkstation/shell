#!/bin/bash
echo "****  开始自动配置安全基线  ****"


# 锁定与设备运行、维护等工作无关的账号
echo -e "\n1. 锁定与设备运行、维护等工作无关的账号"
cp /etc/shadow /etc/'shadow-'`date +%Y%m%d`.bak
passwd -l adm&>/dev/null 2&>/dev/null
passwd -l daemon&>/dev/null 2&>/dev/null
passwd -l bin&>/dev/null 2&>/dev/null
passwd -l sys&>/dev/null 2&>/dev/null
passwd -l lp&>/dev/null 2&>/dev/null
passwd -l uucp&>/dev/null 2&>/dev/null
passwd -l nuucp&>/dev/null 2&>/dev/null
passwd -l smmsplp&>/dev/null 2&>/dev/null
passwd -l mail&>/dev/null 2&>/dev/null
passwd -l operator&>/dev/null 2&>/dev/null
passwd -l games&>/dev/null 2&>/dev/null
passwd -l gopher&>/dev/null 2&>/dev/null
passwd -l ftp&>/dev/null 2&>/dev/null
passwd -l nobody&>/dev/null 2&>/dev/null
passwd -l nobody4&>/dev/null 2&>/dev/null
passwd -l noaccess&>/dev/null 2&>/dev/null
passwd -l listen&>/dev/null 2&>/dev/null
passwd -l webservd&>/dev/null 2&>/dev/null
passwd -l rpm&>/dev/null 2&>/dev/null
passwd -l dbus&>/dev/null 2&>/dev/null
passwd -l avahi&>/dev/null 2&>/dev/null
passwd -l mailnull&>/dev/null 2&>/dev/null
passwd -l nscd&>/dev/null 2&>/dev/null
passwd -l vcsa&>/dev/null 2&>/dev/null
passwd -l rpc&>/dev/null 2&>/dev/null
passwd -l rpcuser&>/dev/null 2&>/dev/null
passwd -l nfs&>/dev/null 2&>/dev/null
passwd -l sshd&>/dev/null 2&>/dev/null
passwd -l pcap&>/dev/null 2&>/dev/null
passwd -l ntp&>/dev/null 2&>/dev/null
passwd -l haldaemon&>/dev/null 2&>/dev/null
passwd -l distcache&>/dev/null 2&>/dev/null
passwd -l webalizer&>/dev/null 2&>/dev/null
passwd -l squid&>/dev/null 2&>/dev/null
passwd -l xfs&>/dev/null 2&>/dev/null
passwd -l gdm&>/dev/null 2&>/dev/null
passwd -l sabayon&>/dev/null 2&>/dev/null
passwd -l named&>/dev/null 2&>/dev/null
echo -e "\033[1;31m\t设置完成    \033[0m"


# 用户的umask安全配置
echo -e "\n2. 配置umask为022"
cp /etc/profile /etc/'profile-'`date +%Y%m%d`.bak
egrep -q "^\s*umask\s+\w+.*$" /etc/profile && sed -ri "s/^\s*umask\s+\w+.*$/umask 022/" /etc/profile || echo "umask 022" >> /etc/profile
cp /etc/csh.login /etc/'csh.login-'`date +%Y%m%d`.bak
egrep -q "^\s*umask\s+\w+.*$" /etc/csh.login && sed -ri "s/^\s*umask\s+\w+.*$/umask 022/" /etc/csh.login || echo "umask 022" >>/etc/csh.login
cp /etc/csh.cshrc /etc/'csh.cshrc-'`date +%Y%m%d`.bak
egrep -q "^\s*umask\s+\w+.*$" /etc/csh.cshrc && sed -ri "s/^\s*umask\s+\w+.*$/umask 022/" /etc/csh.cshrc || echo "umask 022" >> /etc/csh.cshrc
cp /etc/bashrc /etc/'bashrc-'`date +%Y%m%d`.bak
egrep -q "^\s*umask\s+\w+.*$" /etc/bashrc && sed -ri "s/^\s*umask\s+\w+.*$/umask 022/" /etc/bashrc || echo "umask 022" >> /etc/bashrc
echo -e "\033[1;31m\t设置完成    \033[0m"


# 重要目录和文件的权限设置
echo -e "\n3. 设置重要目录和文件的权限"
chmod 755 /etc
chmod 750 /etc/rc.d/init.d
chmod 777 /tmp
chmod 700 /etc/inetd.conf&>/dev/null 2&>/dev/null
chmod 755 /etc/passwd
chmod 755 /etc/shadow
chmod 644 /etc/group
chmod 755 /etc/security
chmod 644 /etc/services
chmod 750 /etc/rc*.d
echo -e "\033[1;31m\t设置完成    \033[0m"


# 用户目录缺省访问权限设置
echo -e "\n4. 设置用户目录默认权限为022"
egrep -q "^\s*(umask|UMASK)\s+\w+.*$" /etc/login.defs && sed -ri "s/^\s*(umask|UMASK)\s+\w+.*$/UMASK 022/" /etc/login.defs || echo "UMASK 022" >> /etc/login.defs
echo -e "\033[1;31m\t设置完成    \033[0m"


# 日志文件非全局可写
echo -e "\n5. 设置日志文件非全局可写"
chmod 755 /var/log/messages; chmod 775 /var/log/spooler; chmod 775 /var/log/mail&>/dev/null 2&>/dev/null; chmod 775 /var/log/cron; chmod 775 /var/log/secure; chmod 775 /var/log/maillog; chmod 775 /var/log/localmessages&>/dev/null 2&>/dev/null
echo -e "\033[1;31m\t设置完成    \033[0m"


# 记录su命令使用情况
echo -e "\n6. 配置并记录su命令使用情况"
cp /etc/rsyslog.conf /etc/'rsyslog.conf-'`date +%Y%m%d`.bak
egrep -q "^\s*authpriv\.\*\s+.+$" /etc/rsyslog.conf && sed -ri "s/^\s*authpriv\.\*\s+.+$/authpriv.*                                              \/var\/log\/secure/" /etc/rsyslog.conf || echo "authpriv.*                                              /var/log/secure" >> /etc/rsyslog.conf
echo -e "\033[1;31m\t设置完成    \033[0m"


# 记录安全事件日志
echo -e "\n7. 配置安全事件日志审计"
touch /var/log/adm&>/dev/null; chmod 755 /var/log/adm
semanage fcontext -a -t security_t '/var/log/adm' 
flag=$?
restorecon -v '/var/log/adm'&>/dev/null
egrep -q "^\s*\*\.err;kern.debug;daemon.notice\s+.+$" /etc/rsyslog.conf 
sed -ri "s/^\s*\*\.err;kern.debug;daemon.notice\s+.+$/*.err;kern.debug;daemon.notice           \/var\/log\/adm/" /etc/rsyslog.conf || echo "*.err;kern.debug;daemon.notice           /var/log/adm" >> /etc/rsyslog.conf
if [ $flag -eq 0 ]
then
	echo -e "\033[1;31m\t设置完成    \033[0m"
else
	echo -e "\033[1;31m\t设置失败    \033[0m"
fi


# 删除潜在威胁文件
echo -e "\n8. 删除潜在威胁文件"
find / -maxdepth 3 -name hosts.equiv | xargs -i mv {} {}.bak
find / -maxdepth 3 -name .netrc | xargs -i mv {} {}.bak
find / -maxdepth 3 -name .rhosts | xargs -i mv {} {}.bak
echo -e "\033[1;31m\t删除完成    \033[0m"


# 限制不必要的服务
echo -e "\n9. 限制不必要的服务"
systemctl disable rsh&>/dev/null 2&>/dev/null
systemctl disable talk&>/dev/null 2&>/dev/null
systemctl disable telnet&>/dev/null 2&>/dev/null
systemctl disable tftp&>/dev/null 2&>/dev/null
systemctl disable rsync&>/dev/null 2&>/dev/null
systemctl disable xinetd&>/dev/null 2&>/dev/null
systemctl disable nfs&>/dev/null 2&>/dev/null
systemctl disable nfslock&>/dev/null 2&>/dev/null
echo -e "\033[1;31m\t设置完成    \033[0m"


# 配置系统历史命令操作记录和定时帐户自动登出时间
echo -e "\n10. 配置系统历史命令操作记录和定时帐户自动登出时间"
grep -i "^HISTSIZE=" /etc/profile >/dev/null
#历史记录保留一万条
if [ $? == 0 ];
then
    sed -i "s/^HISTSIZE=.*$/HISTSIZE=10000/g" /etc/profile
else
    echo 'HISTSIZE=10000' >> /etc/profile
fi
echo -e "\033[1;31m\t保留历史命令10000条    \033[0m"
# 历史命令显示格式
grep -i "^export HISTTIMEFORMAT=" /etc/profile > /dev/null
if [ $? == 0 ];then
    sed -i 's/^export HISTTIMEFORMAT=.*$/export HISTTIMEFORMAT="%F %T `whoami`"/g' /etc/profile
else
    echo 'export HISTTIMEFORMAT="%F %T `whoami` | "' >> /etc/profile
fi
#超时时间600秒
tmout=600
grep -i "^TMOUT=" /etc/profile	> /dev/null
if [ $? == 0 ];then
    sed -i "s/^TMOUT=.*$/TMOUT=$tmout/g" /etc/profile
else
    echo "TMOUT=$tmout" >> /etc/profile
fi
echo -e "\033[1;31m\t设置完成    \033[0m"


# ssh登录失败锁定
echo -e "\n11. ssh登录失败锁定"
logonconfig=/etc/pam.d/sshd
grep -i "^auth.*required.*pam_tally2.so.*$" $logonconfig  > /dev/null
if [ $? == 0 ];then
   sed -i "s/auth.*required.*pam_tally2.so.*$/auth required pam_tally2.so deny=3 unlock_time=300 even_deny_root root_unlock_time=300/g" $logonconfig > /dev/null
else
   sed -i '/^#%PAM-1.0/a\auth required pam_tally2.so deny=3 unlock_time=300 even_deny_root root_unlock_time=300' $logonconfig > /dev/null
fi
if [ $? == 0 ];then
    echo -e "\033[1;31m\t限制登入失败三次，普通账号锁定5分钟，root账号锁定5分钟\033[0m"
	echo -e "\033[37;5m\t[ssh登录失败锁定设置成功]	\033[0m"
else
    echo -e "\033[31;5m\t[ssh登录失败锁定设置失败]	\033[0m"
fi

source /etc/profile
echo "****  安全基线配置完成  ****"