#!/bin/sh

# Broadcasts a message to every running Minecraft server.

ARGC=$#

if [ $ARGC -lt 1 ]; then
  echo "Usage: $0 <json text>"
  exit
fi

MESSAGE=$(echo "$@" | sed 's/"/\\"/g')

./broadcast_command.sh tellraw @a '{"text": ""}'
./broadcast_command.sh tellraw @a '{"text":"","extra":[{"text": "Zcraft", "color": "dark_green", "bold": true}, {"text": " » ", "color": "green"},'$MESSAGE']}'
./broadcast_command.sh tellraw @a '{"text": ""}'
