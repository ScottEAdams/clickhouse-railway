FROM clickhouse/clickhouse-server:24

COPY custom-configs.xml /etc/clickhouse-server/config.d/

