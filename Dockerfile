
FROM php:8.1-apache

MAINTAINER Hendro Wicaksono <hendrowicaksono@gmail.com>

ENV SLIMS_VERSION 9.7.2
ENV SLIMS_MD5 1df72c24a47c37eb4dcac4f0874ab9e4

# 1. Install dependencies sistem
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      libmariadb-dev libxslt1-dev unzip gettext mariadb-client libyaz-dev \
        libfreetype6-dev libjpeg-dev libmagickwand-dev \
        libpng-dev libzip-dev libwebp-dev libonig-dev; \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Install & Configure PHP Extensions
RUN set -ex; \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp; \
    docker-php-ext-install -j "$(nproc)" \
        bcmath exif gd mysqli opcache zip gettext pdo_mysql intl xsl mbstring ; \
    pecl install redis && docker-php-ext-enable redis; \
    pecl install yaz && docker-php-ext-enable yaz;

# 3. Konfigurasi PHP (OPCache & Error Logging)
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini


# 5. Download & Install SLiMS
WORKDIR /var/www/html
# RUN set -eux; \
#     curl -fSL "https://github.com/slims/slims9_bulian/archive/v${SLIMS_VERSION}.zip" -o slims.zip; \
#     # Pastikan MD5 sesuai, jika versi SLiMS naik, MD5 ini harus diupdate
#     unzip slims.zip; \
#     mv slims9_bulian-${SLIMS_VERSION} slims; \
#     chown -R www-data:www-data slims; \
#     rm slims.zip; \
#     chmod -R 777 slims/config slims/images slims/files slims/repository slims/config

COPY ./slims9_bulian-${SLIMS_VERSION} 
RUN set -eux; \
    chown -R www-data:www-data /var/www/html; \
    chmod -R 755 /var/www/html; \
    chmod -R 777 ./config ./images ./files ./repository

# Ekspos port standar
EXPOSE 80 443
