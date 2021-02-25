#!/bin/bash

echo 'start install ......'

cd /opt/kafka_package/packages

unzip librdkafka-master.zip
cd  librdkafka-master
./configure --prefix=/usr
make
make install
ldconfig
cd ..

unzip setuptools-40.8.0.zip
cd setuptools-40.8.0
python setup.py install
cd ..

tar zxvf urllib3-1.25.2.tar.gz
cd urllib3-1.25.2
python setup.py install
cd ..

tar zxvf certifi-2019.3.9.tar.gz
cd certifi-2019.3.9
python setup.py install
cd ..

tar zxvf idna-2.8.tar.gz
cd idna-2.8
python setup.py install
cd ..

tar zxvf chardet-3.0.4.tar.gz
cd chardet-3.0.4
python setup.py install
cd ..

unzip enum34-1.1.6.zip
cd enum34-1.1.6
python setup.py install
cd ..

tar zxvf futures-3.2.0.tar.gz
cd futures-3.2.0
python setup.py install
cd ..


tar zxvf requests-2.22.0.tar.gz
cd requests-2.22.0
python setup.py install
cd ..

tar zxvf confluent-kafka-1.0.0.tar.gz
cd confluent-kafka-1.0.0
python setup.py install
cd ..


echo 'finish install ......'
