#!/bin/bash

source ~/.bashrc

slack_wh=$SLACK_WEBHOOK_URL_DEV

curl -X POST -H 'Content-type: application/json' --data '{"text":"Testing"}' $slack_wh


# Example variables
key="SomeKey"
payload="This is some payload information"

# Generate JSON payload with multiple lines using jq
json_payload=$(jq -n --arg key "$key" --arg payload "$payload" \
    '{text: ($key + "\n" + $payload)}')

# Use curl to send the payload
curl -X POST -H 'Content-type: application/json' --data "$json_payload" $slack_wh



