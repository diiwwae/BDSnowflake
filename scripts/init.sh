#!/bin/bash
set -e

echo "=== Начало инициализации БД ==="

echo "--- Выполняю DDL ---"
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /scripts/ddl.sql

echo "--- Загружаю CSV файлы ---"
for file in /data/csv/*.csv; do
    echo "Загрузка: $file"
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "COPY mock_data FROM '$file' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '\"', ENCODING 'UTF8');"
done

echo "--- Строк в mock_data ---"
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT COUNT(*) AS total_rows FROM mock_data;"

echo "--- Выполняю DML ---"
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /scripts/dml.sql

echo "--- Строк в fact_sales ---"
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT COUNT(*) AS total_facts FROM fact_sales;"

echo "=== Инициализация завершена ==="
