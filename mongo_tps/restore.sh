if [ -f .env ]; then
    export $(cat .env | xargs)
else 
    echo "El archivo .env no existe, y es totalmente necesario para este script."
    exit 1
fi

#Copiar el archivo del dump al contenedor
if [ -z "$1" ]; then
    echo "Por favor, proporcione la ruta del archivo de dump como argumento."
    exit 1
fi

# Extraer el nombre del directorio del path proporcionado
DIR_NAME=$(basename "$1")

docker cp "$1" ${CONTAINER_NAME}:/to-be-restored

# Ejecutar mongorestore en el contenedor
docker exec -it ${CONTAINER_NAME} mongorestore -h 127.0.0.1 --drop --gzip --db $DIR_NAME /to-be-restored/$DIR_NAME -u ${DB_USER} -p ${DB_PASS} --authenticationDatabase ${DB_AUTH}

# Comprobar si la restauración fue exitosa
if [ $? -eq 0 ]; then
    echo "Restauración completada con éxito."
else
    echo "Hubo un error durante la restauración."
fi


