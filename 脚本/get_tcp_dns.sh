tmp_file='/dev/shm/pcap6.tmp'

if ! [ -d Network1 ]; then
    mkdir Network1
fi

find PCAP1 -type f | while read line
do
    tshark -r $line > $tmp_file 2>/dev/null
    if grep 'TCP' $tmp_file --color|| grep 'DNS' $tmp_file  --color; then
        mv $line Network1/
    fi
done
