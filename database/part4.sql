-- For the weather_data table (hourly data)
ALTER TABLE weather_data
ADD COLUMN temperature_delta FLOAT8;

-- For the daily_weather_data table (daily data)
ALTER TABLE daily_weather_data
ADD COLUMN temperature_delta FLOAT8;

-- Calculate and update the 'temperature_delta' values for the 'weather_data' table.
WITH previous_temps AS (
    SELECT
        record_id,
        temperature - LAG(temperature) OVER (PARTITION BY locality, country ORDER BY datetime) AS temperature_delta
    FROM
        weather_data
)
UPDATE weather_data
SET temperature_delta = previous_temps.temperature_delta
FROM previous_temps
WHERE weather_data.record_id = previous_temps.record_id;

-- Calculate and update the 'temperature_delta' values for the 'daily_weather_data' table.
WITH previous_temps AS (
    SELECT
        record_id,
        temperature_fahrenheit - LAG(temperature_fahrenheit) OVER (PARTITION BY locality, country ORDER BY date) AS temperature_delta
    FROM
        daily_weather_data
)
UPDATE daily_weather_data
SET temperature_delta = previous_temps.temperature_delta
FROM previous_temps
WHERE daily_weather_data.record_id = previous_temps.record_id;

-- Create a function to automatically calculate the temperature delta for each new record in the 'weather_data' table.
CREATE OR REPLACE FUNCTION calculate_temperature_delta_hourly()
RETURNS TRIGGER AS $$
BEGIN
    NEW.temperature_delta := NEW.temperature - (
        SELECT temperature
        FROM weather_data
        WHERE locality = NEW.locality
          AND country = NEW.country
          AND datetime < NEW.datetime
        ORDER BY datetime DESC
        LIMIT 1
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger that automatically calculates the temperature delta before inserting a new record into the 'weather_data' table.
CREATE TRIGGER trg_calculate_temperature_delta_hourly
BEFORE INSERT ON weather_data
FOR EACH ROW
EXECUTE FUNCTION calculate_temperature_delta_hourly();


-- Create a function to automatically calculate the temperature delta for each new record in the 'daily_weather_data' table.
CREATE OR REPLACE FUNCTION calculate_temperature_delta_daily()
RETURNS TRIGGER AS $$
BEGIN
    NEW.temperature_delta := NEW.temperature_fahrenheit - (
        SELECT temperature_fahrenheit
        FROM daily_weather_data
        WHERE locality = NEW.locality
          AND country = NEW.country
          AND date < NEW.date
        ORDER BY date DESC
        LIMIT 1
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger that automatically calculates the temperature delta before inserting a new record into the 'daily_weather_data' table.
CREATE TRIGGER trg_calculate_temperature_delta_daily
BEFORE INSERT ON daily_weather_data
FOR EACH ROW
EXECUTE FUNCTION calculate_temperature_delta_daily();


