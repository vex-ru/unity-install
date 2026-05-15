#!/bin/bash

# ============================================
# Скрипт установки Unity Hub для Ubuntu/Debian
# Автоматический запрос прав через sudo
# ============================================

set -e  # Прервать выполнение при ошибке

echo "🚀 Начало установки Unity Hub..."

# Проверка наличия curl, установка при необходимости
if ! command -v curl &> /dev/null; then
    echo "📦 curl не найден. Установка..."
    sudo apt update -qq && sudo apt install -y -qq curl
fi

# Создание директории для ключей
echo "🔐 Настройка ключей репозитория..."
sudo install -d /etc/apt/keyrings

# Импорт публичного ключа подписи Unity
echo "🔑 Добавление публичного ключа Unity..."
curl -fsSL https://hub.unity3d.com/linux/keys/public | sudo gpg --dearmor -o /etc/apt/keyrings/unityhub.gpg

# Добавление репозитория Unity Hub (только для amd64)
echo "📁 Добавление репозитория Unity Hub..."
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/unityhub.gpg] https://hub.unity3d.com/linux/repos/deb stable main" | sudo tee /etc/apt/sources.list.d/unityhub.list

# Обновление кэша пакетов и установка Unity Hub
echo "⬇️ Обновление кэша пакетов и установка Unity Hub..."
sudo apt update -qq
sudo apt install -y -qq unityhub

echo ""
echo "✅ Unity Hub успешно установлен!"
echo "💡 Запустите Unity Hub из меню приложений или командой: unityhub"
