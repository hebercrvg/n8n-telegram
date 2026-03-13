#!/bin/sh

LOCK_FILE="/home/node/.n8n/.setup-done"
CREDS_FILE="/tmp/telegram-creds.json"

mkdir -p /home/node/.n8n

if [ ! -f "$LOCK_FILE" ]; then
  echo "[setup] First run detected — importing credentials and workflow..."

  cat > "$CREDS_FILE" << EOF
[
  {
    "id": "1",
    "name": "Telegram API",
    "type": "telegramApi",
    "data": {
      "accessToken": "${TELEGRAM_BOT_TOKEN}"
    },
    "nodesAccess": []
  }
]
EOF

  n8n import:credentials --input="$CREDS_FILE"
  echo "[setup] Credentials imported."
  rm -f "$CREDS_FILE"

  n8n import:workflow --input=/workflow-telegram-chatbot.json
  echo "[setup] Workflow imported."

  touch "$LOCK_FILE"
  echo "[setup] Setup complete."
fi

exec n8n
