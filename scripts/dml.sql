INSERT INTO dim_country (country_name)
SELECT DISTINCT country_name
FROM (
    SELECT customer_country AS country_name
    FROM mock_data
    WHERE customer_country IS NOT NULL AND customer_country <> ''
    UNION
    SELECT seller_country
    FROM mock_data
    WHERE seller_country IS NOT NULL AND seller_country <> ''
    UNION
    SELECT store_country
    FROM mock_data
    WHERE store_country IS NOT NULL AND store_country <> ''
    UNION
    SELECT supplier_country
    FROM mock_data
    WHERE supplier_country IS NOT NULL AND supplier_country <> ''
) AS countries
ORDER BY country_name;

INSERT INTO dim_city (city_name, state_name, country_id)
SELECT DISTINCT
    m.store_city,
    NULLIF(TRIM(m.store_state), ''),
    c.country_id
FROM mock_data m
JOIN dim_country c
  ON c.country_name = m.store_country
WHERE m.store_city IS NOT NULL
  AND m.store_city <> '';

INSERT INTO dim_city (city_name, state_name, country_id)
SELECT DISTINCT
    m.supplier_city,
    NULL,
    c.country_id
FROM mock_data m
JOIN dim_country c
  ON c.country_name = m.supplier_country
WHERE m.supplier_city IS NOT NULL
  AND m.supplier_city <> ''
  AND NOT EXISTS (
      SELECT 1
      FROM dim_city dc
      WHERE dc.city_name = m.supplier_city
        AND dc.country_id = c.country_id
        AND dc.state_name IS NULL
  );

INSERT INTO dim_pet (pet_type, pet_name, pet_breed)
SELECT DISTINCT
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed
FROM mock_data
WHERE customer_pet_type IS NOT NULL
  AND customer_pet_type <> ''
  AND customer_pet_name IS NOT NULL
  AND customer_pet_name <> ''
  AND customer_pet_breed IS NOT NULL
  AND customer_pet_breed <> '';

INSERT INTO dim_product_category (category_name, pet_category)
SELECT DISTINCT
    product_category,
    pet_category
FROM mock_data
WHERE product_category IS NOT NULL
  AND product_category <> ''
  AND pet_category IS NOT NULL
  AND pet_category <> '';

INSERT INTO dim_brand (brand_name)
SELECT DISTINCT product_brand
FROM mock_data
WHERE product_brand IS NOT NULL
  AND product_brand <> ''
ORDER BY product_brand;

INSERT INTO dim_material (material_name)
SELECT DISTINCT product_material
FROM mock_data
WHERE product_material IS NOT NULL
  AND product_material <> ''
ORDER BY product_material;

INSERT INTO dim_date (full_date, day_num, month_num, year_num, quarter_num, day_of_week)
SELECT DISTINCT
    d,
    EXTRACT(DAY FROM d)::INT,
    EXTRACT(MONTH FROM d)::INT,
    EXTRACT(YEAR FROM d)::INT,
    EXTRACT(QUARTER FROM d)::INT,
    TRIM(TO_CHAR(d, 'Day'))
FROM (
    SELECT TO_DATE(sale_date, 'MM/DD/YYYY') AS d
    FROM mock_data
    WHERE sale_date IS NOT NULL
      AND sale_date <> ''
) AS dates
ORDER BY d;

INSERT INTO dim_customer (first_name, last_name, age, email, postal_code, country_id, pet_id)
SELECT DISTINCT
    m.customer_first_name,
    m.customer_last_name,
    m.customer_age,
    m.customer_email,
    NULLIF(TRIM(m.customer_postal_code), ''),
    c.country_id,
    p.pet_id
FROM mock_data m
JOIN dim_country c
  ON c.country_name = m.customer_country
LEFT JOIN dim_pet p
  ON p.pet_type = m.customer_pet_type
 AND p.pet_name = m.customer_pet_name
 AND p.pet_breed = m.customer_pet_breed;

INSERT INTO dim_seller (first_name, last_name, email, postal_code, country_id)
SELECT DISTINCT
    m.seller_first_name,
    m.seller_last_name,
    m.seller_email,
    NULLIF(TRIM(m.seller_postal_code), ''),
    c.country_id
FROM mock_data m
JOIN dim_country c
  ON c.country_name = m.seller_country;

INSERT INTO dim_product (
    name,
    price,
    quantity,
    weight,
    color,
    size_name,
    description,
    rating,
    reviews,
    release_date,
    expiry_date,
    category_id,
    brand_id,
    material_id
)
SELECT DISTINCT
    m.product_name,
    m.product_price,
    m.product_quantity,
    m.product_weight,
    m.product_color,
    m.product_size,
    m.product_description,
    m.product_rating,
    m.product_reviews,
    CASE
        WHEN m.product_release_date <> '' THEN TO_DATE(m.product_release_date, 'MM/DD/YYYY')
        ELSE NULL
    END,
    CASE
        WHEN m.product_expiry_date <> '' THEN TO_DATE(m.product_expiry_date, 'MM/DD/YYYY')
        ELSE NULL
    END,
    pc.category_id,
    b.brand_id,
    mt.material_id
