#!/bin/bash

echo "Enter a number:"
read n
echo "enter second number:"
read m


for (( i=n; i<=m; i++ ))
do
    echo "$i"
done
