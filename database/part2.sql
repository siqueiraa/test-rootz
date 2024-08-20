-- 1 - create a composite index can help
CREATE INDEX IF NOT EXISTS idx_weather_datetime_locality ON weather_data (datetime, locality);
CREATE INDEX IF NOT EXISTS idx_weather_datetime_country ON weather_data (datetime, country);
CREATE INDEX IF NOT EXISTS idx_weather_datetime_country_locality ON weather_data (datetime, country, locality);

-- 2 - Create a new partitioned table structure
CREATE TABLE new_weather_data (
    record_id SERIAL,
    locality VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    temperature FLOAT8 NOT NULL,
    datetime TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    cloud_coverage VARCHAR(100) NOT NULL,
    uv_index INT NOT NULL,
    atmospheric_pressure FLOAT8 NOT NULL,
    wind_speed FLOAT8 NOT NULL,
    UNIQUE(datetime, locality, country)
) PARTITION BY RANGE (datetime);

-- Define partitions
-- Using the 'zstd' compression method because it provides a higher compression ratio, suitable for older, less frequently accessed data.
CREATE TABLE new_weather_data_y2020 PARTITION OF new_weather_data
    FOR VALUES FROM ('2020-01-01') TO ('2021-01-01')
    WITH (autovacuum_enabled = false, toast.compress = 'zstd');

CREATE TABLE new_weather_data_y2021 PARTITION OF new_weather_data
    FOR VALUES FROM ('2021-01-01') TO ('2022-01-01')
    WITH (autovacuum_enabled = false, toast.compress = 'zstd');

-- Using the 'lz4' compression method because it is fast and offers a good balance between speed and compression ratio.
CREATE TABLE new_weather_data_y2022 PARTITION OF new_weather_data
    FOR VALUES FROM ('2022-01-01') TO ('2023-01-01')
    WITH (autovacuum_enabled = false, toast.compress = 'lz4');

CREATE TABLE new_weather_data_y2023 PARTITION OF new_weather_data
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');


-- Configuring more aggressive autovacuum settings for 2023 data to ensure frequent maintenance and optimal performance.
ALTER TABLE weather_data_2023 SET (
    autovacuum_vacuum_threshold = 50,
    autovacuum_vacuum_scale_factor = 0.2,
    autovacuum_analyze_threshold = 50,
    autovacuum_analyze_scale_factor = 0.1
);

-- Configuring aggressive autovacuum settings for 2022 data to maintain performance as it is still frequently accessed.
ALTER TABLE weather_data_2022 SET (
    autovacuum_vacuum_threshold = 50,
    autovacuum_vacuum_scale_factor = 0.2,
    autovacuum_analyze_threshold = 50,
    autovacuum_analyze_scale_factor = 0.1
);

-- Configuring lighter autovacuum settings for 2021 data as it is less frequently accessed.
ALTER TABLE weather_data_2021 SET (
    autovacuum_vacuum_threshold = 500,
    autovacuum_vacuum_scale_factor = 0.5,
    autovacuum_analyze_threshold = 250,
    autovacuum_analyze_scale_factor = 0.5
);

-- Disabling autovacuum for 2020 data as it is considered static and does not require frequent maintenance.
ALTER TABLE weather_data_2020 SET (
    autovacuum_enabled = false
);

-- Copy data from old to new partitioned table
INSERT INTO new_weather_data SELECT * FROM weather_data;

--drop the old table and rename the new one
DROP TABLE weather_data;
ALTER TABLE new_weather_data RENAME TO weather_data;

-- 3 -  Database Maintenance Routines vacuum and analyze the table
VACUUM (VERBOSE, ANALYZE) weather_data;

-- reindex table
REINDEX TABLE weather_data;

