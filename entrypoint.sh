#!/bin/bash
set -e

# Удаляем server.pid если существует
rm -f /patient_manager/tmp/pids/server.pid

# Ждем пока база данных будет готова
until pg_isready -h db -p 5432 -U postgres; do
  echo "Waiting for database..."
  sleep 2
done

# Создаем и мигрируем базу данных
bundle exec rails db:create
bundle exec rails db:migrate

# Запускаем основной процесс
exec "$@"