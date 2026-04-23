SELECT 'mock_data' AS table_name, COUNT(*) AS row_count FROM mock_data
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM fact_sales;

SELECT 'dim_country' AS dimension, COUNT(*) AS row_count FROM dim_country
UNION ALL SELECT 'dim_city', COUNT(*) FROM dim_city
UNION ALL SELECT 'dim_pet', COUNT(*) FROM dim_pet
UNION ALL SELECT 'dim_product_category', COUNT(*) FROM dim_product_category
UNION ALL SELECT 'dim_brand', COUNT(*) FROM dim_brand
UNION ALL SELECT 'dim_material', COUNT(*) FROM dim_material
UNION ALL SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL SELECT 'dim_seller', COUNT(*) FROM dim_seller
UNION ALL SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL SELECT 'dim_store', COUNT(*) FROM dim_store
UNION ALL SELECT 'dim_supplier', COUNT(*) FROM dim_supplier;

SELECT 'orphaned_customer' AS check_name, COUNT(*) AS cnt
FROM fact_sales f
LEFT JOIN dim_customer c ON f.customer_id = c.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'orphaned_seller', COUNT(*)
FROM fact_sales f
LEFT JOIN dim_seller s ON f.seller_id = s.seller_id
WHERE s.seller_id IS NULL
UNION ALL
SELECT 'orphaned_product', COUNT(*)
FROM fact_sales f
LEFT JOIN dim_product p ON f.product_id = p.product_id
WHERE p.product_id IS NULL
UNION ALL
SELECT 'orphaned_store', COUNT(*)
FROM fact_sales f
LEFT JOIN dim_store st ON f.store_id = st.store_id
WHERE st.store_id IS NULL
UNION ALL
SELECT 'orphaned_supplier', COUNT(*)
FROM fact_sales f
LEFT JOIN dim_supplier sp ON f.supplier_id = sp.supplier_id
WHERE sp.supplier_id IS NULL
UNION ALL
SELECT 'orphaned_date', COUNT(*)
FROM fact_sales f
LEFT JOIN dim_date d ON f.date_id = d.date_id
WHERE d.date_id IS NULL;

SELECT
    co.country_name,
    COUNT(*) AS sales_count,
    SUM(f.sale_total_price) AS total_revenue
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
JOIN dim_country co ON c.country_id = co.country_id
GROUP BY co.country_name
ORDER BY total_revenue DESC
LIMIT 5;

SELECT
    d.year_num,
    d.quarter_num,
    COUNT(*) AS sales_count,
    SUM(f.sale_total_price) AS total_revenue
FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year_num, d.quarter_num
ORDER BY d.year_num, d.quarter_num;

SELECT
    pc.category_name,
    pc.pet_category,
    COUNT(*) AS sales_count,
    SUM(f.sale_total_price) AS total_revenue
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_product_category pc ON p.category_id = pc.category_id
GROUP BY pc.category_name, pc.pet_category
ORDER BY total_revenue DESC;

SELECT
    pet.pet_type,
    COUNT(*) AS sales_count,
    ROUND(AVG(f.sale_total_price), 2) AS avg_order_value
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
JOIN dim_pet pet ON c.pet_id = pet.pet_id
GROUP BY pet.pet_type
ORDER BY avg_order_value DESC;

SELECT
    st.name AS store_name,
    ci.city_name,
    co.country_name,
    COUNT(*) AS sales_count,
    SUM(f.sale_total_price) AS total_revenue
FROM fact_sales f
JOIN dim_store st ON f.store_id = st.store_id
JOIN dim_city ci ON st.city_id = ci.city_id
JOIN dim_country co ON ci.country_id = co.country_id
GROUP BY st.name, ci.city_name, co.country_name
ORDER BY sales_count DESC
LIMIT 10;
