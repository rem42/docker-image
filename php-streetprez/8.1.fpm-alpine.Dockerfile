FROM php:8.1-fpm-alpine

# Installation des dépendances de production
RUN apk upgrade --update && \
    apk add --no-cache \
    libssl3 \
    git \
    openssh \
    make \
    openssl \
    bash \
    zip \
    mysql-client \
    libzip \
    icu \
    libxslt-dev \
    libxpm-dev && \
    apk add --no-cache --virtual .build-deps libxml2-dev curl-dev libzip-dev icu-dev zlib-dev $PHPIZE_DEPS

# Installation des extensions PHP avec Opcache
RUN docker-php-ext-install zip pdo_mysql intl calendar soap sysvmsg sysvsem sysvshm xsl opcache && \
    docker-php-ext-configure intl

# Configuration PHP de Production
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY symfony.ini $PHP_INI_DIR/conf.d/symfony.ini

# Installation de Composer
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

# Nettoyage
RUN apk del .build-deps && \
    rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/*

WORKDIR /var/www/html
