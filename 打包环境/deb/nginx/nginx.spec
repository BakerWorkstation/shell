%define __debug_install_post \
%{_rpmconfigdir}/find-debuginfo.sh %{?_find_debuginfo_opts} "%{_builddir}/%{?buildsubdir}"\
%{nil}

Name:   nginx
Version:    1.12.2
Release:    1.0
Summary:    nginx server package

Group:      Applications/Productivity

Prefix:     /opt/nginx

Autoreq:    no
Autoprov:   no
Autoreqprov:no

License:    GPL
URL:        www.antiy.cn
Source0:    nginx-1.12.2.tar.gz
#Source1:    openssl-1.0.2e.tar.gz
#Source2:    pcre-8.38.tar.gz
#Source3:    zlib-1.2.8.tar.gz

#测试rpm安装默认文件生成目录
BuildRoot:      %_topdir/BUILDROOT

BuildRequires:      gcc, gcc-c++

%description
nginx server 1.12.2

#安装前执行的脚本,我们先空着
#$1==1 代表的是第一次安装，2代表是升级，0代表是卸载 
%pre
#if [ $1 == 1 ];then    
#        /usr/sbin/useradd -r nginx 2> /dev/null  ##其实这个脚本写的不完整
#fi 


#安装前执行的脚本,我们先空着$1==1 代表的是第一次安装，2代表是升级，0代表是卸载 
#%pre
#echo $1

#rpm包安装后执行的脚本
%post
#bash /opt/ieppackage/setup.sh > /tmp/iepserverinstall.log
#rm -rf /opt/ieppackage

test -d /etc/nginx || mkdir /etc/nginx
\cp -rpf /opt/nginx/nginx/*    /etc/nginx/
mv /opt/nginx/nginx.service  /usr/lib/systemd/system/

ln -s /usr/lib/systemd/system/nginx.service /etc/systemd/system/nginx.service && systemctl daemon-reload && systemctl enable nginx.service

rm -rf /opt/nginx/nginx
\cp -rpf /opt/nginx/logrotate.d  /etc/
\cp -rpf /opt/nginx/sysconfig    /etc/
\cp -rpf /opt/nginx/libexec      /usr/
\cp -rpf /opt/nginx/share        /usr/
\cp -rpf /opt/nginx/var/*          /var/

rm -rf /opt/nginx/logrotate.d
rm -rf /opt/nginx/sysconfig
rm -rf /opt/nginx/libexec
rm -rf /opt/nginx/share
rm -rf /opt/nginx/var

#rpm卸载前执行的脚本
%preun
systemctl  stop  nginx
unlink  /etc/systemd/system/nginx.service
rm -rf /etc/logrotate.d/nginx
rm -rf /etc/sysconfig/nginx*
rm -rf /etc/nginx/

rm -rf /opt/nginx/

rm -f /usr/lib/systemd/system/nginx.service
rm -rf /usr/libexec/initscripts/legacy-actions/nginx
rm -rf /usr/share/doc/nginx*
rm -rf /usr/share/man/man8/nginx*
rm -rf /usr/share/nginx

rm -rf /var/cache/nginx
rm -rf /var/log/nginx


#rpm卸载后执行的脚本
%postun


#预处理脚本
%prep
%setup -q                                   #解压并cd到相关目录

#构建包
%build

#定义安装软件包，使用默认值即可
%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{prefix}
\cp -rpf  ./*  %{buildroot}%{prefix}


%files
%defattr(-,root,root)
%{prefix}


%changelog                                  #主要用于软件的变更日志。该选项可有可无
%clean 
rm -rf %{buildroot}                         #清理临时文件
