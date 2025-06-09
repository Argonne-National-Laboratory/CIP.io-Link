#!/usr/bin/env bash

##################################################################################
# Copyright © 2025, UChicago Argonne, LLC
# All Rights Reserved
#
# Software Name: CIPio Link
# By: Argonne National Laboratory
#
# OPEN SOURCE LICENSE (MIT)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# •	The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
##################################################################################

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/utils.sh"

banner_lvl2 "Starting Node-Red setup..."

folder_path=./node-red
if [ ! -d "$folder_path" ]; then
  mkdir -p "$folder_path"
  print_action "${GREEN}Folder '$folder_path' created.${NC}"
fi

if [ ! -d "${folder_path}/assets" ]; then
  mkdir -p "${folder_path}/assets"
  print_action "Folder '${folder_path}/assets' created."
fi

print_action "${GREEN}Updating ownership of $folder_path...${NC}"
sudo docker stop node-red >/dev/null 2>&1
sleep 5
sudo chown -R ${USER}:${USER} $folder_path

cp -r ./build/nr/folders/* $folder_path
cp ./build/nr/settings.js $folder_path
# cp ./build/nr/flow* $folder_path
# cp ./build/nr/assets/* ${folder_path}/assets

# echo "Restarting node-red container..."

# sudo chown -R ${USER}:${USER} $folder_path
sudo chown -R 1000:1000 $folder_path
sudo docker restart node-red >/dev/null 2>&1
