#!/bin/bash

function handler () {
    EVENT_DATA=$1

    echo "this is my function" >&2

    echo $EVENT_DATA
}