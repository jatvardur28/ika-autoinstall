#!/bin/bash

set -e

### Цвета для отображения
GREEN="\033[1;32m"
CYAN="\033[1;36m"
NC="\033[0m"

print_step() {
  echo -e "${CYAN}==> $1${NC}"
}

### 1. Обновление и установка зависимостей
print_step "Обновляем систему и устанавливаем пакеты..."
apt update && apt upgrade -y
apt install -y curl wget git ufw build-essential pkg-config libssl-dev jq docker.io docker-compose

### 2. Настройка firewall
print_step "Открываем порты..."
ufw allow 22
ufw allow 80
ufw allow 443
ufw allow 9100
ufw allow 8080
ufw --force enable

### 3. Установка Rust
print_step "Устанавливаем Rust..."
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

### 4. Клонируем Sui CLI и собираем
print_step "Скачиваем Sui CLI..."
git clone https://github.com/MystenLabs/sui.git
cd sui
cargo build --release
cp target/release/sui /usr/local/bin/
cd .. && rm -rf sui

### 5. Генерация Sui-кошелька
print_step "Генерируем Sui кошелёк..."
WALLET_DATA=$(sui client new-address ed25519 --json)
WALLET_ADDR=$(echo $WALLET_DATA | jq -r '.address')
MNEMONIC=$(echo $WALLET_DATA | jq -r '.mnemonic')
echo -e "SUI ADDRESS: $WALLET_ADDR\nMNEMONIC: $MNEMONIC" > ~/sui_wallet_backup.txt
chmod 600 ~/sui_wallet_backup.txt

### 6. Получение тестовых токенов
print_step "Запрос тестовых токенов..."
sui client faucet --address $WALLET_ADDR || true

### 7. Установка IKA
print_step "Скачиваем IKA Node Docker...
"
mkdir -p ~/ika && cd ~/ika
curl -fsSL https://raw.githubusercontent.com/ikameta/ika-node-docker/main/docker-compose.yml -o docker-compose.yml

print_step "Запускаем ноду..."
docker compose up -d

print_step "Установка завершена. Ваш Sui адрес: $WALLET_ADDR"
echo -e "\n${GREEN}Sui wallet saved to ~/sui_wallet_backup.txt${NC}"
