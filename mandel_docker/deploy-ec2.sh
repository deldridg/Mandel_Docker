#!/bin/bash

# Variables
EC2_IP = "54.235.232.125"
KEY_PATH = "C:\System\AWS\Key_Pairs\mandel-ec2-key.pem"
IMAGE_NAME = "mandeldocker:latest"

# SSH and execute commands
ssh -i "$KEY_PATH" ubuntu@$EC2_IP << 'EOF'
    # Nav to project dir (create if missing)
    if [ ! -d "mandel_docker" ]; then
        git clone https://github.com/deldridg/mandel_docker.git
    fi
    cd mandel_docker

    # Pull latest code
    git pull origin main

    # Build docker image
    docker build -t $IMAGE_NAME

    # Stop and remove any running container
    docker stop $(docker ps -q --filter ancestor=$IMAGE_NAME) 2>/dev/null || true
    docker rm $(docker ps -aq --filter ancestor=$IMAGE_NAME) 2>/dev/null || true

    # Run new container
    docker run -d -p 8000:8000 $IMAGE_NAME

    # Show running containers
    docker ps
EOF

echo "Deployment complete! Check http://$EC2_IP:8000/"