#!/bin/bash
set -e

# Usage: ./deploy.sh <branch_name>
BRANCH=${1:-dev}  # default to dev if no argument

DEV_IMAGE="your-dockerhub-username/dev:$BRANCH"
PROD_IMAGE="your-dockerhub-username/prod:$BRANCH"

# Stop previous container
echo "Stopping old container if exists..."
docker-compose down || true

# Update docker-compose.yml dynamically
if [ "$BRANCH" == "dev" ]; then
    sed -i "s|image: .*|image: $DEV_IMAGE|" docker-compose.yml
elif [ "$BRANCH" == "master" ]; then
    sed -i "s|image: .*|image: $PROD_IMAGE|" docker-compose.yml
fi

# Start container
echo "Starting container..."
docker-compose up -d

echo "Deployment completed for branch $BRANCH!"