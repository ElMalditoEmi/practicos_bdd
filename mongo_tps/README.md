# ?
El script simplemente levanta un container con
la imagen de mongo. Los datos se persisten en
volumenes locales de docker. Esto quiere decir
que al lanzar el contenedor se persisten
todos los datos, mientras se este usando
la misma computadora.

# ¿Que hace cada script?
### `alzar.sh`
Pone el contenedor a correr y muestra la info para
poder conectarse manualmente, si ya estaba corriendo, no hace nada.
### `tirar.sh`
Detiene el contenedor, sin eliminar los datos
que existen dentro de el. Si no estaba corriendo, no hace nada.
### `mongosh.sh`
Inicia una consola de mongoDB dentro del contenedor.
### `restore.sh`
Restaura/carga una base de datos a partir de un directorio que contenga
los `bson.gz` de un dump de la base de datos.
### `dump.sh`
Hace un dump de la base de datos en un directorio que se le pase
### `olvidar.sh`
Detiene el contenedor, y elimina los volumenes locales de datos que existen.
Si no estaba corriendo, elimina los datos del contenedor.