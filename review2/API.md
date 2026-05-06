# API Documentation

Base URL: `http://localhost:5000/api`

## Health
### `GET /health`
Returns backend health status.

## Authentication
### `POST /auth/signup`
Create a new user account.

Request body:
```json
{
  "name": "John Doe",
  "email": "john@college.edu",
  "password": "secret123"
}
```

### `POST /auth/login`
Login and get JWT token.

Request body:
```json
{
  "email": "john@college.edu",
  "password": "secret123"
}
```

### `GET /auth/me`
Get current user profile. Requires `Authorization: Bearer <token>`.

## Events
### `GET /events`
List events with filters, pagination, and sorting.

Query params:
- `search`: title/description search text
- `venue`: filter by venue
- `dateFrom`: ISO date lower bound
- `dateTo`: ISO date upper bound
- `page`: default `1`
- `limit`: default `6`, max `50`
- `sortBy`: `date | title | venue | seats | created_at`
- `order`: `asc | desc`

### `GET /events/:id`
Get a single event.

### `POST /events` (Admin only)
Create event.

### `PUT /events/:id` (Admin only)
Update event.

### `DELETE /events/:id` (Admin only)
Delete event.

Event payload:
```json
{
  "title": "Cloud Workshop",
  "description": "Hands-on event",
  "date": "2026-07-05T14:30:00.000Z",
  "venue": "Lab 4",
  "seats": 60,
  "imageUrl": "https://example.com/image.jpg"
}
```

## Bookings
### `POST /bookings` (Authenticated)
Book tickets for an event.

Request body:
```json
{
  "eventId": 1,
  "ticketsCount": 2
}
```

Behavior:
- Locks event row (`FOR UPDATE`)
- Prevents overbooking
- Reduces available seats on successful booking

### `GET /bookings/me` (Authenticated)
Get current user bookings with event details.

### `GET /bookings` (Admin only)
Get all bookings (paginated, sortable).

Query params:
- `page`
- `limit`
- `sortBy`: `created_at | tickets_count`
- `order`: `asc | desc`

## Common Response Format
```json
{
  "success": true,
  "message": "Optional message",
  "data": {},
  "pagination": {}
}
```

Validation failures return `400`, auth failures return `401/403`, not found returns `404`, conflict (overbooking) returns `409`.
