#!/bin/bash

if [ -f .env ]; then # Cargar variables de entorno
    export $(cat .env | xargs)
else 
    echo "El archivo .env no existe, y es totalmente necesario para este script."
    exit 1
fi

print_separator(){
    echo ""
    echo "-------------------------------------------------"
    echo ""
}

docker_is_installed(){
    if which docker; then
        echo "Docker esta instalado"
        return 0
    else
        echo "Docker no esta instalado"
        return 1
    fi
}

get_info(){
    echo "Username: ${DB_USER}"
    echo "Password: ${DB_PASS}"
    echo "Esta es tu ip:"
    docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${CONTAINER_NAME}
}

theres_previous_container(){
    # Start a running or stopped container 
    if(docker ps -a | grep ${CONTAINER_NAME}); then
       docker start $(docker ps -a | grep ${CONTAINER_NAME} | cut --delimiter=' ' -f 1)
       return 0;
    else 
        return 1;
    fi
}


# ENTRY POINT
if !(docker_is_installed); then
    echo Instalar docker para poder continuar...
    exit 1
fi

print_separator

if (theres_previous_container); then
    echo "Se encontro una instancia anterior de la imagen, ahora está corriendo"
    get_info
    exit 0
fi

# Correr la imagen del contenedor
docker run -d --name ${CONTAINER_NAME} \
        -e MONGO_INITDB_ROOT_USERNAME=${DB_USER} \
        -e MONGO_INITDB_ROOT_PASSWORD=${DB_PASS} \
        -p 27017:27017 \
        -v ${VOLUME_NAME}:/data/db \
        -v ${VOLUME_NAME}:/data/configdb \
        -v ${VOLUME_NAME}:/to-be-restored \
        mongo

print_separator

if [ "$?" -eq 0 ]; then
    echo "Container corriendo"
else
    echo "Hubo un error al correr el container"
    exit 1
fi

print_separator

get_info

echo ""
echo "Para detener el container usa 'docker stop ${CONTAINER_NAME}'"
echo
echo "Para iniciar el container usa este mismo script o 'docker start ${CONTAINER_NAME}'"
echo
echo "Cuando necesites saber si esta o no 'running' tu container usa 'docker ps -a'"
echo 
echo "Por si necesitas algo tan extremo como borrar le contenedor y revertir \
todo usa 'docker rm -f ${CONTAINER_NAME} (WARNING: Si habia datos en tu server o un esquema vas a perderlo)"

sleep 1