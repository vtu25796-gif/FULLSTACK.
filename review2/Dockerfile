# ---------- Stage 1: Build frontend ----------
FROM node:20-alpine AS frontend-builder
WORKDIR /app/frontend

COPY frontend/package*.json ./
RUN npm ci

COPY frontend/ ./
ARG VITE_API_BASE_URL=/api
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}
RUN npm run build

# ---------- Stage 2: Runtime backend ----------
FROM node:20-alpine AS runtime
WORKDIR /app/backend

COPY backend/package*.json ./
RUN npm ci --omit=dev

COPY backend/ ./
COPY --from=frontend-builder /app/frontend/dist ./frontend-dist

ENV NODE_ENV=production
ENV FRONTEND_DIST_PATH=/app/backend/frontend-dist

EXPOSE 5000
CMD ["node", "src/server.js"]
