#!/bin/bash

# Variables
EC2_IP="54.235.232.125"
KEY_PATH="C:\System\AWS\Key_Pairs\mandel-ec2-key.pem"
IMAGE_NAME="mandeldocker:latest"

# SSH and execute commands
ssh -i "$KEY_PATH" ubuntu@$EC2_IP << EOF
    # Nav to project dir (create if missing)
    if [ ! -d "mandel_docker" ]; then
        git clone https://github.com/deldridg/mandel_docker.git
    fi
    cd mandel_docker/mandel_docker

    # Pull latest code
    git pull origin main

    # Build docker image
    docker build -t $IMAGE_NAME .

    # Stop and remove any running container
    echo "Stopping and removing existing containers..."
    RUNNING_CONTAINERS=$(docker ps -q --filter ancestor=$IMAGE_NAME)
    if [ -n "$RUNNING_CONTAINERS" ]; then
        echo "Stopping containers: $RUNNING_CONTAINERS"
        docker stop $RUNNING_CONTAINERS
    fi

    # Remove all containers (running or stopped) with this image
    ALL_CONTAINERS=$(docker ps -aq --filter ancestor=$IMAGE_NAME)
    if [ -n "$ALL_CONTAINERS" ]; then
        echo "Removing containers: $ALL_CONTAINERS"
        docker rm -f $ALL_CONTAINERS
    fi

    # Check if port 8000 is still in use
    if sudo lsof -i :8000 > /dev/null 2>&1; then
        echo "Port 8000 is in use, attempting to free it..."
        sudo lsof -i :8000 | awk 'NR>1 {print $2}' | xargs -r sudo kill -9
    fi

    # Run new container
    echo "Starting new container..."
    docker run -d -p 8000:8000 $IMAGE_NAME

    # Show running containers
    docker ps
EOF

echo "Deployment complete! Check http://$EC2_IP:8000/"