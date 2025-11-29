FROM surnet/alpine-wkhtmltopdf:3.21.2-0.12.6-full as wkhtmltopdf
FROM php:8.4-fpm-alpine

# Install dependencies for wkhtmltopdf
RUN apk add --no-cache \
  libstdc++ \
  libx11 \
  libxrender \
  libxext \
  libssl3 \
  ca-certificates \
  fontconfig \
  freetype \
  ttf-dejavu \
  ttf-droid \
  ttf-freefont \
  ttf-liberation \
&& apk add --no-cache --virtual .build-deps \
  msttcorefonts-installer \
\
# Install microsoft fonts
&& update-ms-fonts \
&& fc-cache -f \
\
# Clean up when done
&& rm -rf /tmp/* \
&& apk del .build-deps

# Copy wkhtmltopdf files from docker-wkhtmltopdf image
COPY --from=wkhtmltopdf /bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf
COPY --from=wkhtmltopdf /bin/wkhtmltoimage /usr/local/bin/wkhtmltoimage
COPY --from=wkhtmltopdf /bin/libwkhtmltox* /usr/local/bin/

# Install dependencies for PHP
RUN apk upgrade --update && \
    apk add --no-cache libssl3 git openssh make openssl bash zip mysql-client libpng libzip icu rabbitmq-c icu-data-full gcompat && \
    apk add --no-cache --virtual .build-deps libxml2-dev rabbitmq-c-dev curl-dev libzip-dev libpng-dev icu-dev libjpeg-turbo-dev libwebp-dev zlib-dev libxpm-dev $PHPIZE_DEPS && \
    apk add --update linux-headers

RUN docker-php-ext-install zip bcmath pdo_mysql gd intl calendar soap sysvmsg sysvsem sysvshm http && \
    pecl install xdebug amqp && \
    docker-php-ext-enable xdebug amqp soap http && \
    docker-php-ext-configure intl

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY php-camalo/symfony.ini $PHP_INI_DIR/conf.d/symfony.ini

ENV LANG fr_FR.UTF-8
ENV LC_ALL fr_FR.UTF-8

# INSTALL COMPOSER
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer && \
    alias composer='php /usr/bin/composer'

RUN mkdir ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# INSTALL SYMFONY
RUN wget https://get.symfony.com/cli/installer -O - | bash && \
    mv /root/.symfony5/bin/symfony /usr/local/bin/symfony

# Set working directory
WORKDIR /var/www/html
RUN git config --global --add safe.directory /var/www/html

RUN rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/*

RUN apk del .build-deps && \
    rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/*
