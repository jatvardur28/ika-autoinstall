#!/bin/bash

set -e

echo "🔧 Установка зависимостей..."
sudo apt update && sudo apt install -y curl git unzip docker.io docker-compose ufw

echo "🐳 Настройка Docker..."
sudo systemctl enable docker
sudo systemctl start docker

echo "🧰 Установка Sui CLI..."
wget -q https://github.com/MystenLabs/sui/releases/download/mainnet-v1.19.1/sui -O sui
chmod +x sui && sudo mv sui /usr/local/bin/

echo "🔐 Генерация нового Sui кошелька..."
WALLET_DATA=$(sui client new-address ed25519 --json)
WALLET_ADDR=$(echo $WALLET_DATA | grep -o '"address": *"0x[a-f0-9]\{40,64\}"' | cut -d '"' -f4)
MNEMONIC=$(echo $WALLET_DATA | grep -o '"mnemonic": *"[^"]\+"' | cut -d '"' -f4)

echo "💾 Сохраняем сид-фразу в файл ~/sui_wallet_backup.txt"
echo -e "SUI ADDRESS: $WALLET_ADDR\nMNEMONIC: $MNEMONIC" > ~/sui_wallet_backup.txt
chmod 600 ~/sui_wallet_backup.txt

echo "💰 Получение тестовых токенов..."
sui client faucet --address $WALLET_ADDR

echo "📦 Клонирование и запуск Ika-ноды..."
git clone https://github.com/tududes/ika-node-exporer.git
cd ika-node-exporer
echo "SUI_WALLET_ADDRESS=$WALLET_ADDR" > .env
docker-compose up -d

echo "🔐 Настройка firewall (ufw)..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22      # SSH
sudo ufw allow 30303   # Ika P2P
sudo ufw allow 3000    # Grafana
sudo ufw allow 9090    # Prometheus
sudo ufw allow 80      # HTTP (если потребуется)
sudo ufw allow 443     # HTTPS (если потребуется)
sudo ufw --force enable

echo "✅ Установка завершена!"
echo "🧾 Адрес кошелька: $WALLET_ADDR"
echo "📁 Сид-фраза сохранена в: ~/sui_wallet_backup.txt"
