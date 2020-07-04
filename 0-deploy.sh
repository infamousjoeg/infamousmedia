#!/bin/bash
#
# Deploys all media automation and prepares environment
set -eou pipefail

# Verify environment variables set
if [[ 
    -z "$TIME_ZONE" ||
    -z "$PLEX_CLAIM_TOKEN" ||
    -z "$AUTOMATION_UID" ||
    -z "$AUTOMATION_GID" ||
    -z "$PLEX_ALLOWED_NETWORKS" ||
    -z "$ADVERTISE_IP"
]]; then
    echo "Please run this script using Summon:"
    echo -e "\t$ summon -p ring.py bash -s 0-deploy.sh\n"
    exit 1
fi

# Question #1
PS3='Have you modified nginx.conf? '  
options=("[Y]es" "[N]o" "[Q]uit")  
select opt in "${options[@]}"  
do  
    case $opt in
        "Y")
            echo "nginx.conf confirmed as modified.  Continuing..."
            ;;
        "N")
            echo -e "\nPlease modify nginx.conf first.\n"
            exit 1
            ;;
        "Q")
            exit 1
            ;;
        *) echo invalid option;;
    esac
done

echo -e "\n==> Checking for Docker...\n"

if [[ -z "$(command -v docker)" ]]; then
    echo "Docker is installed."
else
    echo "Docker not found.  Installing..."
    curl -fsSL get.docker.com | sh
    sudo usermod -aG docker $USER 
    newgrp docker
fi

echo -e "\n==> Checking for Docker-Compose...\n"

if [[ -z "$(command -v docker-compose)" ]]; then
    echo "Docker-Compose is installed."
else
    echo "Docker-Compose not found.  Installing..."
    sudo curl -L https://github.com/docker/compose/releases/download/1.26.1/docker-compose-"$(uname -s)"-"$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

echo -e "\n==> Bringing up containers using Docker-Compose...\n"

docker-compose up -d

echo -e "\n==> Copying NGINX configuration...\n"

docker cp ./nginx/nginx.conf /etc/nginx/nginx.conf

echo -e "\n==> Restarting NGINX container...\n"

docker restart nginx

until $(docker inspect --format='{{.State.Status}}' nginx) == 'running'
do
    echo "Waiting for NGINX to restart..."
    sleep 0.5
done

echo -e "\n==> All containers deployed successfully!\n"