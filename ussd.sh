#!/bin/bash

# ussd.sh v1.0 (22.06.2013) by Shumaher (original source from http://wiki.russianfedora.ru/USB-модемы)
# http://blog.shumaher.net.ru/huawei-ussd
##########################

SCRIPTVER='ussd.sh v1.0 (22.06.2013) by Shumaher'

echo $SCRIPTVER
echo
echo

decodeUCS2()	# UCS to text
{
    bytes=$(echo -n $1 | sed "s/\(.\{2\}\)/\\\x\1/g")
    REPLY=$(printf $bytes | iconv -f UCS-2BE -t UTF-8)
	echo "$REPLY"
}

encodePDU()		# text to PDU
{
    in=$1
    let "in_len=${#in}-1"
    for chr in $(seq  0 $in_len)
    do
        let "chr2=$chr+1"
        let "t=$chr%8+1"
        if [ "$t" -ne 8 ]; then
            byte=$(printf "%d" "'${in:$chr:1}")
            let "c=$byte>>($chr%8)"
            let "c2=(1<<$t)-1"
            byte2=$(printf "%d" "'${in:$chr2:1}")
            let "b=$byte2 & $c2"
            let "c=$b<<(8-$t) | $c"
            REPLY=$REPLY$(echo "obase=16; $c" | bc | sed "s/^\(.\{,1\}\)$/0\1/")
        fi
    done
	echo "$REPLY"
	echo
	echo "AT-command to send '$1' as USSD-request: AT+CUSD=1,\"$REPLY\",15"
}

helpmsg()
{
	echo "Type '`basename $0` *USSD*command#' to convert USSD-request to PDU"
	echo "or   '`basename $0` UCS2-message'   to convert UCS2-encoded USSD-answer to UTF8."
	echo
	echo "See http://blog.shumaher.net.ru/huawei-ussd for more info!"
}

if [ $# -eq 0 ]
then
	helpmsg
elif [ $# -eq 1 ] && echo -n $1 | grep -q '^[#|\*].*'
then
	encodePDU "$1"
elif [ $# -gt 1 ]
	then
	echo "Invalid argument."
	helpmsg
else
	decodeUCS2 "$1"
fi
echo
