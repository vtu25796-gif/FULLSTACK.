# Deployment Guide

## Single Server Deployment (Recommended)

This project now supports single-server deployment where:
- React frontend is built and served by Express
- API runs on the same host and same port
- MySQL runs on the same server via Docker Compose

### 1) Server prerequisites
- Ubuntu/Linux VPS (or any machine with Docker support)
- Docker Engine + Docker Compose plugin installed
- Ports `80` and `3306` available (or customized)

### 2) Copy project to server
```bash
git clone <your-repo-url>
cd Eventbooking
```

### 3) Configure deployment environment
```bash
cp .env.deploy.example .env
```
Update `.env` values:
- `MYSQL_ROOT_PASSWORD`
- `JWT_SECRET`
- `CLIENT_URL` (your domain, e.g. `https://events.college.edu`)
- `APP_PORT` (keep `80` for public HTTP, or change as needed)

### 4) Start complete stack
```bash
docker compose --env-file .env up -d --build
```

### 5) Verify
```bash
docker compose ps
curl http://localhost/api/health
```

If deployed with domain + reverse proxy/SSL, verify with:
```bash
curl https://your-domain/api/health
```

### 6) Stop / restart
```bash
docker compose down
docker compose --env-file .env up -d
```

## Notes
- Database schema and seed run automatically on first MySQL container initialization from `database/`.
- Rebuilding updates both frontend and backend in one image (`Dockerfile` multi-stage build).
- Frontend uses same-origin API (`/api`) in production.

## Optional: Add HTTPS (Nginx + Certbot)
- Point DNS `A` record to your server IP.
- Install Nginx and Certbot on host.
- Proxy `https://your-domain` to `http://localhost:80`.
- Issue TLS certificate with Certbot.

## Production Checklist
- Replace `JWT_SECRET` with a strong secure value.
- Use strong MySQL password.
- Restrict `CLIENT_URL` to your real domain.
- Keep SMTP variables set only if email confirmation is needed.
