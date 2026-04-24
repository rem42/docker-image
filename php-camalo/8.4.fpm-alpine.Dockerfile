FROM surnet/alpine-wkhtmltopdf:3.21.2-0.12.6-full AS wkhtmltopdf

FROM php:8.4-fpm-alpine

# Runtime dependencies
RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    fontconfig \
    freetype \
    gcompat \
    git \
    icu \
    icu-data-full \
    libjpeg-turbo \
    libpng \
    libssl3 \
    libstdc++ \
    libwebp \
    libx11 \
    libxext \
    libxrender \
    libxslt \
    libzip \
    make \
    mysql-client \
    openssh \
    openssl \
    rabbitmq-c \
    ttf-dejavu \
    ttf-droid \
    ttf-freefont \
    ttf-liberation \
    zip \
    zlib

# Microsoft fonts
RUN apk add --no-cache --virtual .font-build-deps msttcorefonts-installer \
    && update-ms-fonts \
    && fc-cache -f \
    && apk del .font-build-deps \
    && rm -rf /tmp/* /var/cache/apk/*

# wkhtmltopdf
COPY --from=wkhtmltopdf /bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf
COPY --from=wkhtmltopdf /bin/wkhtmltoimage /usr/local/bin/wkhtmltoimage
COPY --from=wkhtmltopdf /bin/libwkhtmltox* /usr/local/bin/

# PHP extensions build dependencies
RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    curl-dev \
    freetype-dev \
    icu-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libxml2-dev \
    libxpm-dev \
    libxslt-dev \
    libzip-dev \
    linux-headers \
    rabbitmq-c-dev \
    zlib-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        calendar \
        ftp \
        gd \
        intl \
        pdo_mysql \
        soap \
        sysvmsg \
        sysvsem \
        sysvshm \
        xsl \
        zip \
    && pecl install xdebug amqp \
    && docker-php-ext-enable xdebug amqp \
    && apk del .build-deps \
    && rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/*

# PHP config
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY php-camalo/symfony.ini $PHP_INI_DIR/conf.d/symfony.ini

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# SSH known hosts for private repositories
RUN mkdir -p /root/.ssh \
    && ssh-keyscan github.com >> /root/.ssh/known_hosts

# Symfony CLI (latest stable)
COPY --link \
    --from=ghcr.io/symfony-cli/symfony-cli:latest \
    /usr/local/bin/symfony /usr/local/bin/symfony

ENV LANG=fr_FR.UTF-8
ENV LC_ALL=fr_FR.UTF-8

WORKDIR /var/www/html

RUN git config --global --add safe.directory /var/www/html
