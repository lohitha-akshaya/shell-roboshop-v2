#!/bin/bash
echo "enter a number:"
read n
flag=1
i=2
while [ $i < = n/2 ]
do 
   if [ n % i == 0]; then
      flag=0
      break
   fi
done 
if [ $flag -eq 1 ]; then
   echo "$n is a prime number"
else
   echo "$n is not a prime number"
fi