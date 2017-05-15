#!/bin/bash
PORT=2003
SERVER=localhost
RESP=`echo -en '\xff\x01\x86\x00\x00\x00\x00\x00\x79' > /dev/ttyS1 | head -c 9 /dev/ttyS1 | hexdump -v -e '1/1 "%d" " "'`
RA=(${RESP// / })

if [ "${#RA[@]}" -lt "9" ]
then
    echo "Read error"
    exit 1
fi

CRC=0
for i in {1..7}
do
    let CRC+=RA[$i]
done
CRC=$((256-$((CRC%256))))
CRC=$((CRC%256))

if [ "$CRC" == "${RA[8]}" ]
then
    let CO2=RA[2]*256+RA[3];
    let T=(RA[4]-32)*5/9;
    echo "CO2: $CO2    T: $T"
    echo "home.temp_2 $T `date +%s`" | nc ${SERVER} ${PORT}
    echo "home.co2_2 $CO2 `date +%s`" | nc ${SERVER} ${PORT}

else
    echo "CRC error"
fi

exit 0
