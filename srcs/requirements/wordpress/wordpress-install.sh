#!/bin/bash
if [ ! -f /home/owatanab/data/wp-config.php ]; then
    cat << EOF > /home/owatanab/data/wp-config.php
<?php
define('DB_NAME', '${WORDPRESS_DB_NAME}');
define('DB_USER', '${WORDPRESS_DB_USER}');
define('DB_PASSWORD', '${WORDPRESS_DB_PASSWORD}');
define('DB_HOST', '${WORDPRESS_DB_HOST}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
\$table_prefix = 'wp_';
define('WP_DEBUG', true);
if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');
require_once(ABSPATH . 'wp-settings.php');
EOF
fi

# WordPress のインストールが完了したかどうかの目印ファイル
WP_INSTALLED_FLAG="/home/owatanab/data/wp-installed.flag"

# もし目印ファイルが「まだ存在しなかったら」WordPressのコアインストールを実行
if [ ! -f "${WP_INSTALLED_FLAG}" ]; then
    echo "WordPress core installing..."

    # 少し待機してDBが完全に準備できるのを待つ (環境によっては必要)
    # sleep 15 # 例えば15秒待つ。もっと確実なのは wait-for-it.sh などの利用です。

    # WP-CLI を使って WordPress をインストール！
    # --allow-root は、このスクリプトがrootユーザーで実行されている場合に必要です。
    # 環境変数からサイト情報や管理者情報を取得します。
    wp core install --url="${WORDPRESS_SITE_URL}" \
                    --title="${WORDPRESS_SITE_TITLE}" \
                    --admin_user="${WORDPRESS_ADMIN_USER}" \
                    --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
                    --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
                    --skip-email \
                    --allow-root

    if [ $? -eq 0 ]; then
        echo "WordPress core installed successfully."
        # インストール成功の目印として空のファイルを作成
        touch "${WP_INSTALLED_FLAG}"
    else
        echo "WordPress core installation failed."
        # エラーの場合は、ここでスクリプトを終了させるか、リトライ処理などを入れることも考えられます。
        # 今回はシンプルにエラーメッセージだけ表示します。
    fi

    # ↓ここから追加ユーザー作成↓
    if [ -f "${WP_INSTALLED_FLAG}" ]; then
        echo "Admin user created. Creating additional user..."
        # 追加ユーザーの情報も環境変数から取得するようにすると柔軟です
        wp user create "${ADDITIONAL_USER_LOGIN}" \
                       "${ADDITIONAL_USER_EMAIL}" \
                       --role="${ADDITIONAL_USER_ROLE}" \
                       --user_pass="${ADDITIONAL_USER_PASSWORD}" \
                       --allow-root # スクリプトがrootで実行されている場合

        if [ $? -eq 0 ]; then
            echo "Additional user created successfully."
        else
            echo "Failed to create additional user."
        fi
        # ↑ここまで追加ユーザー作成↑

        echo "WordPress core installed successfully."
        touch "${WP_INSTALLED_FLAG}" # すべての初期ユーザー作成が終わってからフラグを立てる
    else
        echo "WordPress core installation failed."
    fi
else
    echo "WordPress core already installed. Skipping."
fi

exec /usr/sbin/php-fpm8.1 --nodaemonize