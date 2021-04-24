#!/bin/sh

HOUR=$(date +%H)
DISCORD_DATA=$(curl --silent https://canary.discordapp.com/api/guilds/307846049626849280/widget.json)
VOICE_USERS_COUNT=$(echo $DISCORD_DATA | jq '.members | map(select(has("channel_id") and .suppress == false and .self_deaf == false and .deaf == false)) | length')

if [ $VOICE_USERS_COUNT -gt 0 ]; then
  VOICE_USERS=$(echo $DISCORD_DATA | jq -r '.members | map(select(has("channel_id") and .suppress == false and .self_deaf == false and .deaf == false)) | map("§f" + .username + if .self_mute or .mute then " §8(muet)" else "" end + "§7") | join(", ")')
fi

if [ $HOUR -eq 0 ]; then
  MESSAGE_TIME="Il est minuit."
elif [ $HOUR -eq 1 ]; then
  MESSAGE_TIME="Il est une heure."
else
  MESSAGE_TIME="Il est $HOUR heures."
fi

MESSAGE_VOICE=''

if [ $VOICE_USERS_COUNT -eq 1 ]; then
  MESSAGE_VOICE=" Il y a au moins une personne en vocal."
elif [ $VOICE_USERS_COUNT -gt 1 ]; then
  MESSAGE_VOICE=" Il y a au moins $VOICE_USERS_COUNT personnes en vocal."
fi

./broadcast_rawtext.sh \{\"text\": \"$MESSAGE_TIME\", \"color\": \"yellow\"\}, \{\"text\": \"$MESSAGE_VOICE\", \"color\": \"gray\", \"hoverEvent\":\{\"action\": \"show_text\", \"contents\":\{\"text\": \"$VOICE_USERS\"\}\}\}
