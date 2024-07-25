slack_wh='https://hooks.slack.com/services/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'

curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello, World!"}' $slack_wh