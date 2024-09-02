# ControlDoc Challenge

## Introduction

This project involves creating an application to track vehicles using GPS waypoints. The following technologies were used for the development:

- **Ruby** 3.2.0
- **Rails** 6.1
- **Docker** 27.2.0
- **Docker Compose** 2.29.2
- **PostgreSQL** 16
- **Redis** 5.0.8
- **Google Maps API**

## Design

The application includes three JSON API endpoints, one HTML endpoint to display a map, and a monitoring endpoint for Sidekiq.

### Endpoints

- **/sidekiq**: Monitors queues and workers in Sidekiq.
- **/api/v1/check_api**: Checks if the API is currently operational.
- **/api/v1/latest_waypoints**: Displays the latest waypoints for each vehicle.
- **/api/v1/gps**: Registers GPS measurements from vehicles.
- **/show**: Displays a map showing the latest positions of all vehicles.

### Models

The application includes two primary models:

- **Vehicle**: Stores the `vehicle_identifier`, which is unique and serves as the primary key.
- **Waypoint**: Stores GPS measurement data and is associated with the `Vehicle` model via a foreign key (`vehicle_id`).

## Project Execution

Since this project is containerized with Docker, you can bootstrap and run it with the following commands (assuming Docker is already installed on your machine):

```bash
# Build and start the containers in the background
$ docker compose up --build -d

# Create the database
$ docker compose exec app_backend rake db:create

# Run database migrations
$ docker compose exec app_backend rake db:migrate
```

## Google API

A `GOOGLE_MAPS_API_KEY` has been defined in the `.env` file of the `app_backend` container to work with the Google Maps API in developer mode.

## Environment Variables

Various environment variables have been defined in the `.env` and `.env.postgres` files for configuring the database and related services:

```env
POSTGRES_DB=telemetry-waypoints-db
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_HOST=db_measurements

REDIS_URL=redis://redis:6379/0 
JOB_WORKER_URL=redis://redis:6379/0
GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
```

**Note**: The Redis URLs are intentionally duplicated to allow service separation. This ensures that changes in one service do not affect the others.

## Queues

Only one queue was created for this project:

- **gps_measurement**: Used to queue the jobs managed by the worker.

## Background Jobs

As part of the essential requirements for this challenge, a worker was implemented using the Sidekiq framework. This worker, named `GpsMeasurementsWorker`, operates with a single queue called `gps_measurement`. This design ensures that the latency of any HTTP request is extremely low. The Rails application was duplicated to run Sidekiq as a separate container, making it easier to manage.

## Caching

The caching strategy was designed to optimize resource utilization and improve performance, meeting one of the critical requirements of this challenge. The strategy is based on two key principles:

1. **Storing New Measurements**: When a new GPS measurement is received, the cache is checked to see if the vehicle already exists. If it doesn't exist, it may be because the vehicle has never sent measurements before or hasn't been created in the database. In this case, the vehicle is created in the database, its position is stored, and it is registered in the cache.

2. **Updating Existing Data**: If the vehicle exists and is frequently sending updates, its data in the cache is continuously updated as new measurements are received.

## Testing

The tests implemented in this challenge are minimal, focusing on controllers and models. Following Rails team recommendations, the tests for controllers are based on requests rather than direct controller testing.

### Running the Tests

To run the tests, use the following command:

```bash
$ rspec spec/models_or_controllers/file_spec.rb
```

## Disclaimer

A strategy for preloading existing vehicles into the cache was missing, which would have allowed for a "prewarming" of the application, leading to better initial performance.
