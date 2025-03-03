folder_path=./node-red
if [ ! -d "$folder_path" ]; then
  mkdir -p "$folder_path"
  echo "Folder '$folder_path' created."
fi

echo "Updating ownership of $folder_path..."
sudo docker stop node-red >/dev/null 2>&1
sudo chown -R ${USER}:${USER} $folder_path

cp ./build/nr/settings.js $folder_path
cp ./build/nr/flow* $folder_path

echo "Restarting node-red container..."
sudo docker restart node-red
