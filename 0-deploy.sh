#!/bin/bash
#
# Deploys all media automation and prepares environment
set -eou pipefail

# Question #1
PS3='Have you modified bootstrap.env? '  
options=("[Y]es" "[N]o" "[Q]uit")  
select opt in "${options[@]}"  
do  
    case $opt in
        "Y")
            # shellcheck source=/dev/null
            source ./bootstrap.env; 
            echo; echo "Bootstrapped Environment Variables"; echo
            ;;
        "N")
            echo; echo "Please modify bootstrap.env first."; echo
            break
            ;;
        "Q")
            break
            ;;
        *) echo invalid option;;
    esac
done

# Question #2
PS3='Have you modified nginx.conf? '  
options=("[Y]es" "[N]o" "[Q]uit")  
select opt in "${options[@]}"  
do  
    case $opt in
        "Y")
            echo "nginx.conf confirmed as modified.  Continuing..."
            ;;
        "N")
            echo; echo "Please modify nginx.conf first."; echo
            break
            ;;
        "Q")
            break
            ;;
        *) echo invalid option;;
    esac
done

echo; echo "Checking for Docker..."; echo

if command -v docker > /dev/null ; then
    echo "Docker is installed."; echo
else
    echo "Docker not found.  Installing..."; echo
    curl -fsSL get.docker.com | sh
    sudo usermod -aG docker $USER 
    newgrp docker
fi

echo; echo "Checking for Docker-Compose..."; echo

if command -v docker-compose > /dev/null ; then
    echo "Docker-Compose is installed."; echo
else
    echo "Docker-Compose not found.  Installing..."; echo
    sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-"$(uname -s)"-"$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

echo; echo "Bringing up containers using Docker-Compose..."

docker-compose up -d

echo; echo "Copying NGINX configuration..."; echo

cp ./nginx.conf /opt/nginx/nginx/nginx.conf

echo; echo "Restarting NGINX container..."; echo

docker restart nginx

until $(docker inspect --format='{{.State.Status}}' nginx) == 'running'
do
    echo "Waiting for NGINX to restart..."
    sleep 0.5
done

echo; echo "All containers deployed successfully!"; echo