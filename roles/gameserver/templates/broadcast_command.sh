#!/bin/sh

# Broadcasts a command to every running Minecraft server.

ARGC=$#

if [ $ARGC -lt 1 ]; then
  echo "Usage: $0 <command>"
  exit
fi

USER=pablo

send_command () {
    screen -S $1 -X stuff "`printf "$2 \015"`"
    # Escapes are dropped. Why?
    # COMMAND=$2
    # echo $COMMAND
    # sudo -u $USER screen -S $1 -X stuff "$COMMAND"
}

send_command_all () {
    for i in $(screen -ls | grep '[0-9]\.zcraft[^0-9]' | awk '{ print $1 }')
    do
        send_command $i "`echo "$*" | sed 's/"/\\\"/g'`"
    done
}

send_command_all $@
