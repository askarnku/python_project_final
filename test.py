#!/bin/python3

import os
import requests
import json

# Fetch the webhook URL from the environment variables
slack_wh = os.getenv('SLACK_WEBHOOK_URL_DEV')

data = {"text": "Testing via Python"}

response = requests.post(slack_wh, json=data)

print(response.status_code)
print(response.text)
