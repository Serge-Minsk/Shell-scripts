#!/bin/bash

FILENAME=
INTERFACE=
INTERVAL=

function usage() {
	echo $0 -f filename -i interface -u interval
	
	exit 1;
}

function extract_params(){

	if [ $# -ne 6 ]
	then
		usage
	fi

	while [ $# -gt 1 ]
	do
		case $1 in
			-f)
				FILENAME=$2
				;;
			-i)
				INTERFACE=$2
				;;
			-u)
				INTERVAL=$2
				;;		
		
			*)
				usage
				;;
		esac
		shift
		shift
	done
}

function generate_minute_list() {

	INT=$1
	CRT_MIN=date+%M
	CRT_MIN=$(($CRT_MIN + 2))

	FIN_MIN=$(($CRT_MIN + 60))
	
	LIST=	
	for ((I=$CRT_MIN; $I < $FIN_MIN; I= expr $I + $INT ))
	do
		ADD_MIN=$(($I % 60))
		LIST= echo $LIST $ADD_MIN
	done
	echo $LIST
}

extract_params $@

OK_INTS="5 10 20 30 60"

if ! echo $OK_INTS | grep -w $INTERVAL > /dev/null
then
	echo Accepted time intervals are $OK_INTS
	exit 2
fi
MINUTE_LIST=$1
MINUTE_LIST=generate_minute_list $INTERVAL

#echo $MINUTE_LIST

rm -f ifMonitor.crontab

for MIN in $MINUTE_LIST
do
	echo $MIN \*\*\*\* $PWD/check_iface -i $INTERFACE -f $PWD/$FILENAME >> ifMonitor.crontab
done
crontab ifMonitor.crontab
crontab -l 



#echo interface $interface
#echo filename $filename
#DATE= date  
# + %Y-%m-%d %H:%M
#data_string= cat /proc/net/dev | grep -w $interface | cut -f 2 -d':' | awk '{print $1,$2,$9,$10}'
#
#if [  -z "$data_string" ]
#then
#	echo Interface $interface does not exist
#fi
#rx_bytes= echo $data_string | awk '{print $1}'
#rx_pkts= echo $data_string | awk '{print $2}'
#tx_bytes= echo $data_string | awk '{print $3}'
#tx_pkts= echo $data_string | awk '{print $4}'

#if [ ! -e $filename ]
#then
#	echo "Date,Rx bytes,Rx packets,Avg Rx Pkt,Tx bytes,Tx packets,Avg Tx Pkt" > $filename
#fi
#echo $DATE,$rx_bytes,$rx_pkts,$tx_bytes,$tx_pkts >> $filename









