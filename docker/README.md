# Teledoc local stack (Docker)

This spins up:
- PHP 8.2 (CLI) container to run Laravel (`php artisan serve` on port 8000)
- MySQL 8.0 for the backend database

## Prereqs
- Docker and Docker Compose installed

## How to run
```bash
cd docker
docker compose up --build
```

What happens:
- If `.env` is missing in `backend/`, it copies `.env.example` to `.env`
- Installs composer dependencies
- Generates app key
- Runs migrations
- Starts `php artisan serve` at `http://localhost:8000`

## Notes
- Default DB credentials are in `docker/docker-compose.yml` (teledoc/teledoc). They are injected into the Laravel container; adjust if needed.
- If you already have MySQL on port 3306 locally, change the published port on the `db` service.
- To import ICD-10 after up:
  ```bash
  docker compose exec app php artisan diagnosis:import-icd10 --truncate storage/app/icd10cm-codes-2026.txt
  ```
- To run any Laravel command:
  ```bash
  docker compose exec app php artisan <cmd>
  ```
