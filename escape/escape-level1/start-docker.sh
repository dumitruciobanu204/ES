#!/bin/bash

# Stop and remove existing container
podman stop secure-ssh-container 2>/dev/null
podman rm secure-ssh-container 2>/dev/null

# Start with just the basics
podman run -d \
  --name secure-ssh-container \
  --publish 0.0.0.0:2222:2222 \
  --security-opt=no-new-privileges \
  --memory=512m \
  --cpus=1.0 \
  localhost/secure-ssh

echo "lvl 1 container started on port 2222"
