
handler () {
    set -e

    # Event Data is sent as the first parameter
    EVENT_DATA=$1

    # This is the Event Data
    echo $EVENT_DATA

    # Example of command usage
    EVENT_JSON=$(echo $EVENT_DATA | jq .)

    # Example of AWS command that's output will show up in CloudWatch Logs
    aws s3 ls

    # This is the return value because it's being sent to stderr (>&2)
    echo "{\"success\": true}" >&2
}