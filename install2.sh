#!/bin/bash

set -e

echo "💼 Генерация нового кошелька Sui..."

WALLET_DATA=$(sui client new-address ed25519 --json)
WALLET_ADDR=$(echo $WALLET_DATA | jq -r '.address')
MNEMONIC=$(echo $WALLET_DATA | jq -r '.mnemonic')

echo -e "SUI ADDRESS: $WALLET_ADDR\nMNEMONIC: $MNEMONIC" > ~/sui_wallet_backup.txt
chmod 600 ~/sui_wallet_backup.txt

echo "✅ Адрес: $WALLET_ADDR"
echo "💾 Сид-фраза сохранена в ~/sui_wallet_backup.txt"

echo "✨ Добавление в активный аккаунт..."
sui client switch --address "$WALLET_ADDR"

echo "🚰 Получение тестовых токенов (faucet)..."
sui client faucet --address "$WALLET_ADDR"

echo "✅ Установка и настройка кошелька завершена."
