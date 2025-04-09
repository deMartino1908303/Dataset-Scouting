-- Create table for whole dataset
CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name TEXT,
    country_code INT,
    city TEXT,
    address TEXT,
    locality TEXT,
    locality_verbose TEXT,
    longitude FLOAT,
    latitude FLOAT,
    cuisines TEXT,
    average_cost_for_two INT,
    currency TEXT,
    has_table_booking BOOLEAN,
    has_online_delivery BOOLEAN,
    is_delivering_now BOOLEAN,
    switch_to_order_menu BOOLEAN,
    price_range INT,
    aggregate_rating FLOAT,
    rating_color TEXT,
    rating_text TEXT,
    votes INT
);
-- Copy data from CSV File to Table
copy restaurants (
    restaurant_id, 
    restaurant_name, 
    country_code, 
    city, 
    address, 
    locality, 
    locality_verbose, 
    longitude, 
    latitude, 
    cuisines, 
    average_cost_for_two, 
    currency, 
    has_table_booking, 
    has_online_delivery, 
    is_delivering_now, 
    switch_to_order_menu, 
    price_range, 
    aggregate_rating, 
    rating_color, 
    rating_text, 
    votes
) 
FROM 'C:\Users\Public\DM_data\new_dataset.csv' 
DELIMITER ',' 
CSV HEADER;

-- Coutries Table
CREATE TABLE countries (
    country_code INT PRIMARY KEY,
    country TEXT
);

COPY countries (
    country_code,
    country
)
FROM 'C:\Users\Public\DM_data\Country-Code.csv'
DELIMITER ','
CSV HEADER;

-- Address Table
CREATE TABLE restaurant_address (
    restaurant_id INT PRIMARY KEY,
    country_code INT,
    city VARCHAR(100),
    address VARCHAR(255),
    locality VARCHAR(100),
    FOREIGN KEY (country_code) REFERENCES countries(country_code) ON DELETE CASCADE
);

-- Fill Address table
INSERT INTO restaurant_address (restaurant_id, country_code, city, address, locality)
SELECT restaurant_id, country_code, city, address, locality
FROM restaurants;

-- Coordinates Table
CREATE TABLE coordinates (
    restaurant_id INT PRIMARY KEY,
    country_code INT,
    longitude FLOAT,
    latitude FLOAT,
    FOREIGN KEY (country_code) REFERENCES countries(country_code) ON DELETE CASCADE
);

-- Fill coordinates table
INSERT INTO coordinates (restaurant_id, country_code, longitude, latitude)
SELECT restaurant_id, country_code, longitude, latitude
FROM restaurants;

-- Rating table
CREATE TABLE rating (
    restaurant_id INT PRIMARY KEY,
    price_range INT,
    aggregate_rating FLOAT,
    rating_color TEXT,
    rating_text TEXT,
    votes INT
);

-- Fill rating table
INSERT INTO rating (restaurant_id, price_range, aggregate_rating, rating_color, rating_text, votes)
SELECT restaurant_id, price_range, aggregate_rating, rating_color, rating_text, votes
FROM restaurants;

-- add currency info to the rating
ALTER TABLE rating ADD COLUMN currency TEXT;

UPDATE rating
SET currency = r.currency
FROM restaurants r
WHERE rating.restaurant_id = r.restaurant_id;

-- verify if the column is added correctly
SELECT currency, restaurant_id from rating;


-- add currency info to the adress
ALTER TABLE restaurant_address ADD COLUMN currency TEXT;

UPDATE restaurant_address
SET currency = r.currency
FROM restaurants r
WHERE restaurant_address.restaurant_id = r.restaurant_id;

-- verify if the column is added correctly
SELECT currency, restaurant_id from restaurant_address;

ALTER TABLE restaurants 
DROP COLUMN country_code, 
DROP COLUMN city, 
DROP COLUMN address, 
DROP COLUMN locality, 
DROP COLUMN locality_verbose, 
DROP COLUMN longitude, 
DROP COLUMN latitude,
DROP COLUMN currency,
DROP COLUMN has_table_booking, 
DROP COLUMN has_online_delivery, 
DROP COLUMN is_delivering_now, 
DROP COLUMN switch_to_order_menu,
DROP COLUMN price_range,
DROP COLUMN aggregate_rating,
DROP COLUMN rating_color,
DROP COLUMN rating_text,
DROP COLUMN votes;


-- Check if data have been imported correctly
SELECT * FROM restaurants;
SELECT * FROM coordinates;
SELECT * FROM countries;
SELECT * FROM rating;
SELECT * FROM restaurant_address;