# BigDataSnowflake

Лабораторная работа по трансформации плоских CSV-данных в аналитическую модель "снежинка" на PostgreSQL.

## Структура проекта

```text
.
├── docker-compose.yml
├── README.md
├── report.md
├── scripts
│   ├── 01_ddl.sql
│   ├── 02_dml.sql
│   ├── 03_queries.sql
│   └── init.sh
└── исходные данные
    ├── MOCK_DATA.csv
    ├── MOCK_DATA (1).csv
    └── ...
```

## Что делает

1. Создает `mock_data` для staging-загрузки CSV.
2. Создает таблицы измерений и таблицу фактов в модели "снежинка".
3. Загружает все 10 CSV-файлов в `mock_data`.
4. Заполняет измерения и `fact_sales`.

## Быстрый запуск

```bash
docker compose up -d
```

Подключение к БД:

- Host: `localhost`
- Port: `5435`
- Database: `bdsnowflake`
- User: `student`
- Password: `student`

Открыть `psql`:

```bash
docker compose exec postgres psql -U student -d bdsnowflake
```

## Проверка

Проверить число строк:

```sql
SELECT COUNT(*) FROM mock_data;
SELECT COUNT(*) FROM fact_sales;
```

Ожидаемый результат:

- `mock_data = 10000`
- `fact_sales = 10000`

Запустить готовые проверочные запросы:

```bash
docker compose exec postgres psql -U student -d bdsnowflake -f /scripts/03_queries.sql
```

## Остановка

```bash
docker compose down
```

Полная очистка данных:

```bash
docker compose down -v
```

## Схема

### Таблица фактов

- `fact_sales`:
  - внешние ключи на дату, покупателя, продавца, товар, магазин, поставщика
  - метрики `sale_quantity`, `sale_total_price`

### Измерения уровня 1

- `dim_customer`
- `dim_seller`
- `dim_product`
- `dim_store`
- `dim_supplier`

### Измерения уровня 2

- `dim_country`
- `dim_city`
- `dim_pet`
- `dim_product_category`
- `dim_brand`
- `dim_material`
- `dim_date`
