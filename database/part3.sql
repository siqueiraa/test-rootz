-- Create the table 'daily_weather_data' if it does not already exist.
CREATE TABLE IF NOT EXISTS daily_weather_data (
    record_id SERIAL PRIMARY KEY,
    locality VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    temperature_fahrenheit FLOAT8 NOT NULL,
    date DATE NOT NULL,
    cloud_coverage VARCHAR(100) NOT NULL,
    uv_index INT NOT NULL,
    atmospheric_pressure FLOAT8 NOT NULL,
    wind_speed FLOAT8 NOT NULL,
    UNIQUE(date, locality, country)
);

-- Create an index on the 'daily_weather_data' table for the 'date' and 'locality' columns if it does not already exist.
CREATE INDEX IF NOT EXISTS idx_daily_weather_date_locality ON daily_weather_data(date, locality);
-- Create an index on the 'daily_weather_data' table for the 'date' column if it does not already exist.
CREATE INDEX IF NOT EXISTS idx_daily_weather_date ON daily_weather_data(date);

-- Insert aggregated daily weather data into the 'daily_weather_data' table.
INSERT INTO daily_weather_data (locality, country, temperature_fahrenheit, date, cloud_coverage, uv_index, atmospheric_pressure, wind_speed)
SELECT 
    locality,
    country,
    AVG(temperature * 1.8 + 32) AS temperature_fahrenheit,
    DATE(datetime) AS date,  -- Extract date from datetime
    MAX(cloud_coverage) AS cloud_coverage,
    AVG(uv_index) AS uv_index,
    AVG(atmospheric_pressure) AS atmospheric_pressure,  -- Average pressure of the day
    AVG(wind_speed) AS wind_speed  -- Average wind speed of the day
FROM 
    weather_data
GROUP BY 
    locality, country, DATE(datetime);



