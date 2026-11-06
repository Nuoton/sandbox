#!/bin/bash
set -e

# === Настройки Nexus ===
NEXUS_URL="http://93.77.166.24:8081"
NEXUS_USER="student"
NEXUS_PASS="1iRd|OjBGq9V"
VERSION="latest"
REPO_BACKEND="skorokhodov-backend"
REPO_FRONTEND="skorokhodov-frontend"

echo "Скач"
curl -u "${NEXUS_USER}:${NEXUS_PASS}" -o backend.tar "${NEXUS_URL}/repository/${REPO_BACKEND}/docker/${VERSION}/backend.tar"
curl -u "${NEXUS_USER}:${NEXUS_PASS}" -o frontend.tar "${NEXUS_URL}/repository/${REPO_FRONTEND}/docker/${VERSION}/frontend.tar"

echo "загрузка"
sudo docker load -i backend.tar
sudo docker load -i frontend.tar

echo "запуск"
# Убедимся, что мы в папке со скриптом (где лежит docker-compose.yml)
cd "$(dirname "$0")"
sudo docker compose down || true
sudo docker compose up -d

echo "Готово"