#!/bin/bash

while true
do	 
   ./../../bridge_lib/memmap -a 00 -w 0001
   sleep 1
   ./../../bridge_lib/memmap  -a 42 -w 0080
   sleep 1
   ./../../bridge_lib/memmap  -a 00 -w 0002
   sleep 1
   ./../../bridge_lib/memmap  -a 42 -w 0040
   sleep 1
   ./../../bridge_lib/memmap  -a 00 -w 0004
   sleep 1
   ./../../bridge_lib/memmap  -a 42 -w 0020
   sleep 1
   ./../../bridge_lib/memmap  -a 00 -w 0008
   sleep 1
   ./../../bridge_lib/memmap  -a 42 -w 0010
   sleep 1
   ./../../bridge_lib/memmap  -a 00 -w 0010
   sleep 1
   ./../../bridge_lib/memmap  -a 42 -w 0008
   sleep 1
   ./../../bridge_lib/memmap  -a 00 -w 0020
   sleep 1
   ./../../bridge_lib/memmap  -a 42 -w 0004
   sleep 1
   ./../../bridge_lib/memmap  -a 00 -w 0040
   sleep 1
   ./../../bridge_lib/memmap  -a 42 -w 0002
   sleep 1
   ./../../bridge_lib/memmap  -a 00 -w 0080
   sleep 1
   ./../../bridge_lib/memmap  -a 42 -w 0001
   sleep 1
done
