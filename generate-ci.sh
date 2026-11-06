#!/bin/bash
set -e

echo "Генерация.gitlab-ci.yml"
cat << 'EOF' > .gitlab-ci.yml
stages:
  - build

variables:
  VERSION: 1.0.${CI_PIPELINE_ID}

build-backend:
  stage: build
  trigger:
    include: /src/backend/.gitlab-ci.yml
    strategy: depend
  only:
    changes:
      - src/backend/**/*

build-frontend:
  stage: build
  trigger:
    include: /src/frontend/.gitlab-ci.yml
    strategy: depend
  only:
    changes:
      - src/frontend/**/*
EOF

echo "Генерация src/backend/.gitlab-ci.yml"
cat << 'EOF' > src/backend/.gitlab-ci.yml
build:
  stage: build
  image:
    name: gcr.io/kaniko-project/executor:v1.9.0-debug
    entrypoint: [""]
  script:
    - echo "Собираем backend через Kaniko..."
    - /kaniko/executor
      --context "${CI_PROJECT_DIR}/src/backend"
      --dockerfile "${CI_PROJECT_DIR}/src/backend/Dockerfile"
      --destination "${CI_REGISTRY_IMAGE}/sandbox-backend:$CI_COMMIT_SHA"
      --destination "${CI_REGISTRY_IMAGE}/sandbox-backend:latest"
      --build-arg VERSION=$VERSION
      --cache=true
EOF

echo "Генерация"
cat << 'EOF' > src/frontend/.gitlab-ci.yml
build:
  stage: build
  image:
    name: gcr.io/kaniko-project/executor:v1.9.0-debug
    entrypoint: [""]
  script:
    - echo "Собираем frontend через Kaniko..."
    - /kaniko/executor
      --context "${CI_PROJECT_DIR}/src/frontend"
      --dockerfile "${CI_PROJECT_DIR}/src/frontend/Dockerfile"
      --destination "${CI_REGISTRY_IMAGE}/sandbox-frontend:$CI_COMMIT_SHA"
      --destination "${CI_REGISTRY_IMAGE}/sandbox-frontend:latest"
      --build-arg VERSION=$VERSION
      --cache=true
EOF

echo "готово"