#! /bin/bash
check_app_ready() {
  response=$(curl -s http://localhost:8086/api/v2/setup)
  echo "$response" | grep -q '"allowed": true'
}

# Function to check if jq is installed
check_jq_installed() {
  if ! command -v jq &>/dev/null; then
    echo "jq is not installed. Installing jq..."
    sudo apt update
    sudo apt install -y jq
  else
    echo "jq command is available."
  fi
}

# Check if jq is installed and install if necessary
check_jq_installed

export INFLUX_DESC=cipio$(date +'%y%m%d%H%M')
export INFLUX_ORG=cipio

# Start up the influx container
docker compose up influx2 -d

# Loop until the app is ready
while ! check_app_ready; do
  echo "Waiting for the influx to be ready..."
  sleep 5
done

# setup an initial user, org, and bucket
docker exec influx2 influx setup --username cipio --password cipio.lnk --org cipio --bucket ocpp_log --force

# going to sleep for a period of time since we don't know how to tell when setup is ready
#
# Initialize status code to a non-zero value
status=1

# Loop until the status code is 0 (indicating success)
while [ $status -ne 0 ]; do
  # Execute the command
  docker exec influx2 cat /etc/influxdb2/influx-configs >/dev/null 2>&1

  # Capture the status code of the command
  status=$?

  # Check if the command succeeded
  if [ $status -ne 0 ]; then
    echo "Command failed. Retrying..."
    sleep 5 # Wait for 5 seconds before retrying
  fi
done

# Continue with the rest of your script

# Capture the default operator token so we can do further setup
export INFLUX_TOKEN=$(docker exec influx2 cat /etc/influxdb2/influx-configs | grep -A 3 -B 3 cipio | grep token | awk -F\" '{print $2}')

# setup another couple of buckets
docker exec influx2 influx bucket create --name OCPP --retention 52w
docker exec influx2 influx bucket create --name meters --retention 52w

# List the buckets just for debugging purposes. This isn't necessary
docker exec influx2 influx bucket list

# Create an all access token that can be used by Node-Red
docker exec influx2 influx auth create --all-access -d $INFLUX_DESC >/dev/null 2>&1

# Save that token to our .env file so that it can be used by Node-Red or other CIPIO Link  containers
export INFLUX_TOKEN=$(docker exec influx2 influx auth list --json | jq -r --arg desc "$INFLUX_DESC" '.[] | select(.description == $desc) | .token')
echo $INFLUX_TOKEN
# Check if the .env file exists, if not create it
if [ ! -f .env ]; then
  touch .env
fi

# Update the INFLUX_TOKEN in the .env file or add it if it doesn't exist
if grep -q "INFLUX_TOKEN=" .env; then
  # If INFLUX_TOKEN exists, replace its value
  sed -i "s/^INFLUX_TOKEN=.*/INFLUX_TOKEN=$INFLUX_TOKEN/" .env
else
  # If INFLUX_TOKEN does not exist, append it to the file
  echo "INFLUX_TOKEN=$INFLUX_TOKEN" >>.env
fi
