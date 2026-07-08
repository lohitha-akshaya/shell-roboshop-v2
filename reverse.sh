#!/bin/bash

echo "Enter a number:"
read n
echo "enter second number:"
read m


for (( i=n; i<=m; i++ ))
do 
  if [ $(( i % 2 )) -eq 1 ]; then 
       
    echo "$i"
  fi
done
