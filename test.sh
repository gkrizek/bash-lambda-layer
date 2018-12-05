#!/bin/bash

function handler () {
    EVENT_DATA=$1
    unset command_not_found_handle
    echo "this is my function" >&2
    git ls
    echo $?
    echo $EVENT_DATA
}