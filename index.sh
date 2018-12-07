
handler () {
    set -e
    llsdfd
    echo $EVENT_DATA | jq ."text"
    echo $EVENT_DATA >&2
}