#!/bin/bash

# Assign command-line arguments to variables
branch_name="$1"
image_name="$2"
database_name="$3"
database_location="$4"
container_name="$5"
ports="$6"

# Set default ports if they are null or empty
if [ -z "$ports" ]; then
    ports="1433:1433"
fi

# Check if the Docker image exists
if ! docker image inspect mssql-2022-custom &> /dev/null; then
    echo "Docker image 'mssql-2022-custom' does not exist. Building the image..."
    docker build -t mssql-2022-custom .
fi

# Check if the container exists
if [ -z "$container_name" ]; then
    docker run -d \
        -e BACKUP_FILENAME="$database_name" \
        -v "$database_location":/var/opt/mssql/backup \
        -e 'ACCEPT_EULA=Y' \
        -e 'SA_PASSWORD=NotThePa55word!' \
        -p "$ports" \
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
# ./startup.sh main mssql-2022-custom JE_Empty_20231 /Users/glotz/Documents/mssql/backup mssql-2022-custom-empty 1433:1433