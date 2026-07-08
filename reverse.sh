#!/bin/bash
echo "enter a number :"
read n
temp=$n
sum=0
while [ "$temp" -ne 0 ]
do 
    d=$(( $temp % 10 ))
    c=$(( $d * $d * $d ))
    sum=$(( $sum + $c ))
    temp=$(( $temp / 10 ))
done
if [ "$sum" -eq "$n" ]
then
    echo "$n is an armstrong number"
else
    echo "$n is not an armstrong number"
fi
