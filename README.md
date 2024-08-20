# SQL and Tableau Server Automation Challenge

This repository contains solutions to the SQL and scripting challenges. The tasks involve setting up database schemas, optimizing large datasets, and automating the installation and verification of Tableau Server on a Linux environment.

## Table of Contents

- [System Requirements](#system-requirements)
- [Part 1: SQL Challenge](#part-1-sql-challenge)
  - [Schema Creation](#schema-creation)
  - [Optimization for Large Datasets](#optimization-for-large-datasets)
  - [Data Conversion and Aggregation](#data-conversion-and-aggregation)
  - [Temperature Delta Calculation](#temperature-delta-calculation)
- [Part 2: Tableau Server Automation](#part-2-tableau-server-automation)
  - [Installation Script](#installation-script)
  - [Uninstallation Script](#uninstallation-script)
- [Usage](#usage)

## System Requirements

- **Operating System:** Ubuntu 22.04
- **Database:** PostgreSQL 16.3

## Part 1: SQL Challenge

### Schema Creation

The SQL scripts in the `database/` directory define the schema for a weather data table. This table is designed to collect weather data on an hourly basis across different regions.

- **`part1.sql`**: 
  - Creates the `weather_data` table with columns for locality, country, temperature, datetime, cloud coverage, UV index, atmospheric pressure, and wind speed.
  - Ensures data integrity with unique constraints and primary keys.

### Optimization for Large Datasets

As the table grows, optimizations are necessary to maintain performance.

- **`part2.sql`**:
  - Adds composite indexes to optimize query performance.
  - Implements partitioning strategies to manage large datasets efficiently.
  - Discusses the potential for data compression and adjustment of `autovacuum` settings for older data.

### Data Conversion and Aggregation

To meet new requirements, the data is converted and aggregated differently.

- **`part3.sql`**:
  - Creates a new table to store temperature in Fahrenheit.
  - Aggregates the data on a daily basis instead of hourly.

### Temperature Delta Calculation

New requirements ask for calculating the temperature difference between records.

- **`part4.sql`**:
  - Implements functions and triggers to calculate the temperature delta between successive records.
  - Updates both the hourly and daily tables to include this delta.

## Part 2: Tableau Server Automation

### Installation Script

The `tableau-server/` directory contains scripts to automate the installation and management of Tableau Server on a Linux environment.

- **`install.sh`**:
  - Updates the system and installs necessary dependencies.
  - Downloads and installs Tableau Server.
  - Initializes Tableau Server and verifies its successful startup.

### Uninstallation Script

For convenience, the repository also includes a script to uninstall Tableau Server.

- **`uninstall.sh`**:
  - Stops the Tableau Server services.
  - Removes Tableau Server from the system.

## Usage

### SQL Scripts

To use the SQL scripts:

1. Navigate to the `database/` directory.
2. Execute each SQL script in sequence (`part1.sql`, `part2.sql`, `part3.sql`, `part4.sql`) using a PostgreSQL client.

### Tableau Server Scripts

To install Tableau Server:

1. Ensure you are running Ubuntu 22.04.
2. Navigate to the `tableau-server/` directory.
3. Run the installation script:
   ```bash
   ./install.sh
