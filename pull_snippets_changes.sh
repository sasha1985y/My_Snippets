#!/usr/bin/env bash
set -euo pipefail

ENV_FILE=".env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Ошибка: файл $ENV_FILE не найден!" >&2
  exit 1
fi

source "$ENV_FILE"

set -e # Останавливаться при любой ошибке


# Переменные (замените на свои данные)
URL_SOURCE_FILE="$URL_SOURCE_FILE" # Откуда берем файл
REMOTE_URL="$REMOTE_URL" # Куда отправляем
USERNAME="$USERNAME" # GitHub username для аутентификации, если нужно
LOCAL_TARGET_FILE="$LOCAL_TARGET_FILE"
CURRENT_REPO="$CURRENT_REPO"
TEMP_DIR=$(mktemp -d)
#SSH_ADD="$SSH_ADD"
#ssh-add ~/.ssh/"$SSH_ADD"

# 1. Клонируем удаленный репозиторий во временную папку
cd ..
echo "Клонируем удаленный репозиторий..."
git clone --quiet "$REMOTE_URL" "$TEMP_DIR"/repo 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Ошибка: Не удалось клонировать репозиторий. Проверьте URL."
    rm -rf "$TEMP_DIR"
    exit 1
fi

if [[ ! -f "$TEMP_DIR"/repo/"$URL_SOURCE_FILE" ]]; then
  echo "Ошибка: файл $URL_SOURCE_FILE не найден!" >&2
  exit 1
fi

# 2. Копируем файл из текущего проекта в клон удаленного
echo "Копирование файла $URL_SOURCE_FILE...."

cat "$TEMP_DIR"/repo/"$URL_SOURCE_FILE" > "$CURRENT_REPO"/"$LOCAL_TARGET_FILE"

# 3. Добавляем, коммитим и пушим изменения
echo "Добавление и коммит изменений..."
cd "$CURRENT_REPO"

git add "$LOCAL_TARGET_FILE"
# Используем дату для уникальности сообщения коммита
COMMIT_MSG="Обновление $LOCAL_TARGET_FILE на $(date +'%Y_%m_%d_%H:%M:%S')"
git commit -m "$COMMIT_MSG"

echo "Отправка изменений на GitHub..."
git push origin main

# 4. Очистка: удаляем временную папку
echo "Очистка временных файлов..."

echo "Готово!"
