#!/bin/sh

# Boots a Minecraft server.

ARGC=$#

if [ $ARGC -ne 2 ]; then
  echo "Usage: $0 <folder_name> <RAM_in_MB>"
  exit
fi

FOLDER=$1
RAM=$2

REBOOT_DELAY=6

mkdir -p "$FOLDER"

cd "$FOLDER" || exit

while :
do
  java -Xms${RAM} -Xmx${RAM} -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \
	  -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch \
	  -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 \
	  -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 \
	  -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 \
	  -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs \
	  -Daikars.new.flags=true -jar paper.jar --nogui

  echo
  echo
  echo
  echo

  echo "Restarting server in $REBOOT_DELAY seconds... (hit ^C then ^D to abort)"

  sleep $REBOOT_DELAY
done
