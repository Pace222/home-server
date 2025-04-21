#!/bin/bash

# Log to Telegram
curl -X POST -H "Content-Type: application/json" \
  -d '{
    "topic": "dynamic_dns",
    "message": "ℹ️ New IP Address: '$1'"
  }' \
  http://int-tele-bot/message
