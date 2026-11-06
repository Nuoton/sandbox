#!/bin/bash
set -e

# Переменные (можно менять при необходимости)
BACKEND_SERVICE="sandbox-backend"
FRONTEND_SERVICE="sandbox-frontend"
BACKEND_USER="sandbox-backend"
FRONTEND_USER="sandbox-frontend"

# --- 1. Установка http-server (если его нет) ---
# Преподаватель упомянул http-server, значит он должен быть в системе
if ! command -v http-server &> /dev/null; then
    echo "Устанавливаем Node.js и http-server..."
    sudo apt update
    sudo apt install -y nodejs npm
    sudo npm install -g http-server
fi

# --- 2. Создаем сервисных пользователей (как просил преподаватель) ---
echo "Создаем пользователей..."
sudo useradd --system --no-create-home --shell /usr/sbin/nologin --user-group "${BACKEND_USER}" 2>/dev/null || true
sudo useradd --system --no-create-home --shell /usr/sbin/nologin --user-group "${FRONTEND_USER}" 2>/dev/null || true

# --- 3. Создаем директории для сервисов ---
echo "Создаем директории..."
sudo mkdir -p /opt/sandbox/backend
sudo mkdir -p /opt/sandbox/frontend/site

# --- 4. Скачиваем/Копируем свежую версию сервиса ---
# Здесь предполагается, что бинарник app уже лежит в /home/nuoton/app
# и файлы фронтенда уже распакованы в /var/www/html
echo "Копируем файлы..."
sudo cp /home/nuoton/app /opt/sandbox/backend/app
sudo cp -r /var/www/html/* /opt/sandbox/frontend/site/

# --- 5. Переносим свежую версию конфигурации в целевую директорию ---
# (В нашем случае мы просто копируем service-файлы из репозитория в systemd)
echo "Устанавливаем конфигурации systemd..."
sudo cp src/backend/${BACKEND_SERVICE}.service /etc/systemd/system/
sudo cp src/frontend/${FRONTEND_SERVICE}.service /etc/systemd/system/

# --- 6. Выдаем права на файлы ---
sudo chown -R ${BACKEND_USER}:${BACKEND_USER} /opt/sandbox/backend
sudo chmod +x /opt/sandbox/backend/app
sudo chown -R ${FRONTEND_USER}:${FRONTEND_USER} /opt/sandbox/frontend

# --- 7. Перезагружаем конфигурацию systemd ---
echo "Перезагружаем systemd..."
sudo systemctl daemon-reload

# --- 8. Запускаем сервисы и включаем автозапуск ---
echo "Запускаем сервисы..."
sudo systemctl enable "${BACKEND_SERVICE}" "${FRONTEND_SERVICE}"
sudo systemctl restart "${BACKEND_SERVICE}" "${FRONTEND_SERVICE}"

# --- 9. Проверяем статус ---
echo "Статус сервисов:"
sudo systemctl status "${BACKEND_SERVICE}" --no-pager
sudo systemctl status "${FRONTEND_SERVICE}" --no-pager

echo "Установка завершена!"