FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/mysqld \
    && mkdir -p /home/owatanab/data \
    && chown mysql:mysql /var/run/mysqld \
    && chmod 755 /var/run/mysqld \
    && chown -R mysql:mysql /home/owatanab/data \
    && chmod -R 750 /home/owatanab/data

COPY my.cnf /etc/mysql/my.cnf
COPY init.sql /docker-entrypoint-initdb.d/init.sql

# 作成したエントリーポイントスクリプトをコンテナにコピーし、実行権限を付与
# COPY docker-mariadb-entry.sh /usr/local/bin/docker-mariadb-entry.sh
# RUN chmod +x /usr/local/bin/docker-mariadb-entry.sh
RUN mariadb-install-db --user=mysql --datadir="/home/owatanab/data"

EXPOSE 3306

# ENTRYPOINTにスクリプトを指定
# ENTRYPOINT ["/usr/local/bin/docker-mariadb-entry.sh"]
# CMDはエントリーポイントスクリプト内で直接 mysqld を起動するため、ここでは不要になるか、
# mysqld の基本的な引数のみを指定します（エントリーポイント側で --datadir 等を追加するため）。
# 今回のエントリーポイントスクリプトではmysqldを直接呼び出しているので、CMDは空でも良いですが、
# 習慣としてmysqldコマンドを指定しておくこともあります。
# CMD ["mysqld", "--user=mysql"] # エントリーポイントスクリプトがこれを引数として受け取る場合はこのようにする
# 今回の entrypoint.sh は引数を直接使わず、固定で mysqld を呼び出しているので、CMDは実質無視されます。
# よって、CMD は空にするか、コメントアウトしても良いです。
CMD ["mysqld", "--user=mysql", "--init-file=/docker-entrypoint-initdb.d/init.sql"]