# ControlDoc Challenge

## Introduction

The technologies used for this assessment are the following below:

- Ruby 3.2.0
- Rails 6.1
- Docker 27.2.0
- Docker Compose 2.29.2
- PostgreSQL 16
- Redis 5.0.8
- GoogleMaps 

## Diseño
La aplicación consta de 3 endpoints que devuelven _responses_ en json, un endpont que devuelve contenido HTML donde se visualizará el mapa, además del endpoint de sidekiq para monitoreo.

### Endpoints
```bash
/sidekiq            		    # To monitorize queues and workers 
/api/v1/check_api         	# To check if the API is working right now
/api/v1/latest_waypoints    # Show the last waypoints of each vehicle
/api/v1/gps           		  # Registering of each measurement from vehicle's GPS
/show             			    # To show the map
```

### Models
There are only two models:

- **Vehicle**: Almacena el `vehicle_identifier` con una llave primaria, es único.
- **Waypoint**: Almacena datos de mediciones y se encuentra relacionado con Vehicle a través de una llave foránea (`vehicle_id`)

### Project execution
Since this project was running on Docker, its bootstrapping is executed by the following below instructions (the evaluator has installed Docker on his own machine):

1. `(project-directory)$ docker compose up --build -d # -d If you want to demonize the execution is in background`
2. `(project-directory)$ docker compose exec app_backend rake db:create # To create database`
3. `(project-directory)$ docker compose exec app_backend rake db:migrate # To run migrations`

### Google API
Se ha definido una `GOOGLE_MAPS_API_KEY` en el archivo `.env` del contenedor app_backeend para trabajar en modo developer con la API de Google Maps.

### Environment variables
Fueron definidas diversas variables de entorno en los archivos .env y .env.postgres para la configuración de bases de datos y puest en marcha de servicios de bases de datos.
```bash
POSTGRES_DB=telemetry-waypoints-db
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_HOST=db_measurements

REDIS_URL=redis://redis:6379/0 
JOB_WORKER_URL=redis://redis:6379/0
GOOGLE_MAPS_API_KEY=AIzaSyCAtmzLLZrsfDCny_1qnljPoCbOrl0Sr0s

# Intencionalmente se duplicaron las URL, dado a que si se desean separar servicios por bases de datos, ninguno se vea afectado por los cambios del otro.
```
### Colas
Se ha creado solo una cola para efectos del ejercicio:

```bash
gps_measurement     # Para encolar los trabajos manipulados por el worker.
```

### Background Jobs
Como parte del _must have_ de este challenge, fue necesario la implementación de un worker con el framework Sidekiq, el cual es llamado `GpsMeasurementsWorker`, el cual opera con una única cola llamada `gps_measurements`, por lo tanto la latencia que tiene alguna petición HTTP es sumamente baja. Fue duplicada la aplicación de Rails del backend a fin de levantar Sidekiq como un contenedor más, siendo más fácil de gestionar.

### Caching
La estrategia de caché está orientada a preservar los recursos de la máquina a final de utilizarlos más eficientemente y cumplir con un _must_ de este challenge en cuanto a performance, dicha estrategia se compone de dos premisas:

- Cuando entra una medición de GPS (gps measurement) se procede a consultar en la caché para ver si existe, si no existe, puede que nunca haya enviado mediciones o sencillamente nunca haya sido creado en la base de datos, al no existir, se procede a crearse en la base de datos, almacenar su posición y además ser registradi dentro de la caché.

- Cuando el vehículo efectivamente existe y está enviando frecuentemente sus posiciones, se consulta en la caché, pero se va actualizando sus datos en la caché a medida que se reciben nuevas mediciones.

### Testing
Los testings aplicados en este challenge son mínimos, se limitaron a controladores y modelos, para los controladores, por recomendación del equipo de Rails, no se prueba el controlador sino el Request.
Su ejecución se realiza de la siguiente manera:
`$ rspec spec/models_or_controllers/file_spec.rb`

## Disclamer

Faltó una estrategía para cargar los vehículos preexistentes en caché a modo tal de hacer un _prehotting_ de la aplicación.