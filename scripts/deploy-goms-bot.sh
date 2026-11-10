#!/bin/bash
set -e

cd /home/ubuntu/GOMS-Bot-V1

git fetch origin
git checkout main
git pull origin main

docker compose down
docker compose up -d --build

docker compose ps
