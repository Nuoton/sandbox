#!/bin/bash
set -e
cd "$(dirname "$0")"
sudo docker compose down || true
sudo docker compose up -d