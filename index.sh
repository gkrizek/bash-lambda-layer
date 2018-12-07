#!/bin/bash

function handler () {
    set -e
    EVENT_DATA=$1
    echo "this is my function"
    echo "this is my function"
    for i in `seq 1 25`;
      do
        echo $i
      done  
    lsssss
    echo $?
    echo "after....."
    echo "TESTING" > /tmp/testing.out
    echo $?
    echo $EVENT_DATA >&2
    
}