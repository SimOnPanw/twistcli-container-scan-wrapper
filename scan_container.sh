#!/bin/bash
# Script to scan a container image using Twistcli

if [ -z "$1" ]; then
  echo "Error: No container image specified as argument."
  exit 1
fi
CONTAINER_IMAGE="$1"

# Step 1: Get the JWT token from the general Prisma login API
JWT_TOKEN=$(curl --silent --location "$PRISMA_CLOUD_URL/login" \
  --header 'Content-Type: application/json' \
  --data-raw "{\"username\":\"$PRISMA_CLOUD_USERNAME\", \"password\":\"$PRISMA_CLOUD_PASSWORD\"}" \
  | jq -r .token)

if [ -z "$JWT_TOKEN" ] || [ "$JWT_TOKEN" == "null" ]; then
  echo "Error: Failed to obtain JWT token. Check your credentials."
  exit 1
fi

echo "JWT token obtained successfully."

# Get the Compute URL from meta_info endpoint
COMPUTE_URL=$(curl --silent --location "$PRISMA_CLOUD_URL/meta_info" \
  --header "x-redlock-auth: $JWT_TOKEN" \
  | jq -r .twistlockUrl)

if [ -z "$COMPUTE_URL" ] || [ "$COMPUTE_URL" == "null" ]; then
  echo "Error: Failed to obtain Compute URL from meta_info."
  exit 1
fi

echo "Compute URL obtained: $COMPUTE_URL"

# Step 2: Get the CWP-specific token using the JWT token
CWP_TOKEN=$(curl --silent --location "$COMPUTE_URL/api/v1/current/token" \
  --header "x-redlock-auth: $JWT_TOKEN" \
  | jq -r .token)

if [ -z "$CWP_TOKEN" ] || [ "$CWP_TOKEN" == "null" ]; then
  echo "Error: Failed to obtain CWP token."
  exit 1
fi

echo "CWP token obtained successfully."

# Check if twistcli exists, if not download it
if [ ! -f "./twistcli" ]; then
  echo "twistcli not found in current directory, downloading..."
  
  # Download twistcli
  echo "Downloading twistcli from $COMPUTE_URL..."
  curl -s -k --header "authorization: Bearer $CWP_TOKEN" \
    "$COMPUTE_URL/api/v1/util/twistcli" -o twistcli
  
  if [ $? -ne 0 ]; then
    echo "Failed to download twistcli"
    exit 1
  fi
  
  # Make executable
  chmod a+x twistcli
  echo "twistcli downloaded successfully"
fi

# Step 3: Use the CWP token with twistcli
echo "Scanning container image: $CONTAINER_IMAGE"

# Execute twistcli scan with the CWP token
./twistcli images scan --address="$COMPUTE_URL" --token="$CWP_TOKEN" --details $CONTAINER_IMAGE
