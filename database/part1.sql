-- Create the table 'weather_data' if it does not already exist.
CREATE TABLE IF NOT EXISTS weather_data (
    record_id SERIAL PRIMARY KEY,
    locality VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    temperature FLOAT8 NOT NULL,
    datetime TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    cloud_coverage VARCHAR(100) NOT NULL,
    uv_index INT NOT NULL,
    atmospheric_pressure FLOAT8 NOT NULL,
    wind_speed FLOAT8 NOT NULL,
    UNIQUE(datetime, locality, country)
);


-- Insert 5000 random records into the 'weather_data' table.
DO $$
BEGIN
    FOR i IN 1..5000 LOOP
        INSERT INTO weather_data (locality, country, temperature, datetime, cloud_coverage, uv_index, atmospheric_pressure, wind_speed)
        VALUES (
            -- Random locality from a list
            (ARRAY['Locality1', 'Locality2', 'Locality3', 'Locality4', 'Locality5'])[floor(random() * 5 + 1)],
            -- Random country from a list
            (ARRAY['Country1', 'Country2', 'Country3', 'Country4', 'Country5'])[floor(random() * 5 + 1)],
            -- Random temperature between -10 and 40 degrees Celsius
            round((random() * 50 - 10)::numeric, 2),
            -- Random datetime between 2020-01-01 and 2023-12-31
            timestamp '2020-01-01' + random() * (timestamp '2023-12-31' - timestamp '2020-01-01'),
            -- Random cloud coverage from a list
            (ARRAY['Clear', 'Partial', 'Cloudy', 'Overcast'])[floor(random() * 4 + 1)],
            -- Random UV index between 0 and 11
            floor(random() * 12)::int,
            -- Random atmospheric pressure between 950 and 1050 hPa
            round((random() * 100 + 950)::numeric, 2),
            -- Random wind speed between 0 and 40 knots
            round((random() * 40)::numeric, 2)
        );
    END LOOP;
END $$;

