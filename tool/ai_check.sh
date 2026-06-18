#!/bin/bash

# Минимальный скрипт для проверок проекта Kopim перед коммитом / отправкой.

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0;3m' # No Color
RESET='\033[0m'

echo -e "${YELLOW}=== Запуск базовых проверок проекта Kopim ===${RESET}"

# 1. Форматирование кода
echo -n "Проверка форматирования кода (dart format)... "
if dart format --set-exit-if-changed . > /dev/null 2>&1; then
    echo -e "${GREEN}ОК${RESET}"
else
    echo -e "${RED}Ошибка форматирования! Пожалуйста, запустите 'dart format .'${RESET}"
    exit 1
fi

# 2. Статический анализ
echo -n "Запуск статического анализа (flutter analyze)... "
if flutter analyze > /dev/null 2>&1; then
    echo -e "${GREEN}ОК${RESET}"
else
    echo -e "${RED}Найдены ошибки анализа! Запустите 'flutter analyze' локально для подробностей.${RESET}"
    exit 1
fi

# 3. Тесты
if [ "$1" == "--all" ]; then
    echo -e "${YELLOW}Запуск всех тестов проекта (flutter test)...${RESET}"
    flutter test --reporter expanded
    TEST_EXIT_CODE=$?
    if [ $TEST_EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}Все тесты успешно пройдены!${RESET}"
    else
        echo -e "${RED}Тесты провалены с кодом $TEST_EXIT_CODE${RESET}"
        exit $TEST_EXIT_CODE
    fi
elif [ -n "$1" ]; then
    echo -e "${YELLOW}Запуск targeted тестов для: $1...${RESET}"
    flutter test "$1" --reporter expanded
    TEST_EXIT_CODE=$?
    if [ $TEST_EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}Targeted тесты успешно пройдены!${RESET}"
    else
        echo -e "${RED}Targeted тесты провалены с кодом $TEST_EXIT_CODE${RESET}"
        exit $TEST_EXIT_CODE
    fi
else
    echo -e "${GREEN}Базовые проверки форматирования и анализа успешно пройдены!${RESET}"
    echo -e "${YELLOW}Используйте './tool/ai_check.sh --all' для запуска всех тестов или './tool/ai_check.sh <path_to_test>' для запуска конкретного теста.${RESET}"
fi

exit 0
