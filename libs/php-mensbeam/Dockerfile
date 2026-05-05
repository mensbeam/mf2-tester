FROM php:8.5.5-cli
RUN apt-get update && apt-get install -y git jq unzip && rm -rf /var/lib/apt/lists/*
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
WORKDIR /app/deps
COPY deps/composer.json deps/composer.lock ./
RUN composer install --no-dev -q
