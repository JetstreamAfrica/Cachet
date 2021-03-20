FROM composer:1.10 as vendor

COPY database/ database/

COPY composer.json composer.json
COPY composer.lock composer.lock

RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist

FROM php:7.4-fpm-alpine

RUN rm -f /etc/apk/repositories &&\
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.12/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.12/community" >> /etc/apk/repositories

RUN apk update --quiet && apk add --quiet --no-cache --virtual .build-deps autoconf  \
    zlib-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libxml2-dev \
    bzip2-dev \
    postgresql-dev \
    zip \
    libzip-dev \
    gmp-dev \
    curl

RUN apk add --quiet --update --no-cache bash \
    jpegoptim \
    pngquant \
    optipng \
    icu-dev \
    freetype-dev

RUN docker-php-ext-configure \
    opcache --enable-opcache &&\
    docker-php-ext-configure gd --with-jpeg=/usr/include/ --with-freetype=/usr/include/ && \
    docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql &&\
    docker-php-ext-configure zip && \
    docker-php-ext-install \
    opcache \
    pgsql \
    pdo_pgsql \
    pdo \
    sockets \
    json \
    intl \
    gd \
    xml \
    bz2 \
    pcntl \
    bcmath \
    exif

RUN apk --no-cache add --quiet pcre-dev ${PHPIZE_DEPS} \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del pcre-dev ${PHPIZE_DEPS} \
    && rm -rf /tmp/pear

ENV USER www
ENV APP_HOME /var/$USER

WORKDIR ${APP_HOME}

RUN touch .env

COPY nginx /etc/nginx
COPY entrypoint.sh /var/www/
RUN chmod +x /var/www/entrypoint.sh
COPY php/php.ini /usr/local/etc/php/conf.d/laravel.ini

COPY . ${APP_HOME}
COPY --from=vendor /app/vendor/ /var/www/vendor/

VOLUME ["/etc/nginx", "/var/www"]

ENTRYPOINT [ "/var/www/entrypoint.sh" ]

CMD ["php-fpm"]
