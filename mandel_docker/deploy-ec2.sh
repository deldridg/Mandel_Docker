#!/bin/bash

# Variables (edit these)
EC2_IP="54.235.232.125"
KEY_PATH="C:/System/AWS/key_pairs/mandel-ec2-key.pem"  # Adjust path
IMAGE_NAME="mandeldocker:latest"

# SSH and execute commands
ssh -i "$KEY_PATH" ubuntu@$EC2_IP << EOF
  # Navigate to project dir (create if missing)
  if [ ! -d "mandel_docker" ]; then
    git clone https://github.com/your-username/mandel-docker.git
  fi
  cd mandel_docker/mandel_docker

  # Pull latest code
  echo "Pulling latest code from GitHub..."
  git pull origin main

  # Build Docker image
  echo "Building Docker image..."
  docker build -t $IMAGE_NAME .

  # Run new container
  echo "Starting new container..."
  docker run -d -p 8000:8000 $IMAGE_NAME

  # Show running containers
  echo "Running containers:"
  docker ps
EOF

echo "Deployment complete! Check http://$EC2_IP:8000/"