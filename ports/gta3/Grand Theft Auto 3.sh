#!/bin/bash
# PORTMASTER: gta3.zip, Grand Theft Auto 3.sh
# Built from https://github.com/nosro1/re3 (branch sdl2)

PORTNAME="Grand Theft Auto 3"

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
get_controls

CUR_TTY=/dev/tty0
$ESUDO chmod 666 $CUR_TTY

GAMEDIR="/$directory/ports/gta3"

if [[ ! -d "$GAMEDIR/data" ]]; then
  echo "Missing game files. Copy original game files to roms/ports/gta3." > $CUR_TTY
  sleep 5
  $ESUDO systemctl restart oga_events &
  printf "\033c" >> $CUR_TTY
  exit 1
fi

# Check if re3 project files are already installed
# (needs to be done after the game files are copied, since it overwrites certain files)
if [[ -d "$GAMEDIR/re3-data" ]]; then
  echo "Installing re3 files..." > $CUR_TTY
  cp -rf "$GAMEDIR/re3-data"/* "$GAMEDIR" && rm -rf "$GAMEDIR/re3-data"
fi

cd "$GAMEDIR"
$ESUDO chmod 666 /dev/uinput
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs":$LD_LIBRARY_PATH
$GPTOKEYB "re3" &
./re3 2>&1 | tee log.txt

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> $CUR_TTY
