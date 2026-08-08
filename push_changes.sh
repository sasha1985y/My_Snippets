#!/bin/bash

# Переменные (замените на свои данные)
SOURCE_REPO_DIR="/путь/к/вашему/локальному/проекту" # Откуда берем файл
REMOTE_URL="https://github.com/your-username/your-repo.git" # Куда отправляем
USERNAME="your-username" # GitHub username для аутентификации, если нужно
FILE_NAME="snippets.json"
TEMP_DIR=$(mktemp -d)

# 1. Клонируем удаленный репозиторий во временную папку
echo "Клонируем удаленный репозиторий..."
git clone --quiet "$REMOTE_URL" "$TEMP_DIR/repo" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Ошибка: Не удалось клонировать репозиторий. Проверьте URL."
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 2. Копируем файл из текущего проекта в клон удаленного
echo "Копирование файла $FILE_NAME..."
cp "$SOURCE_REPO_DIR/$FILE_NAME" "$TEMP_DIR/repo/$FILE_NAME"

# 3. Настраиваем Git в клоне (если это первый раз для этого репо)
cd "$TEMP_DIR/repo"
# Замените на свои данные, если они отличаются
git config user.email "your-email@example.com"
git config user.name "Your Name"

# 4. Добавляем, коммитим и пушим изменения
echo "Добавление и коммит изменений..."
git add "$FILE_NAME"
# Используем дату для уникальности сообщения коммита
COMMIT_MSG="Обновление $FILE_NAME на $(date +'%Y_%m_%d_%H:%M:%S')"
git commit -m "$COMMIT_MSG"

echo "Отправка изменений на GitHub..."
git push origin main

# 5. Очистка: удаляем временную папку
echo "Очистка временных файлов..."
cd -
rm -rf "$TEMP_DIR"

echo "Готово!"