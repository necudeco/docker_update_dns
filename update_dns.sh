#!/bin/bash

# Función para actualizar el archivo /etc/hosts
update_hosts_file() {
    local ip_address=$1
    local hostname=$2
    local hosts_file="/etc/hosts"

    if [ -z "$ip_address" ] || [ -z "$hostname" ]; then
        echo "Uso: update_hosts_file <IP_ADDRESS> <HOSTNAME>"
        return 1
    fi

    # Verificar si la entrada ya existe
    if grep -q "$hostname" "$hosts_file"; then
        echo "Actualizando la entrada existente para $hostname en $hosts_file"
        # Reemplazar la entrada existente
        sudo sed -i "/$hostname/c\\$ip_address\t$hostname" "$hosts_file"
    else
        echo "Añadiendo nueva entrada $hostname con IP $ip_address en $hosts_file"
        # Añadir nueva entrada
        echo -e "$ip_address\t$hostname" | sudo tee -a "$hosts_file" > /dev/null
    fi
}

# Función para manejar el evento de creación de contenedor
handle_container_creation() {
    local container_id=$1
    local container_name=$(docker inspect --format '{{.Name}}' "$container_id" | sed 's/\///')
    local image_name=$(docker inspect --format '{{.Config.Image}}' "$container_id")
    local container_ip=$(docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_id")

    echo "Nuevo contenedor creado:"
    echo "ID del Contenedor: $container_id"
    echo "Nombre del Contenedor: $container_name"
    echo "Imagen del Contenedor: $image_name"
    echo "IP del Contenedor: $container_ip"
    echo "------------------------------------"

    # Llamar a la función update_hosts_file
    update_hosts_file "$container_ip" "$container_name"
}

# Monitorear eventos de Docker
docker events --filter 'event=create' --format '{{json .}}' | while read event
do
    container_id=$(echo $event | jq -r '.id')
    handle_container_creation $container_id
done
