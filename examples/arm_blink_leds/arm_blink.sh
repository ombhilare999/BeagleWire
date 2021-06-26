#!/bin/bash

while true
do	
   echo "All LEDs on" 
   ./../../bridge_lib/memmap -a 0 -w 000F
   sleep 0.5

   echo "All LEDs off" 
   ./../../bridge_lib/memmap -a 0 -w 0000
   sleep 0.5
done