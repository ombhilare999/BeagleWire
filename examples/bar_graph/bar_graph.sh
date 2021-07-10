#!/bin/bash

while true
do	 
   ./../../bridge_lib/memmap -a 0 -w 0001
   sleep 0.1
   ./../../bridge_lib/memmap -a 0 -w 0002
   sleep 0.1
   ./../../bridge_lib/memmap -a 0 -w 0004
   sleep 0.1
   ./../../bridge_lib/memmap -a 0 -w 0008
   sleep 0.1
   ./../../bridge_lib/memmap -a 0 -w 0010
   sleep 0.1
   ./../../bridge_lib/memmap -a 0 -w 0020
   sleep 0.1
   ./../../bridge_lib/memmap -a 0 -w 0040
   sleep 0.1
   ./../../bridge_lib/memmap -a 0 -w 0080
   sleep 0.1
done