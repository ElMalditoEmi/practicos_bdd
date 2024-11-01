#!/bin/bash
# Import environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | xargs)
else 
    echo "El archivo .env no existe, y es totalmente necesario para este script."
    exit 1
fi

# Check if the directory argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <output_directory>"
  exit 1
fi

OUTPUT_DIR=$1

# Set default output directory if empty
if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR="dump"
fi

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Run mongodump inside the MongoDB container with authentication
docker exec ${CONTAINER_NAME} sh -c \
                        "exec mongodump \
                            -u ${DB_USER} \
                            -p ${DB_PASS} \
                            --authenticationDatabase ${DB_AUTH}"

docker cp ${CONTAINER_NAME}:/dump/. $OUTPUT_DIR


# Check if the dump was successful
if [ $? -eq 0 ]; then
  echo "Database dump successful. Saved to $OUTPUT_DIR/dump.archive"
else
  echo "Database dump failed."
  exit 1
fi