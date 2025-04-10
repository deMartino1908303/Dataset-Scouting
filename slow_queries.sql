-- 1. Count the number of restaurants per country
SELECT c.country, COUNT(r.restaurant_id) AS total_restaurants
FROM restaurants r
JOIN restaurant_address a ON r.restaurant_id = a.restaurant_id
JOIN countries c ON a.country_code = c.country_code
GROUP BY c.country
ORDER BY total_restaurants DESC;

-- 2. Find the highest-rated restaurant in each country
SELECT DISTINCT ON (c.country) c.country, r.restaurant_name, rt.aggregate_rating
FROM restaurants r
JOIN rating rt ON r.restaurant_id = rt.restaurant_id
JOIN restaurant_address a ON r.restaurant_id = a.restaurant_id
JOIN countries c ON a.country_code = c.country_code
ORDER BY c.country, rt.aggregate_rating DESC;

-- 3. Find restaurants by cuisine
SELECT r.restaurant_name, a.city, c.country, r.cuisines
FROM restaurants r
JOIN restaurant_address a ON r.restaurant_id = a.restaurant_id
JOIN countries c ON a.country_code = c.country_code
WHERE r.cuisines ILIKE '%Italian%' AND r.cuisines ILIKE '%Japanese%';

-- 4. Find closest restaurants to a given location (Haversine formula)
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

-- London:        51.5074, -0.1278
-- Paris:         48.8566, 2.3522
-- Rome:          41.9028, 12.4964
-- Tokyo:         35.6895, 139.6917
-- Delhi:         28.6139, 77.2090
-- New York:      40.7128, -74.0060


-- 5. Get average rating per country
SELECT c.country, AVG(rt.aggregate_rating) AS avg_rating
FROM rating rt
JOIN restaurant_address a ON rt.restaurant_id = a.restaurant_id
JOIN countries c ON a.country_code = c.country_code
GROUP BY c.country
HAVING AVG(rt.aggregate_rating) > 4
ORDER BY avg_rating DESC;

-- 6. Find restaurants that offer online delivery
SELECT r.restaurant_name, a.city, c.country
FROM restaurants r
JOIN restaurant_address a ON r.restaurant_id = a.restaurant_id
JOIN countries c ON a.country_code = c.country_code
WHERE r.has_online_delivery = TRUE;

-- 7. Get the price range distribution of restaurants
SELECT price_range, COUNT(*) AS total
FROM rating
GROUP BY price_range
ORDER BY price_range;


-- 8. Find the most voted restaurant in each country
SELECT DISTINCT ON (c.country) c.country, r.restaurant_name, rt.votes
FROM restaurants r
JOIN rating rt ON r.restaurant_id = rt.restaurant_id
JOIN restaurant_address a ON r.restaurant_id = a.restaurant_id
JOIN countries c ON a.country_code = c.country_code
ORDER BY c.country, rt.votes DESC;

-- 9. Get restaurants with the highest rating in each price range
SELECT price_range, restaurant_name, aggregate_rating
FROM (
    SELECT rt.price_range, r.restaurant_name, rt.aggregate_rating,
           RANK() OVER (PARTITION BY rt.price_range ORDER BY rt.aggregate_rating DESC) AS rank
    FROM restaurants r
    JOIN rating rt ON r.restaurant_id = rt.restaurant_id
) ranked
WHERE rank = 1;

-- 10. Get restaurants that have both high rating and many votes
SELECT r.restaurant_name, rt.aggregate_rating, rt.votes
FROM restaurants r
JOIN rating rt ON r.restaurant_id = rt.restaurant_id
WHERE rt.aggregate_rating > 4.5 AND rt.votes > 1000
ORDER BY rt.aggregate_rating DESC, rt.votes DESC;
