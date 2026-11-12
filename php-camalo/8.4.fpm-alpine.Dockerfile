# Image de développement local pour camalo/chamalo
FROM php:8.4-fpm-alpine

# Outils système utilisés en dev (composer, git via SSH, Makefile, CLI MySQL pour l'import de données de test)
RUN apk add --no-cache \
    bash \
    git \
    icu-data-full \
    make \
    mariadb-client \
    openssh-client \
    unzip

# Extensions PHP (install-php-extensions gère les dépendances de build et le nettoyage)
COPY --from=mlocati/php-extension-installer:2 /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions \
    amqp \
    ftp \
    intl \
    opcache \
    pdo_mysql \
    soap \
    sysvsem \
    xdebug \
    zip

# Configuration PHP (développement)
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY php-camalo/symfony.ini $PHP_INI_DIR/conf.d/symfony.ini

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Symfony CLI
COPY --link --from=ghcr.io/symfony-cli/symfony-cli:latest /usr/local/bin/symfony /usr/local/bin/symfony

# Clés SSH connues pour les dépôts privés
RUN mkdir -p /root/.ssh \
    && ssh-keyscan github.com >> /root/.ssh/known_hosts

# Le projet est monté en volume : on autorise git quel que soit le propriétaire / chemin
RUN git config --global --add safe.directory '*'

ENV LANG=fr_FR.UTF-8 \
    LC_ALL=fr_FR.UTF-8

WORKDIR /home/docker/www
