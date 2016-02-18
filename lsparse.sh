#!/bin/bash

function max ()
{
        if (( ${1}  > MAX ))
        then
                MAX=$1
        fi
}

function lsparse ()
{
        if (( $# < 9 ))
        then
                SIZ=-1
        else
                SIZ=$5
        fi
}
 declare -i CNT MAX=-1
while read lsline
do
        let CNT++
        lsparse $lsline
        max $SIZ
done

printf "largest of %d file was: %d\n" $CNT $MAX
