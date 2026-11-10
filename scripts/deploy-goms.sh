#!/bin/bash
set -e

cd /home/ubuntu/GOMS-Backend-V3
git fetch origin
git checkout main
git pull origin main
docker compose build app
docker compose up -d --no-deps app
docker image prune -f
docker compose ps

