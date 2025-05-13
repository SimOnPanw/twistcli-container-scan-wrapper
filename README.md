# Prisma Cloud Container Scan Script (`scan_container.sh`)

This script automates the process of scanning container images using Prisma Cloud Compute (`twistcli`). It handles the necessary authentication steps and then executes the `twistcli images scan` command.

## Overview

The script performs the following actions:

1.  **Authenticates with Prisma Cloud:**
    *   Retrieves a JSON Web Token (JWT) from the main Prisma Cloud API using the provided username and password.
    *   Uses this JWT to fetch metadata, including the specific Compute URL (`twistlockUrl`) for your environment.
2.  **Obtains a CWP Token:**
    *   Requests a Compute-specific (CWP) token using the JWT and the obtained Compute URL.
3.  **Scans the Container Image:**
    *   Executes `twistcli images scan` using the CWP token and the Compute URL, targeting the container image specified by the user.

## Prerequisites

Before running this script, ensure you have the following:

1.  **`curl`**: A command-line tool for transferring data with URLs.
2.  **`jq`**: A command-line JSON processor.
3.  **`twistcli`**: The Prisma Cloud Compute command-line interface. The script assumes `twistcli` is in your system's PATH or in the same directory as the script.
4.  **Prisma Cloud Credentials**: You need to set your Prisma Cloud username and password as environment variables:
    ```bash
    export PRISMA_CLOUD_USERNAME="your_prisma_username"
    export PRISMA_CLOUD_PASSWORD="your_prisma_password"
    ```
    Replace `"your_prisma_username"` and `"your_prisma_password"` with your actual credentials.

## Usage

1.  **Make the script executable:**
    ```bash
    chmod +x scan_container.sh
    ```

2.  **Run the script:**
    Execute the script from your terminal, providing the full name of the container image you want to scan as a command-line argument.

    **Syntax:**
    ```bash
    ./scan_container.sh <IMAGE_NAME>
    ```

    **Example:**
    ```bash
    ./scan_container.sh your-registry/your-image:latest
    ```
    Or to scan a public image like `nginx`:
    ```bash
    ./scan_container.sh nginx:alpine
    ```

The script will output status messages for each step (token acquisition, URL retrieval) and then display the results of the `twistcli` scan.

## Script Variables

*   `PRISMA_CLOUD_URL`: The base URL for the Prisma Cloud API. Defaults to `https://api2.eu.prismacloud.io`.
*   `PRISMA_CLOUD_USERNAME`: Your Prisma Cloud username (must be set as an environment variable).
*   `PRISMA_CLOUD_PASSWORD`: Your Prisma Cloud password (must be set as an environment variable).
*   `CONTAINER_IMAGE`: The container image to scan (taken from the first command-line argument).

## Error Handling

The script includes basic error handling:
*   It will exit if no container image is specified as an argument.
*   It will exit if it fails to obtain the JWT token (e.g., due to incorrect credentials).
*   It will exit if it fails to retrieve the Compute URL from the `meta_info` endpoint.
*   It will exit if it fails to obtain the CWP-specific token.
Error messages will be printed to standard output.
