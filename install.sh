#!/bin/bash

# ============================================
# Скрипт установки Unity Hub для Ubuntu/Debian
# ============================================

set -e  # Прервать выполнение при ошибке

echo "🚀 Начало установки Unity Hub..."

# Проверка прав суперпользователя
if [ "$EUID" -ne 0 ]; then 
  echo "❌ Пожалуйста, запустите скрипт с правами root (sudo)"
  exit 1
fi

# Проверка и установка curl при необходимости
if ! command -v curl &> /dev/null; then
    echo "📦 Установка curl..."
    apt update -qq && apt install -y -qq curl
fi

# Создание директории для ключей
echo "🔐 Настройка ключей репозитория..."
install -d /etc/apt/keyrings

# Импорт публичного ключа подписи Unity
echo "🔑 Добавление публичного ключа Unity..."
curl -fsSL https://hub.unity3d.com/linux/keys/public | gpg --dearmor -o /etc/apt/keyrings/unityhub.gpg

# Добавление репозитория Unity Hub (только для amd64)
echo "📁 Добавление репозитория Unity Hub..."
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/unityhub.gpg] https://hub.unity3d.com/linux/repos/deb stable main" > /etc/apt/sources.list.d/unityhub.list

# Обновление кэша пакетов и установка Unity Hub
echo "⬇️ Обновление кэша пакетов и установка Unity Hub..."
apt update -qq
apt install -y -qq unityhub

echo ""
echo "✅ Unity Hub успешно установлен!"
echo "💡 Запустите Unity Hub из меню приложений или командой: unityhub"
