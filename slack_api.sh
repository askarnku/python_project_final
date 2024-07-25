#!/bin/bash

slack_wh='https://hooks.slack.com/services/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'

curl -X POST -H 'Content-type: application/json' --data '{"text":"Testing"}' $slack_wh