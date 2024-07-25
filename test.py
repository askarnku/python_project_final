#!/bin/python3

import os

# Fetch the webhook URL from the environment variables
slack_webhook_url = os.getenv('SLACK_WEBHOOK_URL_DEV')

if slack_webhook_url is None:
    print("SLACK_WEBHOOK_URL is not set.")
else:
    print(f"Slack Webhook URL: {slack_webhook_url}")
