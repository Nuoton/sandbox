#!/bin/bash
set -e

# === Настройки ===
VM_IP="153.51.118.157"
VM_USER="nuoton"
SSH_KEY="$HOME/.ssh/ssh-key-1793340107510"
REMOTE_DIR="/home/nuoton/app"

# === Настройки Nexus ===
NEXUS_URL="http://153.51.118.157:8081"
NEXUS_USER="student"
NEXUS_PASS="1iRd|OjBGq9V"
VERSION="latest"
REPO_BACKEND="skorokhodov-backend"
REPO_FRONTEND="skorokhodov-frontend"

echo "копир"
ssh -o IdentityAgent=none -i "$SSH_KEY" "$VM_USER@$VM_IP" "mkdir -p $REMOTE_DIR"
scp -o IdentityAgent=none -i "$SSH_KEY" docker-compose.yml .env "$VM_USER@$VM_IP:$REMOTE_DIR/"

echo " скачиваем образы из Nexus"
ssh -o IdentityAgent=none -i "$SSH_KEY" "$VM_USER@$VM_IP" << EOF
  cd $REMOTE_DIR
  
  echo "Скачиваем backend.tar из Nexus..."
  sudo curl -u "${NEXUS_USER}:${NEXUS_PASS}" -o backend.tar "${NEXUS_URL}/repository/${REPO_BACKEND}/docker/${VERSION}/backend.tar"
  
  echo "Скачиваем frontend.tar из Nexus..."
  sudo curl -u "${NEXUS_USER}:${NEXUS_PASS}" -o frontend.tar "${NEXUS_URL}/repository/${REPO_FRONTEND}/docker/${VERSION}/frontend.tar"
  
  echo "Загружаем образы в Docker..."
  sudo docker load -i backend.tar
  sudo docker load -i frontend.tar
  
  echo "Запускаем docker compose..."
  sudo docker compose down || true
  sudo docker compose up -d
  sudo docker compose ps
  
  echo "Удаляем временные архивы..."
  rm -f backend.tar frontend.tar
EOF

echo "готово"