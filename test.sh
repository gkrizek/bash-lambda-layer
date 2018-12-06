#!/bin/bash

function handler () {
    set -e
    EVENT_DATA=$1
    echo "this is my function"
    lsssss
    RETURN_VALUE="this is the return value"
    echo $?
    echo $EVENT_DATA
}