#!/bin/bash

# https://hooks.slack.com/services/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

slack_wh='https://hooks.slack.com/services/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'

curl -X POST -H 'Content-type: application/json' --data '{"text":"Testing"}' $slack_wh