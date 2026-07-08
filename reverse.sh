#!/bin/bash

echo "Enter a number:"
read num

i=2
flag=0

while [ $i -lt $num ]
do
    if [ $((num % i)) -eq 0 ]
    then
        flag=1
        break
    fi
    i=$((i + 1))
done

if [ $num -le 1 ]
then
    echo "$num is not a Prime Number"
elif [ $flag -eq 0 ]
then
    echo "$num is a Prime Number"
else
    echo "$num is not a Prime Number"
fi