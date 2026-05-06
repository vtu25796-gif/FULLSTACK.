USE event_booking_system;

-- Password for seeded users: password
INSERT INTO users (name, email, password, role) VALUES
  ('Department Admin', 'admin@college.edu', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'admin'),
  ('Aditi Sharma', 'aditi@college.edu', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'user')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  password = VALUES(password),
  role = VALUES(role);

INSERT INTO events (title, description, category, date, venue, seats, price, image_url)
SELECT seeded.title, seeded.description, seeded.category, seeded.date, seeded.venue, seeded.seats, seeded.price, seeded.image_url
FROM (
  SELECT
    'AI Technical Fest 2026' AS title,
    'An internal technical fest featuring AI project expo, coding sprint, and panel discussions by faculty.' AS description,
    'Technical Fest' AS category,
    '2026-06-10 10:00:00' AS date,
    'Main Auditorium' AS venue,
    118 AS seats,
    299.00 AS price,
    'https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&w=1200&q=80' AS image_url
  UNION ALL
  SELECT
    'Cloud Workshop: DevOps in Practice',
    'Hands-on workshop on CI/CD, Docker pipelines, and cloud deployment strategies for students and faculty.',
    'Workshop',
    '2026-07-05 14:30:00',
    'Lab 4, CS Block',
    60,
    199.00,
    'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=1200&q=80'
  UNION ALL
  SELECT
    'Cybersecurity Seminar',
    'Expert-led seminar on secure coding patterns, zero-trust architecture, and incident response playbooks.',
    'Seminar',
    '2026-08-12 11:00:00',
    'Seminar Hall B',
    80,
    149.00,
    'https://images.unsplash.com/photo-1563013544-824ae1b704d3?auto=format&fit=crop&w=1200&q=80'
  UNION ALL
  SELECT
    'Data Science Research Colloquium',
    'Faculty and postgraduate researchers present applied analytics work in healthcare, climate, and smart campus systems.',
    'Colloquium',
    '2026-09-03 09:30:00',
    'Innovation Center',
    90,
    249.00,
    'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=1200&q=80'
  UNION ALL
  SELECT
    'Hackathon Kickoff Night',
    'A high-energy opening session with team formation, mentor introductions, sponsor challenges, and late-night coding pods.',
    'Hackathon',
    '2026-09-18 18:00:00',
    'Central Computing Hub',
    150,
    499.00,
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80'
  UNION ALL
  SELECT
    'UI/UX Design Sprint',
    'A product design bootcamp covering rapid wireframing, accessibility reviews, usability testing, and portfolio critique.',
    'Workshop',
    '2026-10-02 13:00:00',
    'Design Studio 2',
    45,
    179.00,
    'https://images.unsplash.com/photo-1522542550221-31fd19575a2d?auto=format&fit=crop&w=1200&q=80'
  UNION ALL
  SELECT
    'Robotics Arena Demo Day',
    'Student teams showcase autonomous bots, embedded systems, and computer vision demos on a live challenge course.',
    'Demo Day',
    '2026-10-21 16:00:00',
    'Mechanical Block Arena',
    110,
    349.00,
    'https://images.unsplash.com/photo-1535378917042-10a22c95931a?auto=format&fit=crop&w=1200&q=80'
  UNION ALL
  SELECT
    'Startup Founder Fireside',
    'A candid evening conversation with alumni founders on product-market fit, fundraising, and building technical teams.',
    'Talk',
    '2026-11-07 17:30:00',
    'Conference Hall A',
    70,
    129.00,
    'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80'
  UNION ALL
  SELECT
    'Annual Project Expo',
    'Final-year capstone teams exhibit production-ready software, IoT systems, and AI prototypes to industry guests.',
    'Expo',
    '2026-11-28 10:30:00',
    'Exhibition Pavilion',
    200,
    99.00,
    'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=1200&q=80'
) AS seeded
WHERE NOT EXISTS (
  SELECT 1
  FROM events e
  WHERE e.title = seeded.title AND e.date = seeded.date
);

UPDATE events
SET category = CASE title
  WHEN 'AI Technical Fest 2026' THEN 'Technical Fest'
  WHEN 'Cloud Workshop: DevOps in Practice' THEN 'Workshop'
  WHEN 'Cybersecurity Seminar' THEN 'Seminar'
  WHEN 'Data Science Research Colloquium' THEN 'Colloquium'
  WHEN 'Hackathon Kickoff Night' THEN 'Hackathon'
  WHEN 'UI/UX Design Sprint' THEN 'Workshop'
  WHEN 'Robotics Arena Demo Day' THEN 'Demo Day'
  WHEN 'Startup Founder Fireside' THEN 'Talk'
  WHEN 'Annual Project Expo' THEN 'Expo'
  ELSE category
END;

UPDATE events
SET price = CASE title
  WHEN 'AI Technical Fest 2026' THEN 299.00
  WHEN 'Cloud Workshop: DevOps in Practice' THEN 199.00
  WHEN 'Cybersecurity Seminar' THEN 149.00
  WHEN 'Data Science Research Colloquium' THEN 249.00
  WHEN 'Hackathon Kickoff Night' THEN 499.00
  WHEN 'UI/UX Design Sprint' THEN 179.00
  WHEN 'Robotics Arena Demo Day' THEN 349.00
  WHEN 'Startup Founder Fireside' THEN 129.00
  WHEN 'Annual Project Expo' THEN 99.00
  ELSE price
END
WHERE price = 0.00;

INSERT INTO bookings (
  user_id,
  event_id,
  tickets_count,
  payment_method,
  upi_id,
  card_holder_name,
  card_last4,
  card_brand,
  payment_status
)
SELECT
  users.id,
  events.id,
  seeded.tickets_count,
  seeded.payment_method,
  seeded.upi_id,
  seeded.card_holder_name,
  seeded.card_last4,
  seeded.card_brand,
  seeded.payment_status
FROM (
  SELECT 'aditi@college.edu' AS user_email, 'AI Technical Fest 2026' AS event_title, 2 AS tickets_count, 'card' AS payment_method, NULL AS upi_id, 'Aditi Sharma' AS card_holder_name, '4242' AS card_last4, 'Visa' AS card_brand, 'paid' AS payment_status
  UNION ALL
  SELECT 'aditi@college.edu', 'Cloud Workshop: DevOps in Practice', 1, 'card', NULL, 'Aditi Sharma', '4444', 'Mastercard', 'paid'
  UNION ALL
  SELECT 'aditi@college.edu', 'Cybersecurity Seminar', 1, 'upi', 'aditi.sharma@oksbi', 'Aditi Sharma', 'ksbi', 'UPI', 'paid'
) AS seeded
INNER JOIN users ON users.email = seeded.user_email
INNER JOIN events ON events.title = seeded.event_title
WHERE NOT EXISTS (
  SELECT 1
  FROM bookings b
  WHERE b.user_id = users.id AND b.event_id = events.id
);
