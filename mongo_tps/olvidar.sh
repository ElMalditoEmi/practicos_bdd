#!/bin/bash

if [ -f .env ]; then # Cargar variables de entorno
    export $(cat .env | xargs)
else 
    echo "El archivo .env no existe, y es totalmente necesario para este script."
    exit 1
fi

# Mensaje de confirmación
read -p "¿Estás seguro de que quieres bajar el container y perder la BDD? (s/n): " respuesta

# Convertir la respuesta a minúsculas
respuesta=${respuesta,,}

if [[ "$respuesta" == "s" ]]; then
    echo "Ejecutando 'docker rm -fv ${CONTAINER_NAME}'..."
    docker rm -fv ${CONTAINER_NAME}
else
    echo "Operación cancelada."
fi