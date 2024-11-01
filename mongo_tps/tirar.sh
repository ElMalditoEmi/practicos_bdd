if [ -f .env ]; then # Cargar variables de entorno
    export $(cat .env | xargs)
else 
    echo "El archivo .env no existe, y es totalmente necesario para este script."
    exit 1
fi



echo "Deteniendo el container '${CONTAINER_NAME}'..."
docker stop ${CONTAINER_NAME}
