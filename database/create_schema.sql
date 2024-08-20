-- Create a new PostgreSQL user
CREATE USER test_rootz WITH PASSWORD 'test_rootz';

-- Create a new schema named 'test_rootz'
CREATE SCHEMA test_rootz;

-- Change the ownership of the 'test_rootz' schema to the 'test_rootz' user
ALTER SCHEMA test_rootz OWNER TO test_rootz;

-- Grant all privileges on the 'test_rootz' schema to the 'test_rootz' user
GRANT ALL PRIVILEGES ON SCHEMA test_rootz TO test_rootz;

-- Set the default search path for the 'test_rootz' user to include the 'test_rootz' schema
ALTER ROLE test_rootz SET search_path TO test_rootz;
