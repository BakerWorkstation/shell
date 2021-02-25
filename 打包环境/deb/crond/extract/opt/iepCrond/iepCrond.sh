#!/bin/bash
start()
{
    cd /opt/iepCrond
    echo "start iep Crond"
    nohup python  iepCrond.pyc &> /dev/null &
    exit 0
}

down()
{
    ps aux | grep 'iepCrond.pyc' | awk '{print $2}'| xargs -i kill {}
    exit 0
}


case $1 in
    -s) start;;
    -d) down;;
    *)  echo "Usage: $0 <-s|-d>";;
esac

