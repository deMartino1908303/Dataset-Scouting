-- 1. Optimized: Count restaurants per country
CREATE INDEX idx_country_code ON restaurant_address (country_code);
SELECT c.country, COUNT(a.restaurant_id) AS total_restaurants
FROM restaurant_address a
JOIN countries c ON a.country_code = c.country_code
GROUP BY c.country
ORDER BY total_restaurants DESC;

-- 2. Optimized: Highest-rated restaurant per country using materialized view
CREATE MATERIALIZED VIEW highest_rated AS
SELECT DISTINCT ON (c.country) c.country, r.restaurant_name, rt.aggregate_rating
FROM restaurants r
JOIN rating rt ON r.restaurant_id = rt.restaurant_id
JOIN restaurant_address a ON r.restaurant_id = a.restaurant_id
JOIN countries c ON a.country_code = c.country_code
ORDER BY c.country, rt.aggregate_rating DESC;

SELECT * FROM highest_rated;

-- 3. Optimized: Find restaurants by cuisine with index
CREATE INDEX idx_cuisines ON restaurants (cuisines);
SELECT r.restaurant_name, a.city, c.country, r.cuisines
FROM restaurants r
JOIN restaurant_address a ON r.restaurant_id = a.restaurant_id
JOIN countries c ON a.country_code = c.country_code
WHERE r.cuisines LIKE '%Italian%' AND r.cuisines LIKE '%Japanese%';

-- 4. Optimized: Find closest restaurants using index and bounding box
CREATE INDEX idx_coordinates ON coordinates (longitude, latitude);
SELECT r.restaurant_name, a.city, c.country, co.longitude, co.latitude
FROM restaurants r
JOIN restaurant_address a ON r.restaurant_id = a.restaurant_id
JOIN countries c ON a.country_code = c.country_code
JOIN coordinates co ON r.restaurant_id = co.restaurant_id
WHERE co.longitude BETWEEN -82.5 AND -74.5
  AND co.latitude BETWEEN 33 AND 44
ORDER BY (POW(co.longitude - (-74.0060), 2) + POW(co.latitude - 40.7128, 2)) ASC
LIMIT 5;
