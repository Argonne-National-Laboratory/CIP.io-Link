folder_path=./node-red
if [ ! -d "$folder_path" ]; then
  mkdir -p "$folder_path"
  echo "Folder '$folder_path' created."
fi

if [ ! -d "${folder_path}/assets" ]; then
  mkdir -p "${folder_path}/assets"
  echo "Folder '${folder_path}/assets' created."
fi

echo "Updating ownership of $folder_path..."
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
