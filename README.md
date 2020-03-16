# Beetrack Challenge

## Introducción

En una primera instancia, se efectua una evaluación sobre como pudiera diseñarle la app, en cuanto a tecnologías, fueron utilizadas las siguientes:

- Ruby 2.6.5
- Rails 5.2.4.1
- Docker 19.03.5
- Docker Compose 1.25.4
- PostgreSQL 11
- Redis 5.0.8
- GoogleMaps 

## Diseño
La aplicación consta de 3 endpoints que devuelven _responses_ en json, un endpont que devuelve contenido HTML donde se visualizará el mapa, además del endpoint de sidekiq para monitoreo.

### Endpoints
```bash
/sidekiq            # Para monitorizar las colas y los workers
/api/v1/check_api         # Para revisar si la API está en funcionamiento
/api/v1/latest_waypoints    # Muestra los últimos puntos de cada vehículo
/api/v1/gps           # Registra cada measurement procedente del GPS del vehículo
/show             # Para visualizar el mapa
```

### Modelos
Se encuentran solamente dos modelos:

- **Vehicle**: Almacena el `vehicle_identifier` con una llave primaria, es único.
- **Waypoint**: Almacena datos de mediciones y se encuentra relacionado con Vehicle a través de una llave foránea (`vehicle_id`)

### Ejecución del proyecto
Dado a que este proyecto se levantó en base a Docker por las ventajas que ofrece, su puesta en marcha es de la siguiente manera (el autor supone que el evaluador posee Docker instalado en la máquina):

1. `(project-directory)$ docker-compose up --build -d # -d por si desean demonizarlo`
2. `(project-directory)$ docker-compose exec app_backend rake db:create && rake db:migrate # para la creación de la base de datos y la ejecución de las migraciones`

### Google API
Se ha definido una `GOOGLE_MAPS_API_KEY` en el archivo `.env` del contenedor app_backeend para trabajar en modo developer con la API de Google Maps.

### Variables de entorno
Fueron definidas diversas variables de entorno en los archivos .env y .env.postgres para la configuración de bases de datos y puest en marcha de servicios de bases de datos.
```bash
POSTGRES_DB=beetrack
POSTGRES_USER=postgres
POSTGRES_PASSWORD=beetrack
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