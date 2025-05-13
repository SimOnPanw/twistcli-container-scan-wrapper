#!/bin/bash
# Script to scan a container image using Twistcli

# Define Prisma Cloud URL
PRISMA_CLOUD_URL="https://api2.eu.prismacloud.io"

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

# Step 3: Use the CWP token with twistcli
echo "Scanning container image: $CONTAINER_IMAGE"

# Execute twistcli scan with the CWP token
twistcli images scan --address="$COMPUTE_URL" --token="$CWP_TOKEN" --details $CONTAINER_IMAGE
