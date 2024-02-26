ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-fpm
ENV DISPLAY=:99 \
    DBUS_SESSION_BUS_ADDRESS=/dev/null

RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /usr/local/etc/php-fpm.conf \
    && sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i -e "s/pm.max_children = 5/pm.max_children = 9/g" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i -e "s/pm.start_servers = 2/pm.start_servers = 3/g" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i -e "s/pm.max_requests = 500/pm.max_requests = 200/g" /usr/local/etc/php-fpm.d/www.conf

RUN apt-get update -qqy \
  && apt-get -qqy install wget ca-certificates apt-transport-https nginx supervisor ttf-wqy-zenhei\
    unzip git x11vnc xfonts-100dpi xfonts-75dpi xfonts-cyrillic xfonts-scalable xvfb libpng-dev libjpeg-dev gnupg \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update -qqy \
    && apt-get -qqy install google-chrome-stable google-chrome-unstable chromium google-chrome-beta \
    && rm /etc/apt/sources.list.d/google-chrome.list \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN apt-get update -qqy \
    && apt-get install -y libc-client-dev libkrb5-dev libzip-dev libmagickwand-dev --no-install-recommends \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install gd imap zip \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Imagick
RUN set -xe \
 && git clone https://github.com/Imagick/imagick \
 && cd imagick \
 && git checkout master && git pull \
 && phpize && ./configure && make && make install \
 && cd .. && rm -Rf imagick \
 && docker-php-ext-enable imagick \
 && rm -rf /tmp/* /var/cache/apt/*

# Chrome
RUN useradd headless --shell /bin/bash --create-home \
    && usermod -a -G sudo headless \
    && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && echo 'headless:nopassword' | chpasswd

RUN mkdir /data

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && rm -rf /etc/nginx/sites-enabled/default \
    && mkdir -p /root/.ssh \
    && echo "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

VOLUME /code

WORKDIR /code

# Ajout de conf php custom
COPY files/php.ini $PHP_INI_DIR/conf.d/

COPY files/supervisord.conf /etc/supervisord.conf

COPY files/entrypoint.sh /entrypoint.sh

COPY files/vhost.conf /etc/nginx/sites-enabled/vhost.conf

COPY files/policy.xml /etc/ImageMagick-6/policy.xml

ENTRYPOINT ["/entrypoint.sh"]

CMD ["bash"]
