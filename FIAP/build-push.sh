#!/bin/bash

# Build and push Docker images to ECR

# Set variables
ACCOUNT_ID=123456789012
REGION=us-east-1
REPO_PREFIX=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Authenticate Docker to ECR
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Build and push auth-service
cd auth-service
docker build -t $REPO_PREFIX/auth-service:latest .
docker push $REPO_PREFIX/auth-service:latest
cd ..

# Build and push flag-service
cd flag-service
docker build -t $REPO_PREFIX/flag-service:latest .
docker push $REPO_PREFIX/flag-service:latest
cd ..

# Build and push targeting-service
cd targeting-service
docker build -t $REPO_PREFIX/targeting-service:latest .
docker push $REPO_PREFIX/targeting-service:latest
cd ..

# Build and push evaluation-service
cd evaluation-service
docker build -t $REPO_PREFIX/evaluation-service:latest .
docker push $REPO_PREFIX/evaluation-service:latest
cd ..

# Build and push analytics-service
cd analytics-service
docker build -t $REPO_PREFIX/analytics-service:latest .
docker push $REPO_PREFIX/analytics-service:latest
cd ..

echo "All images built and pushed to ECR!"