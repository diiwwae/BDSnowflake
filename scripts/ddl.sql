DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;
DROP TABLE IF EXISTS dim_seller CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_store CASCADE;
DROP TABLE IF EXISTS dim_supplier CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;
DROP TABLE IF EXISTS dim_city CASCADE;
DROP TABLE IF EXISTS dim_pet CASCADE;
DROP TABLE IF EXISTS dim_product_category CASCADE;
DROP TABLE IF EXISTS dim_brand CASCADE;
DROP TABLE IF EXISTS dim_material CASCADE;
DROP TABLE IF EXISTS dim_country CASCADE;
DROP TABLE IF EXISTS mock_data CASCADE;

CREATE TABLE mock_data (
    id                   INT,
    customer_first_name  VARCHAR(100),
    customer_last_name   VARCHAR(100),
    customer_age         INT,
    customer_email       VARCHAR(255),
    customer_country     VARCHAR(100),
    customer_postal_code VARCHAR(20),
    customer_pet_type    VARCHAR(50),
    customer_pet_name    VARCHAR(100),
    customer_pet_breed   VARCHAR(100),
    seller_first_name    VARCHAR(100),
    seller_last_name     VARCHAR(100),
    seller_email         VARCHAR(255),
    seller_country       VARCHAR(100),
    seller_postal_code   VARCHAR(20),
    product_name         VARCHAR(255),
    product_category     VARCHAR(50),
    product_price        NUMERIC(10,2),
    product_quantity     INT,
    sale_date            VARCHAR(20),
    sale_customer_id     INT,
    sale_seller_id       INT,
    sale_product_id      INT,
    sale_quantity        INT,
    sale_total_price     NUMERIC(12,2),
    store_name           VARCHAR(255),
    store_location       VARCHAR(255),
    store_city           VARCHAR(255),
    store_state          VARCHAR(100),
    store_country        VARCHAR(100),
    store_phone          VARCHAR(30),
    store_email          VARCHAR(255),
    pet_category         VARCHAR(50),
    product_weight       NUMERIC(8,2),
    product_color        VARCHAR(50),
    product_size         VARCHAR(20),
    product_brand        VARCHAR(255),
    product_material     VARCHAR(50),
    product_description  TEXT,
    product_rating       NUMERIC(3,1),
    product_reviews      INT,
    product_release_date VARCHAR(20),
    product_expiry_date  VARCHAR(20),
    supplier_name        VARCHAR(255),
    supplier_contact     VARCHAR(255),
    supplier_email       VARCHAR(255),
    supplier_phone       VARCHAR(30),
    supplier_address     VARCHAR(255),
    supplier_city        VARCHAR(255),
    supplier_country     VARCHAR(100)
);

CREATE TABLE dim_country (
    country_id   SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dim_city (
    city_id     SERIAL PRIMARY KEY,
    city_name   VARCHAR(255) NOT NULL,
    state_name  VARCHAR(100),
    country_id  INT NOT NULL REFERENCES dim_country(country_id),
    UNIQUE NULLS NOT DISTINCT (city_name, state_name, country_id)
);

CREATE TABLE dim_pet (
    pet_id    SERIAL PRIMARY KEY,
    pet_type  VARCHAR(50) NOT NULL,
    pet_name  VARCHAR(100) NOT NULL,
    pet_breed VARCHAR(100) NOT NULL,
    UNIQUE (pet_type, pet_name, pet_breed)
);

CREATE TABLE dim_product_category (
    category_id    SERIAL PRIMARY KEY,
    category_name  VARCHAR(50) NOT NULL,
    pet_category   VARCHAR(50) NOT NULL,
    UNIQUE (category_name, pet_category)
);

CREATE TABLE dim_brand (
    brand_id    SERIAL PRIMARY KEY,
    brand_name  VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE dim_material (
    material_id    SERIAL PRIMARY KEY,
    material_name  VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE dim_date (
    date_id      SERIAL PRIMARY KEY,
    full_date    DATE NOT NULL UNIQUE,
    day_num      INT NOT NULL,
    month_num    INT NOT NULL,
    year_num     INT NOT NULL,
    quarter_num  INT NOT NULL,
    day_of_week  VARCHAR(15) NOT NULL
);

CREATE TABLE dim_customer (
    customer_id  SERIAL PRIMARY KEY,
    first_name   VARCHAR(100) NOT NULL,
    last_name    VARCHAR(100) NOT NULL,
    age          INT,
    email        VARCHAR(255) NOT NULL,
    postal_code  VARCHAR(20),
    country_id   INT REFERENCES dim_country(country_id),
    pet_id       INT REFERENCES dim_pet(pet_id),
    UNIQUE NULLS NOT DISTINCT (first_name, last_name, email, country_id, pet_id)
);

CREATE TABLE dim_seller (
    seller_id    SERIAL PRIMARY KEY,
    first_name   VARCHAR(100) NOT NULL,
    last_name    VARCHAR(100) NOT NULL,
    email        VARCHAR(255) NOT NULL,
    postal_code  VARCHAR(20),
    country_id   INT REFERENCES dim_country(country_id),
    UNIQUE NULLS NOT DISTINCT (first_name, last_name, email, country_id)
);

CREATE TABLE dim_product (
    product_id     SERIAL PRIMARY KEY,
    name           VARCHAR(255) NOT NULL,
    price          NUMERIC(10,2),
    quantity       INT,
    weight         NUMERIC(8,2),
    color          VARCHAR(50),
    size_name      VARCHAR(20),
    description    TEXT,
    rating         NUMERIC(3,1),
    reviews        INT,
    release_date   DATE,
    expiry_date    DATE,
    category_id    INT REFERENCES dim_product_category(category_id),
    brand_id       INT REFERENCES dim_brand(brand_id),
    material_id    INT REFERENCES dim_material(material_id),
    UNIQUE NULLS NOT DISTINCT (name, price, category_id, brand_id, material_id)
);

CREATE TABLE dim_store (
    store_id    SERIAL PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    location    VARCHAR(255),
    phone       VARCHAR(30),
    email       VARCHAR(255),
    city_id     INT REFERENCES dim_city(city_id),
    UNIQUE NULLS NOT DISTINCT (name, city_id)
);

CREATE TABLE dim_supplier (
    supplier_id  SERIAL PRIMARY KEY,
    name         VARCHAR(255) NOT NULL,
    contact      VARCHAR(255),
    email        VARCHAR(255),
    phone        VARCHAR(30),
    address      VARCHAR(255),
    city_id      INT REFERENCES dim_city(city_id),
    UNIQUE NULLS NOT DISTINCT (name, email, city_id)
);

CREATE TABLE fact_sales (
    sale_id           SERIAL PRIMARY KEY,
    date_id           INT NOT NULL REFERENCES dim_date(date_id),
    customer_id       INT NOT NULL REFERENCES dim_customer(customer_id),
    seller_id         INT NOT NULL REFERENCES dim_seller(seller_id),
    product_id        INT NOT NULL REFERENCES dim_product(product_id),
    store_id          INT NOT NULL REFERENCES dim_store(store_id),
    supplier_id       INT NOT NULL REFERENCES dim_supplier(supplier_id),
    sale_quantity     INT NOT NULL,
    sale_total_price  NUMERIC(12,2) NOT NULL
);
