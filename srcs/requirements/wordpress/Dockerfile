FROM debian:bullseye-slim

# 必要なツールをインストールし、sury.org のリポジトリを追加
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    && curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb \
    && dpkg -i /tmp/debsuryorg-archive-keyring.deb \
    && echo "deb https://packages.sury.org/php/ bullseye main" > /etc/apt/sources.list.d/php.list \
    && rm /tmp/debsuryorg-archive-keyring.deb \
    && apt-get update

# PHP 8.1 と必要な拡張モジュールをインストール
RUN apt-get install -y \
    php8.1 \
    php8.1-fpm \
    php8.1-mysql \
    php8.1-gd \
    php8.1-zip \
    php8.1-mbstring \
    php8.1-curl \
    php8.1-xml

# Web ディレクトリを作成
RUN mkdir -p /var/www/html

# WordPress の最新版をダウンロード
RUN curl -o /tmp/wordpress.tar.gz -SL https://wordpress.org/latest.tar.gz \
    && tar -xzf /tmp/wordpress.tar.gz -C /tmp \
    && mv /tmp/wordpress/* /var/www/html/ \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/wp-content \
    && rm /tmp/wordpress.tar.gz

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# 不要なパッケージを削除してクリーンアップ
RUN apt-get purge -y --auto-remove curl unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# PHP-FPM の設定
RUN sed -i 's/listen = \/run\/php\/php8.1-fpm.sock/listen = 9000/' /etc/php/8.1/fpm/pool.d/www.conf \
    && sed -i 's/;clear_env = no/clear_env = no/' /etc/php/8.1/fpm/pool.d/www.conf

# PHP-FPM のソケットディレクトリを作成
RUN mkdir -p /run/php && chown www-data:www-data /run/php

# 作業ディレクトリを設定
WORKDIR /var/www/html

# ポートを公開
EXPOSE 9000

# エントリーポイントスクリプトをコピー
COPY wordpress-install.sh /usr/local/bin/wordpress-install.sh
RUN chmod +x /usr/local/bin/wordpress-install.sh

# エントリーポイントを設定
ENTRYPOINT ["/usr/local/bin/wordpress-install.sh"]