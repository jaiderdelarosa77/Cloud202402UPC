#!/bin/bash

# Actualizar paquetes
sudo yum update

# Instalar Docker
sudo yum install -y docker

# Iniciar el servicio de Docker
sudo systemctl start docker.service

# Descargar la imagen de Nginx
sudo docker pull nginx:latest

# Ejecutar un contenedor de Nginx
sudo docker run -d -p 80:80 --name nginx1 nginx

# Modificar el archivo index.html dentro del contenedor
sudo docker exec nginx1 sh -c 'echo "<h1>Welcome to nginx!</h1>" > /usr/share/nginx/html/index.html'

# Cambiar el contenido de <h1> en el archivo HTML
sudo docker exec nginx1 sh -c 'sed -i "s/<h1>Welcome to nginx!/<h1>Welcome to nginx1!/g" /usr/share/nginx/html/index.html'
