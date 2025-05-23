#!/bin/bash

set -e

echo "🔧 Обновление системы..."
apt update && apt upgrade -y

echo "📦 Установка зависимостей..."
apt install -y curl git ufw unzip jq build-essential pkg-config libssl-dev libclang-dev cmake lsb-release

echo "🐳 Установка Docker и Docker Compose..."
apt install -y docker.io docker-compose
systemctl enable docker --now

echo "🔓 Настройка файрвола..."
ufw allow OpenSSH
ufw allow 8080/tcp
ufw allow 9000/tcp
ufw allow 9184/tcp
ufw allow 443/tcp
ufw --force enable

echo "📁 Создание рабочих директорий..."
mkdir -p ~/ika-node && cd ~/ika-node

echo "📥 Загрузка конфигурации Ika Node..."
curl -sL https://raw.githubusercontent.com/ikamachines/ika/main/docker-compose.yaml -o docker-compose.yaml

echo "🐳 Запуск Ika Node..."
docker-compose pull
docker-compose up -d

echo "✅ Установка завершена. Далее установите Sui CLI вручную и продолжите настройку."
