
🚀 Start the Starter Kit
1) Make sure Docker is running
Start Docker Desktop first.

2) From the repo root run
This script will:

build the PHP/Laravel container
start all Docker services
run Laravel setup if needed
migrate the database
cache config/routes

3) Open the apps
Frontend: http://localhost:8200
Backend: http://localhost:8201
Backend API status: http://localhost:8201/api/status

🛠️ Stop the environment
This runs docker compose down.

🔧 Laravel setup / reset
If you need a full Laravel initialization, run:

That will:

install Composer dependencies
generate APP_KEY

 Ports used
Frontend: localhost:8200
Backend: localhost:8201
MySQL: localhost:8203
Redis: localhost:8204
Tools container: localhost:8205

💡 Notes
The repo includes docker-compose.yml wiring frontend, backend, PHP-FPM, MySQL, Redis, and a tools container.
Frontend expects the backend API on http://localhost:8201/api from your browser.

When any change is done you should stop the container of Docer first, after this start it again because the changes won't appear.
