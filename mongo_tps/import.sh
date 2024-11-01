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
COLLECTION_FILE=$(basename "$1")

DB_NAME=${COLLECTION_FILE%.json}

echo $COLLECTION_FILE

docker cp "$1" ${CONTAINER_NAME}:/to-be-restored/$COLLECTION_FILE

# Ejecutar mongorestore en el contenedor
docker exec -it ${CONTAINER_NAME} mongoimport -h 127.0.0.1 --drop --db $DB_NAME /to-be-restored/$COLLECTION_FILE -u ${DB_USER} -p ${DB_PASS} --authenticationDatabase ${DB_AUTH}

# Comprobar si la restauración fue exitosa
if [ $? -eq 0 ]; then
    echo "Restauración completada con éxito."
else
    echo "Hubo un error durante la restauración."
fi


