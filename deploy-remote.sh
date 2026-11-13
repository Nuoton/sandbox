#!/bin/bash
set -e

VM_IP="93.77.163.101"
VM_USER="nuoton"
SSH_KEY="$HOME/.ssh/ssh-key-1793340107510"
REMOTE_DIR="/home/nuoton/app"

echo "Сохраняем образы локально"
docker save sandbox-backend:latest -o backend.tar
docker save sandbox-frontend:latest -o frontend.tar

echo "Копируем файлы на сервер"
ssh -o IdentityAgent=none -i "$SSH_KEY" "$VM_USER@$VM_IP" "mkdir -p $REMOTE_DIR || true"
scp -o IdentityAgent=none -i "$SSH_KEY" docker-compose.yml .env backend.tar frontend.tar "$VM_USER@$VM_IP:$REMOTE_DIR/"

echo "Загружаем образы"
ssh -o IdentityAgent=none -i "$SSH_KEY" "$VM_USER@$VM_IP" << EOF
  cd $REMOTE_DIR
  sudo docker load -i backend.tar
  sudo docker load -i frontend.tar
  sudo docker compose down || true
  sudo docker compose up -d
  sudo docker compose ps
  rm -f backend.tar frontend.tar
EOF

echo " Сайт доступен на http://$VM_IP:8888"