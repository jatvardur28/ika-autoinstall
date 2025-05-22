#!/bin/bash
set -e

echo "🛠 Обновление системы..."
sudo apt update && sudo apt upgrade -y

echo "🔧 Установка необходимых пакетов..."
sudo apt install -y curl wget tar git ufw jq unzip ca-certificates gnupg lsb-release file

echo "🐳 Установка Docker и Docker Compose..."
sudo apt install -y docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker

echo "🔓 Настройка файрвола..."
sudo ufw allow ssh
sudo ufw allow 26656/tcp     # p2p порт Ika
sudo ufw allow 80,443/tcp    # если потребуется для RPC/HTTPS
sudo ufw --force enable

echo "📦 Установка Sui CLI..."

LATEST_TAG=$(curl -s https://api.github.com/repos/MystenLabs/sui/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
URL="https://github.com/MystenLabs/sui/releases/download/${LATEST_TAG}/sui-linux-amd64.tar.gz"

wget -q --show-progress "$URL" -O sui-linux.tar.gz
tar -xzf sui-linux.tar.gz
chmod +x sui
sudo mv sui /usr/local/bin/
rm sui-linux.tar.gz

echo "🔐 Генерация Sui-кошелька..."
WALLET_DATA=$(sui client new-address ed25519 --json)
WALLET_ADDR=$(echo $WALLET_DATA | jq -r '.address')
MNEMONIC=$(echo $WALLET_DATA | jq -r '.mnemonic')

echo "💾 Сохранение сид-фразы в ~/sui_wallet_backup.txt"
echo -e "SUI_ADDRESS=$WALLET_ADDR\nMNEMONIC=\"$MNEMONIC\"" > ~/sui_wallet_backup.txt
chmod 600 ~/sui_wallet_backup.txt

echo "🪙 Запрос тестовых токенов с faucet..."
sui client faucet --address "$WALLET_ADDR" > /dev/null || echo "⚠️ Faucet временно недоступен"

echo "🌐 Клонирование Ika-ноды..."
git clone https://github.com/iko-io/ika-node.git
cd ika-node

echo "🚀 Запуск Ika-ноды..."
docker compose up -d

echo "✅ Установка завершена!"
echo "🧠 Сид-фраза сохранена в: ~/sui_wallet_backup.txt"
echo "🔗 Ваш Sui-адрес: $WALLET_ADDR"
