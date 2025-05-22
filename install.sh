#!/bin/bash

set -e

echo "🔄 Обновление системы..."
apt update && apt upgrade -y

echo "📦 Установка зависимостей..."
apt install -y curl wget git ufw docker.io docker-compose jq build-essential pkg-config libssl-dev libclang-dev clang cmake

echo "🔓 Настройка файрвола..."
ufw allow 22
ufw allow 9000
ufw allow 9184
ufw --force enable

echo "🐳 Запуск Docker..."
systemctl enable docker
systemctl start docker

echo "📥 Установка Sui CLI через qyeah98/sui-installer..."
bash <(curl -s https://raw.githubusercontent.com/qyeah98/sui-installer/main/install.sh)

echo "🪙 Генерация нового Sui-кошелька..."
WALLET_DATA=$(sui client new-address ed25519 --json)
WALLET_ADDR=$(echo "$WALLET_DATA" | jq -r .address)
MNEMONIC=$(echo "$WALLET_DATA" | jq -r .mnemonic)

echo -e "SUI ADDRESS: $WALLET_ADDR\nMNEMONIC: $MNEMONIC" > ~/sui_wallet_backup.txt
chmod 600 ~/sui_wallet_backup.txt
echo "✅ Адрес Sui: $WALLET_ADDR"
echo "🧠 Сид-фраза сохранена в ~/sui_wallet_backup.txt"

echo "🚰 Получение тестовых токенов..."
sui client faucet --address "$WALLET_ADDR"

echo "✅ Установка завершена. Рекомендуется перезагрузить систему: sudo reboot"
