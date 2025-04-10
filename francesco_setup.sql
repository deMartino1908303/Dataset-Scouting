-- FRESH START OF SETUP
DROP TABLE IF EXISTS rating CASCADE;
DROP TABLE IF EXISTS coordinates CASCADE;
DROP TABLE IF EXISTS restaurant_address CASCADE;
DROP TABLE IF EXISTS restaurants CASCADE;
DROP TABLE IF EXISTS countries CASCADE;




-- Create the main 'restaurants' table
CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name TEXT NOT NULL,
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
    price_range INT CHECK (price_range >= 1 AND price_range <= 4),  -- Check constraint for valid price range
    aggregate_rating FLOAT CHECK (aggregate_rating >= 0 AND aggregate_rating <= 5),  -- Check constraint for valid rating
    rating_color TEXT,
    rating_text TEXT,
    votes INT,
    UNIQUE (restaurant_id)  -- Ensure unique restaurant_id
);

-- Load data from the main CSV file into the 'restaurants' table
COPY restaurants (
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

-- Create table for countries with unique country codes
CREATE TABLE countries (
    country_code INT PRIMARY KEY,
    country TEXT NOT NULL,
    UNIQUE (country_code)  -- Ensure unique country_code
);

-- Load country codes and names from CSV
COPY countries (
    country_code,
    country
)
FROM 'C:\Users\Public\DM_data\Country-Code.csv'
DELIMITER ',' 
CSV HEADER;

-- Create separate table for restaurant addresses and location info
CREATE TABLE restaurant_address (
    restaurant_id INT PRIMARY KEY,
    country_code INT NOT NULL,
    city TEXT NOT NULL,  -- Ensure city is not NULL
    address TEXT NOT NULL,  -- Ensure address is not NULL
    locality TEXT,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (country_code) REFERENCES countries(country_code) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (restaurant_id)  -- Ensure unique restaurant_id
);

-- Insert address-related data from main table into 'restaurant_address'
INSERT INTO restaurant_address (restaurant_id, country_code, city, address, locality)
SELECT restaurant_id, country_code, city, address, locality
FROM restaurants;

-- Create table for storing geographical coordinates
CREATE TABLE coordinates (
    restaurant_id INT PRIMARY KEY,
    country_code INT NOT NULL,
    longitude FLOAT,
    latitude FLOAT,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (country_code) REFERENCES countries(country_code) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (restaurant_id)  -- Ensure unique restaurant_id
);

-- Insert coordinates from the main table
INSERT INTO coordinates (restaurant_id, country_code, longitude, latitude)
SELECT restaurant_id, country_code, longitude, latitude
FROM restaurants;

-- Create table for ratings and pricing info
CREATE TABLE rating (
    restaurant_id INT PRIMARY KEY,
    price_range INT CHECK (price_range >= 1 AND price_range <= 4),  -- Check constraint for valid price range
    aggregate_rating FLOAT CHECK (aggregate_rating >= 0 AND aggregate_rating <= 5),  -- Check constraint for valid rating
    rating_color TEXT,
    rating_text TEXT,
    votes INT,
    currency TEXT,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (restaurant_id)  -- Ensure unique restaurant_id
);

-- Insert rating-related data from main table
INSERT INTO rating (restaurant_id, price_range, aggregate_rating, rating_color, rating_text, votes, currency)
SELECT restaurant_id, price_range, aggregate_rating, rating_color, rating_text, votes, currency
FROM restaurants;

-- Verify if the 'currency' column is added correctly to rating tables
SELECT currency, restaurant_id FROM rating;

-- Drop redundant columns from the main restaurants table
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
DROP COLUMN is_delivering_now, 
DROP COLUMN switch_to_order_menu,
DROP COLUMN price_range,
DROP COLUMN aggregate_rating,
DROP COLUMN rating_color,
DROP COLUMN rating_text,
DROP COLUMN votes;

-- Final verification queries to check that the data was split correctly
SELECT * FROM restaurants;
SELECT * FROM coordinates;
SELECT * FROM countries;
SELECT * FROM rating;
SELECT * FROM restaurant_address;
