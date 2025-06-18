#!/bin/bash
set -e # コマンドがエラーになったらすぐに終了

DATADIR="/home/owatanab/data" # データディレクトリ

# データディレクトリが初期化されていなければ初期化処理を実行
if [ ! -d "$DATADIR/mysql" ]; then
  echo "データディレクトリ '$DATADIR' は初期化されていません。初期化します..."
  # mariadb-install-db コマンドでデータディレクトリを初期化
  # --user にはMariaDBを実行するユーザー、--datadir にはデータディレクトリを指定
  mariadb-install-db --user=mysql --datadir="$DATADIR"
  echo "データディレクトリの初期化が完了しました。"
else
  echo "データディレクトリ '$DATADIR' は既に初期化されています。"
fi

INIT_FILE_OPT=""
# init.sql が存在すれば、--init-file オプションとして追加
if [ -f "/docker-entrypoint-initdb.d/init.sql" ]; then
  INIT_FILE_OPT="--init-file=/docker-entrypoint-initdb.d/init.sql"
  echo "初期化SQLファイルを使用します: /docker-entrypoint-initdb.d/init.sql"
fi

echo "MariaDBサーバーを起動します..."
# mysqld を実行ユーザーmysqlで、指定されたデータディレクトリとinit-fileオプションで起動
# CMDからの引数 ("mysqld", "--user=mysql") はここで直接指定するため、exec "$@" は使わない
exec mysqld --user=mysql --datadir="$DATADIR" $INIT_FILE_OPT