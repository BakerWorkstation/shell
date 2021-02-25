Name:   confluent_kafka
Version:    1.0.1
Release:    1.0
Summary:    confluent kafka client

Group:      Applications/Productivity

Prefix:     /opt/kafka_package

Autoreq:    no
Autoprov:   no
Autoreqprov:no

License:    GPL
#URL:        www.antiy.cn
Source0:     confluent_kafka-1.0.1.tar.gz
#Source1:    openssl-1.0.2e.tar.gz
#Source2:    pcre-8.38.tar.gz
#Source3:    zlib-1.2.8.tar.gz

#测试rpm安装默认文件生成目录
BuildRoot:      %_topdir/BUILDROOT

BuildRequires:      gcc, gcc-c++

%description
confluent kafka client

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
bash /opt/kafka_package/setup.sh > /tmp/kafkaclientinstall.log
rm -rf /opt/kafka_package


#rpm卸载前执行的脚本
%preun


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
