FROM ruby:3.4.6

# Устанавливаем зависимости для разработки
RUN apt-get update -qq && apt-get install -y \
    postgresql-client \
    nodejs \
    npm \
    vim \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g yarn

# Создаем рабочую директорию
WORKDIR /patient_manager

# Копируем Gemfile и устанавливаем гемы
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Копируем весь код приложения
COPY . .

# Добавляем скрипт для запуска
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Экспонируем порт
EXPOSE 3000

# Команда запуска для разработки
CMD ["rails", "server", "-b", "0.0.0.0"]