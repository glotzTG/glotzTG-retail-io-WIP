#!/bin/bash

# Assign command-line arguments to variables
branch_name="$1"
database_name="$2"
database_location="$3"
container_name="$4"
ports="$5"

# Set default ports if they are null or empty
if [ -z "$ports" ]; then
    ports="1433:1433"
fi

# Check if the database folder exists, if not, prompt the user to create it
if [ -z "$database_location" ]; then
    database_location="./database"
    echo "Database location not provided. Creating 'database' folder in the current directory..."
    mkdir -p "$database_location"
else
    if [ ! -d "$database_location" ]; then
        read -rp "Database folder '$database_location' does not exist. Do you want to create it? (Y/N): " create_folder
        if [[ "$create_folder" =~ ^[Yy]$ ]]; then
            mkdir -p "$database_location"
        else
            echo "Database folder creation skipped. Exiting..."
            exit 1
        fi
    fi
fi

# Check if the Docker image exists
if ! docker image inspect mssql-2022-custom &> /dev/null; then
    echo "Docker image 'mssql-2022-custom' does not exist. Building the image..."
    docker build -t mssql-2022-custom .
fi

# Check if the database exists in the specified location
if [ ! -f "$database_location/$database_name.bak" ]; then
    echo "Database '$database_name' does not exist. Downloading from Azure repository..."

    # Authenticate using Azure CLI and open a browser window for authentication
    #az login --use-device-code

    # Read the JSON file and extract the values using jq
    configFile="./config.json"
    accountName=$(jq -r '.accountName' "$configFile")
    accountKey=$(jq -r '.accountKey' "$configFile")
    databaseContainer=$(jq -r '.databaseContainer' "$configFile")

    # Print the extracted values
    echo "accountName: $accountName"
    echo "accountKey: $accountKey"
    echo "databaseContainer: $databaseContainer"

    # Download the database from Azure repository
    az storage blob download \
        --account-name $accountName \
        --account-key $accountKey \
        --container-name $databaseContainer \
        --name "$database_name.bak" \
        --file "$database_location/$database_name.bak"
fi
 
# Check if the container exists
if [ -z "$container_name" ]; then
    if docker ps -a --filter name="mssql-2022" | grep -q "mssql-2022"; then
        echo "Container mssql-2022 exists, stopping and deleting it..."
        # Stop and remove the Docker container
        docker stop mssql-2022 && docker rm mssql-2022
    fi
    docker run -d \
        -e BACKUP_FILENAME="$database_name" \
        -v "$database_location":/var/opt/mssql/backup \
        -e 'ACCEPT_EULA=Y' \
        -e 'SA_PASSWORD=NotThePa55word!' \
        -p "$ports" \
        --name mssql-2022 \
        mssql-2022-custom
else
    if docker ps -a --filter name="$container_name" | grep -q "$container_name"; then
        echo "Container $container_name exists, stopping and deleting it..."
        # Stop and remove the Docker container
        docker stop "$container_name" && docker rm "$container_name"
    fi
    docker run -d \
        -e BACKUP_FILENAME="$database_name" \
        -v "$database_location":/var/opt/mssql/backup \
        -e 'ACCEPT_EULA=Y' \
        -e 'SA_PASSWORD=NotThePa55word!' \
        -p "$ports" \
        --name "$container_name" \
        mssql-2022-custom
fi

# Example:
# 1: ./startup.sh main JE_Empty_20231 /Users/glotz/Documents/mssql/backup mssql-2022-custom-empty 1433:1433
# 2: ./startup.sh main JE_Empty_20231