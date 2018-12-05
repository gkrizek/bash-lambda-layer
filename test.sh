#!/bin/bash -xe

function handler () {
    EVENT_DATA=$1

    echo "this is my function" >&2
    git ls
    echo $EVENT_DATA
}