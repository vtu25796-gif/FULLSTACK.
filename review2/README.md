# Internal Department Event Ticket Booking System

Full-stack web app for department events where students/faculty can browse events and book tickets.

## Tech Stack
- Frontend: React (Vite), React Router, Axios, Bootstrap 5
- Backend: Node.js, Express.js, JWT auth, MVC structure
- Database: MySQL 8
- Testing: Jest (backend utilities)
- Deployment: Docker Compose (single-server ready)

## Project Structure
```text
Eventbooking/
|- backend/
|- frontend/
|- database/
|- docs/
|- Dockerfile
|- docker-compose.yml
|- .env.deploy.example
`- README.md
```

## Features
- JWT signup/login
- Event listing with search, filters, pagination, sorting
- Event details + booking flow
- Seat availability management and overbooking prevention
- User booking dashboard
- Admin CRUD panel for events
- Optional booking email confirmations

## Local Development Setup

### 1) Prerequisites
- Node.js 18+
- MySQL 8+
- npm

### 2) Database setup
```bash
mysql -u root -p < database/schema.sql
mysql -u root -p < database/seed.sql
```

### 3) Backend
```bash
cd backend
npm install
cp .env.example .env
# PowerShell: Copy-Item .env.example .env
npm run dev
```
Runs on `http://localhost:5000`.

### 4) Frontend
```bash
cd frontend
npm install
cp .env.example .env
# PowerShell: Copy-Item .env.example .env
npm run dev
```
Runs on `http://localhost:5173`.

## Single Server Deployment (Complete Project on One Server)

This deploys frontend + backend + MySQL together on one machine.

### 1) Prepare env file
```bash
cp .env.deploy.example .env
```
Set at least:
- `MYSQL_ROOT_PASSWORD`
- `JWT_SECRET`
- `CLIENT_URL`
- `APP_PORT`

### 2) Build and run
```bash
docker compose --env-file .env up -d --build
```

### 3) Verify
```bash
docker compose ps
curl http://localhost/api/health
```

### 4) Stop
```bash
docker compose down
```

## Seeded Accounts
- Admin: `admin@college.edu` / `password`
- User: `aditi@college.edu` / `password`

## Testing
```bash
cd backend
npm test
```

## Documentation
- API: [docs/API.md](docs/API.md)
- Deployment: [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)
- UI Preview: [docs/UI_PREVIEW.md](docs/UI_PREVIEW.md)