FROM mock_data m
LEFT JOIN dim_product_category pc
  ON pc.category_name = m.product_category
 AND pc.pet_category = m.pet_category
LEFT JOIN dim_brand b
  ON b.brand_name = m.product_brand
LEFT JOIN dim_material mt
  ON mt.material_name = m.product_material;

INSERT INTO dim_store (name, location, phone, email, city_id)
SELECT DISTINCT
    m.store_name,
    m.store_location,
    m.store_phone,
    m.store_email,
    dc.city_id
FROM mock_data m
JOIN dim_country co
  ON co.country_name = m.store_country
JOIN dim_city dc
  ON dc.city_name = m.store_city
 AND dc.country_id = co.country_id
 AND (
      dc.state_name = NULLIF(TRIM(m.store_state), '')
      OR (dc.state_name IS NULL AND NULLIF(TRIM(m.store_state), '') IS NULL)
 );

INSERT INTO dim_supplier (name, contact, email, phone, address, city_id)
SELECT DISTINCT ON (src.supplier_name, src.supplier_email, src.city_id)
    src.supplier_name,
    src.supplier_contact,
    src.supplier_email,
    src.supplier_phone,
    src.supplier_address,
    src.city_id
FROM (
    SELECT
        m.supplier_name,
        NULLIF(TRIM(m.supplier_contact), '') AS supplier_contact,
        NULLIF(TRIM(m.supplier_email), '') AS supplier_email,
        NULLIF(TRIM(m.supplier_phone), '') AS supplier_phone,
        NULLIF(TRIM(m.supplier_address), '') AS supplier_address,
        dc.city_id
    FROM mock_data m
    JOIN dim_country co
      ON co.country_name = m.supplier_country
    JOIN dim_city dc
      ON dc.city_name = m.supplier_city
     AND dc.country_id = co.country_id
     AND dc.state_name IS NULL
) AS src
ORDER BY
    src.supplier_name,
    src.supplier_email,
    src.city_id,
    (src.supplier_contact IS NULL),
    (src.supplier_phone IS NULL),
    (src.supplier_address IS NULL),
    src.supplier_contact,
    src.supplier_phone,
    src.supplier_address;

INSERT INTO fact_sales (
    date_id,
    customer_id,
    seller_id,
    product_id,
    store_id,
    supplier_id,
    sale_quantity,
    sale_total_price
)
SELECT
    d.date_id,
    cust.customer_id,
    sel.seller_id,
    prod.product_id,
    st.store_id,
    sup.supplier_id,
    m.sale_quantity,
    m.sale_total_price
FROM mock_data m
JOIN dim_date d
  ON d.full_date = TO_DATE(m.sale_date, 'MM/DD/YYYY')
JOIN dim_country cc
  ON cc.country_name = m.customer_country
LEFT JOIN dim_pet pet
  ON pet.pet_type = m.customer_pet_type
 AND pet.pet_name = m.customer_pet_name
 AND pet.pet_breed = m.customer_pet_breed
JOIN dim_customer cust
  ON cust.first_name = m.customer_first_name
 AND cust.last_name = m.customer_last_name
 AND cust.email = m.customer_email
 AND cust.country_id = cc.country_id
 AND cust.pet_id IS NOT DISTINCT FROM pet.pet_id
JOIN dim_country sc
  ON sc.country_name = m.seller_country
JOIN dim_seller sel
  ON sel.first_name = m.seller_first_name
 AND sel.last_name = m.seller_last_name
 AND sel.email = m.seller_email
 AND sel.country_id = sc.country_id
LEFT JOIN dim_product_category pc
  ON pc.category_name = m.product_category
 AND pc.pet_category = m.pet_category
LEFT JOIN dim_brand b
  ON b.brand_name = m.product_brand
LEFT JOIN dim_material mt
  ON mt.material_name = m.product_material
JOIN dim_product prod
  ON prod.name = m.product_name
 AND prod.price = m.product_price
 AND prod.category_id IS NOT DISTINCT FROM pc.category_id
 AND prod.brand_id IS NOT DISTINCT FROM b.brand_id
 AND prod.material_id IS NOT DISTINCT FROM mt.material_id
JOIN dim_country stc
  ON stc.country_name = m.store_country
JOIN dim_city stci
  ON stci.city_name = m.store_city
 AND stci.country_id = stc.country_id
 AND (
      stci.state_name = NULLIF(TRIM(m.store_state), '')
      OR (stci.state_name IS NULL AND NULLIF(TRIM(m.store_state), '') IS NULL)
 )
JOIN dim_store st
  ON st.name = m.store_name
 AND st.city_id = stci.city_id
JOIN dim_country suc
  ON suc.country_name = m.supplier_country
JOIN dim_city suci
  ON suci.city_name = m.supplier_city
 AND suci.country_id = suc.country_id
 AND suci.state_name IS NULL
JOIN dim_supplier sup
  ON sup.name = m.supplier_name
 AND sup.email IS NOT DISTINCT FROM NULLIF(TRIM(m.supplier_email), '')
 AND sup.city_id = suci.city_id;
