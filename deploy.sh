#!/bin/sh
set -eu
cd "$(dirname "$0")"

set -a
. ./.env
set +a

: "${IMAGE_REGISTRY:?Не задан IMAGE_REGISTRY в .env}"
: "${VERSION:?Не задан VERSION в .env}"
: "${REGISTRY_USER:?Не задан REGISTRY_USER}"

echo "Вход в registry ${IMAGE_REGISTRY}"
docker login "$IMAGE_REGISTRY" -u "$REGISTRY_USER" --password-stdin

echo "Загрузка образов версии ${VERSION}"
docker compose pull

echo "Запуск"
docker compose up -d --remove-orphans

echo "Очистка старых образов"
docker image prune -f

echo "$VERSION" > version

echo "Готово! Развернута версия ${VERSION}"
docker compose ps