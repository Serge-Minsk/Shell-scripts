#!/bin/bash

declare -a DIGNAM
DIGNAM=(zero one two three four [5]=five six seven eight nine)
DIGNAM[2]=two

for anarg
do
        for ((i=0; i<${#anarg} ; i++))
        do
                C=${anarg:i:1}
                case "$C" in
                [0-9])  SAY="${DIGNAM[$C]}"
                        ;;
                *)      SAY="$C"
                esac
                printf "%s " "$SAY"
        done
        echo
done
