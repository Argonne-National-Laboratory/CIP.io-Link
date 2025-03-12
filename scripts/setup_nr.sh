#!/bin/bash

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/utils.sh"

echo -e "${GREEN}********************************************${NC}"
echo -e "${GREEN}* ${CYAN}Starting Node-Red setup...   ${GREEN}            *${NC}"
echo -e "${GREEN}********************************************${NC}"

folder_path=./node-red
if [ ! -d "$folder_path" ]; then
  mkdir -p "$folder_path"
  echo -e "${GREEN}Folder '$folder_path' created.${NC}"
fi

if [ ! -d "${folder_path}/assets" ]; then
  mkdir -p "${folder_path}/assets"
  echo "Folder '${folder_path}/assets' created."
fi

echo -e "${GREEN}Updating ownership of $folder_path...${NC}"
sudo docker stop node-red >/dev/null 2>&1
sleep 5
sudo chown -R ${USER}:${USER} $folder_path

cp -r ./build/nr/folders/* $folder_path
cp ./build/nr/settings.js $folder_path
# cp ./build/nr/flow* $folder_path
# cp ./build/nr/assets/* ${folder_path}/assets

# echo "Restarting node-red container..."

sudo chown -R ${USER}:${USER} $folder_path
sudo docker restart node-red >/dev/null 2>&1
