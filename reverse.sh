#!/bin/bash
echo "enter a number :"
read n
rno=0
while [ "$n" -ne 0 ]
do 
    d=$($n%10)
    rno=$($rno*10+$d)
    n=$($n/10)
done
echo "reverse number is : $rno"
