#!/bin/bash

# ============================================
# Скрипт установки Unity Hub для Ubuntu/Debian
# С прогресс-баром и визуальной индикацией
# ============================================

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Счётчик шагов
TOTAL_STEPS=6
CURRENT_STEP=0

# Функция для отображения заголовка шага
step_header() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Шаг $CURRENT_STEP из $TOTAL_STEPS:${NC} $1"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Функция с анимацией-спиннером для долгих команд
with_spinner() {
    local pid=$1
    local message=$2
    local spin_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    
    echo -n "  $message "
    local i=0
    while kill -0 $pid 2>/dev/null; do
        echo -ne "\r  $message ${spin_chars[i % ${#spin_chars[@]}]}"
        i=$((i + 1))
        sleep 0.1
    done
    echo -ne "\r  $message ${GREEN}✓${NC}\n"
}

# Функция для отображения прогресс-бара
progress_bar() {
    local percent=$1
    local width=40
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    echo -n "  ["
    for ((i=0; i<filled; i++)); do echo -n "█"; done
    for ((i=0; i<empty; i++)); do echo -n "░"; done
    echo -n "] ${percent}%\r"
}

# Функция для успешного завершения шага
step_done() {
    echo -e "  ${GREEN}✓ Выполнено${NC}"
    progress_bar $((CURRENT_STEP * 100 / TOTAL_STEPS))
    echo
}

# Функция для ошибки
step_error() {
    echo -e "  ${RED}✗ Ошибка: $1${NC}"
    exit 1
}

# ============================================
# ОСНОВНОЙ ПРОЦЕСС УСТАНОВКИ
# ============================================

clear
echo -e "${GREEN}🚀 Установка Unity Hub${NC}"
echo "Версия скрипта: 2.1 | $(date '+%H:%M:%S')"
progress_bar 0

# Шаг 1: Проверка прав доступа
step_header "Проверка прав и подготовка"
if ! sudo -v &>/dev/null; then
    echo "  🔐 Запрашиваем права суперпользователя..."
    sudo -v || step_error "Не удалось получить права sudo"
fi
step_done

# Шаг 2: Проверка и установка curl
step_header "Проверка зависимостей (curl)"
if ! command -v curl &>/dev/null; then
    echo "  📦 curl не найден, устанавливаем..."
    (sudo apt update -qq && sudo apt install -y -qq curl) &
    with_spinner $! "Установка curl"
else
    echo "  ✅ curl уже установлен"
fi
step_done

# Шаг 3: Настройка ключей репозитория
step_header "Настройка GPG-ключей"
echo "  📁 Создаём директорию для ключей..."
sudo install -d /etc/apt/keyrings
echo "  🔑 Импортируем публичный ключ Unity..."
(curl -fsSL https://hub.unity3d.com/linux/keys/public | sudo gpg --dearmor -o /etc/apt/keyrings/unityhub.gpg) &
with_spinner $! "Загрузка и обработка ключа"
step_done

# Шаг 4: Добавление репозитория
step_header "Добавление репозитория Unity Hub"
REPO_ENTRY="deb [arch=amd64 signed-by=/etc/apt/keyrings/unityhub.gpg] https://hub.unity3d.com/linux/repos/deb stable main"
echo "  📝 Добавляем запись в sources.list.d..."
echo "$REPO_ENTRY" | sudo tee /etc/apt/sources.list.d/unityhub.list > /dev/null
echo "  ✅ Репозиторий добавлен:"
echo "     ${YELLOW}$(cat /etc/apt/sources.list.d/unityhub.list)${NC}"
step_done

# Шаг 5: Обновление кэша и установка
step_header "Обновление кэша и установка Unity Hub"
echo "  🔄 Обновляем кэш пакетов..."
(sudo apt update -qq) &
with_spinner $! "apt update"

echo "  ⬇️  Устанавливаем unityhub (это может занять 1-3 минуты)..."
(sudo apt install -y -qq unityhub) &
with_spinner $! "Установка пакета"
step_done

# Шаг 6: Финальная проверка
step_header "Финальная проверка"
if command -v unityhub &>/dev/null; then
    VERSION=$(unityhub --version 2>/dev/null || echo "неизвестная")
    echo "  ✅ Unity Hub установлен!"
    echo "  📦 Версия: ${GREEN}$VERSION${NC}"
else
    step_error "Unity Hub не найден в PATH после установки"
fi
step_done

# ============================================
# ЗАВЕРШЕНИЕ
# ============================================

clear
echo -e "${GREEN}╔════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ Unity Hub успешно установлен!  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════╝${NC}"
echo
echo "  🎮 Запуск Unity Hub:"
echo "     • Через меню приложений → найдите 'Unity Hub'"
echo "     • Или из терминала: ${YELLOW}unityhub${NC}"
echo
echo "  🔗 Полезные ссылки:"
echo "     • Документация: ${BLUE}https://docs.unity3d.com/hub${NC}"
echo "     • Learn Unity:  ${BLUE}https://learn.unity.com${NC}"
echo
echo "  ⚙️  Дополнительные команды:"
echo "     • Обновить:  ${YELLOW}sudo apt update && sudo apt upgrade unityhub${NC}"
echo "     • Удалить:   ${YELLOW}sudo apt remove unityhub${NC}"
echo
progress_bar 100
echo -e "\n${GREEN}✓ 100% — Готово!${NC}\n"
