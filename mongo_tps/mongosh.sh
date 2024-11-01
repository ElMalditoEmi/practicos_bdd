# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | xargs)
else 
    echo "El archivo .env no existe, y es totalmente necesario para este script."
    exit 1
fi

if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
    docker exec -it ${CONTAINER_NAME} mongosh -u ${DB_USER} -p ${DB_PASS} --authenticationDatabase ${DB_AUTH}
else
	echo "Container '${CONTAINER_NAME}' is not running."
fi