-- 1. Count the number of restaurants per country
SELECT c.country, COUNT(r.restaurant_id) AS total_restaurants
FROM restaurants r
JOIN restaurant_address a ON r.restaurant_id = a.restaurant_id
JOIN countries c ON a.country_code = c.country_code
GROUP BY c.country
ORDER BY total_restaurants DESC;

-- 2. Find the highest-rated restaurant in each country
SELECT DISTINCT ON (c.country) c.country, r.restaurant_name, r.aggregate_rating
FROM restaurants r
JOIN restaurant_address a ON r.restaurant_id = a.restaurant_id
JOIN countries c ON a.country_code = c.country_code
ORDER BY c.country, r.aggregate_rating DESC;

-- 3. Find restaurants by cuisine
SELECT r.restaurant_name, a.city, c.country, r.cuisines
FROM restaurants r
JOIN restaurant_address a ON r.restaurant_id = a.restaurant_id
JOIN countries c ON a.country_code = c.country_code
WHERE r.cuisines ILIKE '%Italian%' OR r.cuisines ILIKE '%Japanese%';

-- 4. Find closest restaurants to a given location
SELECT r.restaurant_name, a.city, c.country, co.longitude, co.latitude,
       ( 6371 * ACOS(COS(RADIANS(40.7128)) * COS(RADIANS(co.latitude))
       * COS(RADIANS(co.longitude) - RADIANS(-74.0060))
       + SIN(RADIANS(40.7128)) * SIN(RADIANS(co.latitude))) ) AS distance_km
FROM restaurants r
JOIN restaurant_address a ON r.restaurant_id = a.restaurant_id
JOIN countries c ON a.country_code = c.country_code
JOIN coordinates co ON r.restaurant_id = co.restaurant_id
ORDER BY distance_km ASC
LIMIT 5;

SELECT * FROM coordinates

-- 5. Get average rating per country
SELECT c.country, AVG(r.aggregate_rating) AS avg_rating
FROM restaurants r
JOIN restaurant_address a ON r.restaurant_id = a.restaurant_id
JOIN countries c ON a.country_code = c.country_code
GROUP BY c.country
HAVING AVG(r.aggregate_rating) > 4
ORDER BY avg_rating DESC;

-- 6. Find restaurants that offer online delivery
SELECT r.restaurant_name, a.city, c.country
FROM restaurants r
JOIN restaurant_address a ON r.restaurant_id = a.restaurant_id
JOIN countries c ON a.country_code = c.country_code
WHERE r.has_online_delivery = TRUE;

-- 7. Get the price range distribution of restaurants
SELECT price_range, COUNT(*) AS total
FROM restaurants
GROUP BY price_range
ORDER BY price_range;

-- 8. Find the most voted restaurant in each country
SELECT DISTINCT ON (c.country) c.country, r.restaurant_name, r.votes
FROM restaurants r
JOIN restaurant_address a ON r.restaurant_id = a.restaurant_id
JOIN countries c ON a.country_code = c.country_code
ORDER BY c.country, r.votes DESC;

-- 9. Get restaurants with the highest rating in each price range
SELECT price_range, restaurant_name, aggregate_rating
FROM (
    SELECT price_range, restaurant_name, aggregate_rating,
           RANK() OVER (PARTITION BY price_range ORDER BY aggregate_rating DESC) AS rank
    FROM restaurants
) ranked
WHERE rank = 1;

-- 10. Get restaurants that have both high rating and many votes
SELECT r.restaurant_name, r.aggregate_rating, r.votes
FROM restaurants r
WHERE r.aggregate_rating > 4.5 AND r.votes > 1000
ORDER BY r.aggregate_rating DESC, r.votes DESC;
