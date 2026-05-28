FROM php:8.2-cli

## System deps
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     git unzip libzip-dev libpng-dev libicu-dev libonig-dev libxml2-dev \
  && docker-php-ext-install pdo_mysql zip gd intl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

## Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /workspace

EXPOSE 8000
