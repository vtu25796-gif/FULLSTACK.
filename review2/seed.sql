USE event_booking_system;

-- Password for seeded users: password
INSERT INTO users (name, email, password, role) VALUES
  ('Department Admin', 'admin@college.edu', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'admin'),
  ('Aditi Sharma', 'aditi@college.edu', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'user');

INSERT INTO events (title, description, date, venue, seats, image_url) VALUES
  (
    'AI Technical Fest 2026',
    'An internal technical fest featuring AI project expo, coding sprint, and panel discussions by faculty.',
    '2026-06-10 10:00:00',
    'Main Auditorium',
    118,
    'https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&w=1200&q=80'
  ),
  (
    'Cloud Workshop: DevOps in Practice',
    'Hands-on workshop on CI/CD, Docker pipelines, and cloud deployment strategies for students and faculty.',
    '2026-07-05 14:30:00',
    'Lab 4, CS Block',
    60,
    'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=1200&q=80'
  ),
  (
    'Cybersecurity Seminar',
    'Expert-led seminar on secure coding patterns, zero-trust architecture, and incident response playbooks.',
    '2026-08-12 11:00:00',
    'Seminar Hall B',
    80,
    'https://images.unsplash.com/photo-1563013544-824ae1b704d3?auto=format&fit=crop&w=1200&q=80'
  );

INSERT INTO bookings (user_id, event_id, tickets_count) VALUES
  (2, 1, 2);
