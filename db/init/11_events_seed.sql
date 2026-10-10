-- =============================================================================
-- Society Events — Events-domain Seed Data  (split out of 02_seed.sql,
-- EVENTS_SERVICE_PLAN.md C8). Runs AFTER 02_seed.sql: references its users,
-- society and currency rows by their fixed UUIDs.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- CLEAR EVENTS DATA  (CASCADE also clears core.notification, which references
-- event_svc.event — every seeded notification is re-inserted below)
-- ---------------------------------------------------------------------------
TRUNCATE TABLE
    registration_svc.registration_item, event_svc.ticket_type,
    payment_svc.distribution_entry, payment_svc.vendor_revenue_distribution,
    payment_svc.event_vendor, payment_svc.vendor,
    registration_svc.complimentary_ticket, payment_svc.event_expense,
    payment_svc.sponsorship_refund, payment_svc.event_sponsorship, payment_svc.sponsor,
    event_svc.announcement, registration_svc.refund, registration_svc.payment,
    registration_svc.registration, event_svc.event, event_svc.event_category
RESTART IDENTITY CASCADE;

-- ---------------------------------------------------------------------------
-- EVENT CATEGORY
-- ---------------------------------------------------------------------------
INSERT INTO event_svc.event_category (id, society_id, name, icon, color_hex) VALUES
    ('41100000-0000-0000-0000-000000000001', '11100000-0000-0000-0000-000000000001', 'Festival',   'sparkles', '#F59E0B'),
    ('41100000-0000-0000-0000-000000000002', '11100000-0000-0000-0000-000000000001', 'Sports',     'trophy',   '#10B981'),
    ('41100000-0000-0000-0000-000000000003', '11100000-0000-0000-0000-000000000001', 'Wellness',   'heart',    '#8B5CF6'),
    ('41100000-0000-0000-0000-000000000004', '11100000-0000-0000-0000-000000000001', 'Governance', 'building', '#6B7280'),
    ('41100000-0000-0000-0000-000000000005', '11100000-0000-0000-0000-000000000001', 'Kids',       'star',     '#EC4899');

-- ---------------------------------------------------------------------------
-- EVENTS
-- ---------------------------------------------------------------------------
INSERT INTO event_svc.event (id, society_id, category_id, organizer_id, title, description,
                   start_time, end_time, venue, capacity, status,
                   ticket_price, price_currency, is_free) VALUES

    ('51100000-0000-0000-0000-000000000001',
     '11100000-0000-0000-0000-000000000001',
     '41100000-0000-0000-0000-000000000001',
     '31100000-0000-0000-0000-000000000002',
     'Diwali Mela 2025',
     'Annual Diwali celebration with rangoli competition, diyas, cultural performances, and a grand potluck dinner. All residents and guests welcome.',
     NOW() + INTERVAL '45 days', NOW() + INTERVAL '45 days' + INTERVAL '5 hours',
     'Society Clubhouse & Garden', 500, 'published', 0.00, 'INR', TRUE),

    ('51100000-0000-0000-0000-000000000002',
     '11100000-0000-0000-0000-000000000001',
     '41100000-0000-0000-0000-000000000002',
     '31100000-0000-0000-0000-000000000002',
     'Annual Sports Day 2026',
     'Cricket, badminton, throwball, tug-of-war and 100 m sprint. Medals and trophies for top three in each category. Registration covers sports kit and refreshments.',
     NOW() + INTERVAL '80 days', NOW() + INTERVAL '80 days' + INTERVAL '8 hours',
     'Society Sports Ground', 200, 'published', 150.00, 'INR', FALSE),

    ('51100000-0000-0000-0000-000000000003',
     '11100000-0000-0000-0000-000000000001',
     '41100000-0000-0000-0000-000000000003',
     '31100000-0000-0000-0000-000000000001',
     'Sunday Morning Yoga',
     'Guided yoga and pranayama every Sunday at 6:30 AM. Suitable for all levels. Bring your own mat.',
     NOW() + INTERVAL '5 days', NOW() + INTERVAL '5 days' + INTERVAL '1 hour',
     'Rooftop Terrace — Tower A', 30, 'published', 0.00, 'INR', TRUE),

    ('51100000-0000-0000-0000-000000000004',
     '11100000-0000-0000-0000-000000000001',
     '41100000-0000-0000-0000-000000000004',
     '31100000-0000-0000-0000-000000000001',
     'Annual General Meeting 2025',
     'Mandatory AGM covering FY2025 accounts, maintenance fee revision, upcoming infrastructure projects, and election of new committee members.',
     NOW() + INTERVAL '20 days', NOW() + INTERVAL '20 days' + INTERVAL '3 hours',
     'Conference Room, Clubhouse', 150, 'published', 0.00, 'INR', TRUE),

    ('51100000-0000-0000-0000-000000000005',
     '11100000-0000-0000-0000-000000000001',
     '41100000-0000-0000-0000-000000000005',
     '31100000-0000-0000-0000-000000000002',
     'Children''s Day Carnival',
     'Games, face painting, puppet show, and art competition for kids aged 4–14. Fee covers activity kits, snacks, and participation gifts.',
     NOW() + INTERVAL '12 days', NOW() + INTERVAL '12 days' + INTERVAL '4 hours',
     'Society Amphitheatre', 100, 'published', 100.00, 'INR', FALSE);

-- ---------------------------------------------------------------------------
-- REGISTRATION
-- ---------------------------------------------------------------------------
INSERT INTO registration_svc.registration (id, event_id, user_id, ticket_count, total_amount,
                           display_currency, status, qr_code) VALUES

    -- Diwali (free)
    ('61100000-0000-0000-0000-000000000001',
     '51100000-0000-0000-0000-000000000001', '31100000-0000-0000-0000-000000000003',
     3, 0.00, 'INR', 'confirmed', 'QR-DIWALI-ARJUN-001'),

    ('61100000-0000-0000-0000-000000000002',
     '51100000-0000-0000-0000-000000000001', '31100000-0000-0000-0000-000000000004',
     2, 0.00, 'INR', 'confirmed', 'QR-DIWALI-PRIYA-001'),

    ('61100000-0000-0000-0000-000000000003',
     '51100000-0000-0000-0000-000000000001', '31100000-0000-0000-0000-000000000005',
     4, 0.00, 'INR', 'confirmed', 'QR-DIWALI-SANJAY-001'),

    ('61100000-0000-0000-0000-000000000009',
     '51100000-0000-0000-0000-000000000001', '31100000-0000-0000-0000-000000000008',
     2, 0.00, 'INR', 'confirmed', 'QR-DIWALI-DEEPA-001'),

    ('61100000-0000-0000-0000-000000000010',
     '51100000-0000-0000-0000-000000000001', '31100000-0000-0000-0000-000000000010',
     1, 0.00, 'INR', 'confirmed', 'QR-DIWALI-ANANYA-001'),

    -- Sports Day (paid INR) — Arjun: 2 tickets = ₹300
    ('61100000-0000-0000-0000-000000000004',
     '51100000-0000-0000-0000-000000000002', '31100000-0000-0000-0000-000000000003',
     2, 300.00, 'INR', 'confirmed', 'QR-SPORTS-ARJUN-001'),

    -- Sports Day (paid USD) — Vikram: 1 ticket ($1.80)
    ('61100000-0000-0000-0000-000000000005',
     '51100000-0000-0000-0000-000000000002', '31100000-0000-0000-0000-000000000006',
     1, 1.80, 'USD', 'confirmed', 'QR-SPORTS-VIKRAM-001'),

    -- Sports Day — Kiran: 1 participant ticket = ₹150
    ('61100000-0000-0000-0000-000000000011',
     '51100000-0000-0000-0000-000000000002', '31100000-0000-0000-0000-000000000011',
     1, 150.00, 'INR', 'confirmed', 'QR-SPORTS-KIRAN-001'),

    -- Children's Carnival — Priya: 2 tickets = ₹200
    ('61100000-0000-0000-0000-000000000006',
     '51100000-0000-0000-0000-000000000005', '31100000-0000-0000-0000-000000000004',
     2, 200.00, 'INR', 'confirmed', 'QR-KIDS-PRIYA-001'),

    -- Yoga (free)
    ('61100000-0000-0000-0000-000000000007',
     '51100000-0000-0000-0000-000000000003', '31100000-0000-0000-0000-000000000003',
     1, 0.00, 'INR', 'confirmed', 'QR-YOGA-ARJUN-001'),

    ('61100000-0000-0000-0000-000000000012',
     '51100000-0000-0000-0000-000000000003', '31100000-0000-0000-0000-000000000008',
     1, 0.00, 'INR', 'confirmed', 'QR-YOGA-DEEPA-001'),

    -- AGM (free) — Sanjay: pending
    ('61100000-0000-0000-0000-000000000008',
     '51100000-0000-0000-0000-000000000004', '31100000-0000-0000-0000-000000000005',
     1, 0.00, 'INR', 'pending', NULL);

-- ---------------------------------------------------------------------------
-- PAYMENT
-- ---------------------------------------------------------------------------
INSERT INTO registration_svc.payment (id, registration_id, gateway_name,
                     gateway_order_id, gateway_txn_id,
                     original_amount, original_currency,
                     settled_amount, settled_currency,
                     exchange_rate_used, exchange_rate_id,
                     status, gateway_response, paid_at) VALUES

    -- Arjun: ₹300 Sports Day
    ('81100000-0000-0000-0000-000000000001',
     '61100000-0000-0000-0000-000000000004',
     'razorpay', 'order_RZP_sports_arjun_001', 'pay_RZP_sports_arjun_001',
     300.00, 'INR', 300.00, 'INR', 1.0, NULL,
     'success',
     '{"method":"upi","vpa":"arjun@oksbi","fee":600,"tax":91}'::jsonb,
     NOW() - INTERVAL '2 days'),

    -- Vikram: $1.80 USD → ₹150.30
    ('81100000-0000-0000-0000-000000000002',
     '61100000-0000-0000-0000-000000000005',
     'razorpay', 'order_RZP_sports_vikram_001', 'pay_RZP_sports_vikram_001',
     1.80, 'USD', 150.30, 'INR',
     83.50000000, '71100000-0000-0000-0000-000000000001',
     'success',
     '{"method":"card","bank":"HDFC","international":true,"currency":"USD"}'::jsonb,
     NOW() - INTERVAL '3 days'),

    -- Priya: ₹200 Children's Carnival
    ('81100000-0000-0000-0000-000000000003',
     '61100000-0000-0000-0000-000000000006',
     'razorpay', 'order_RZP_kids_priya_001', 'pay_RZP_kids_priya_001',
     200.00, 'INR', 200.00, 'INR', 1.0, NULL,
     'success',
     '{"method":"netbanking","bank":"SBIN"}'::jsonb,
     NOW() - INTERVAL '1 day'),

    -- Kiran: ₹150 Sports Day
    ('81100000-0000-0000-0000-000000000004',
     '61100000-0000-0000-0000-000000000011',
     'razorpay', 'order_RZP_sports_kiran_001', 'pay_RZP_sports_kiran_001',
     150.00, 'INR', 150.00, 'INR', 1.0, NULL,
     'success',
     '{"method":"upi","vpa":"kiran@ybl","fee":300,"tax":46}'::jsonb,
     NOW() - INTERVAL '1 day');

-- ---------------------------------------------------------------------------
-- REFUND  (Priya: partial ₹100 for carnival)
-- ---------------------------------------------------------------------------
INSERT INTO registration_svc.refund (id, payment_id, initiated_by,
                    original_refund_amount, original_currency,
                    settled_refund_amount, settled_currency,
                    reason, status, gateway_refund_id) VALUES
    ('91100000-0000-0000-0000-000000000001',
     '81100000-0000-0000-0000-000000000003',
     '31100000-0000-0000-0000-000000000004',
     100.00, 'INR', 100.00, 'INR',
     'One family member unable to attend due to travel. Requesting partial refund for 1 ticket.',
     'processed', 'rfnd_RZP_kids_priya_001');

-- ---------------------------------------------------------------------------
-- ANNOUNCEMENT
-- ---------------------------------------------------------------------------
INSERT INTO event_svc.announcement (id, event_id, author_id, title, body, sent_at) VALUES
    ('a1100000-0000-0000-0000-000000000001',
     '51100000-0000-0000-0000-000000000001',
     '31100000-0000-0000-0000-000000000002',
     'Diwali Mela — Rangoli Competition Details',
     'Dear residents, the rangoli competition will begin at 5 PM sharp. Each flat may register one team of up to 4 members. Colours and stencils will be provided. Theme: "Unity in Diversity".',
     NOW() - INTERVAL '5 days'),

    ('a1100000-0000-0000-0000-000000000002',
     '51100000-0000-0000-0000-000000000002',
     '31100000-0000-0000-0000-000000000002',
     'Sports Day — Schedule Released',
     'The final event schedule is now available on the notice board and app. Cricket registration closes in 48 hours.',
     NOW() - INTERVAL '1 day'),

    ('a1100000-0000-0000-0000-000000000003',
     '51100000-0000-0000-0000-000000000004',
     '31100000-0000-0000-0000-000000000001',
     'AGM Agenda Published',
     'Key items: (1) FY2025 audited accounts, (2) Maintenance fee increase proposal of 8%, (3) EV charging station in Tower B, (4) New committee election. Documents shared on the app.',
     NOW() - INTERVAL '3 days');

-- ---------------------------------------------------------------------------
-- NOTIFICATION
-- ---------------------------------------------------------------------------
INSERT INTO core.notification (id, user_id, event_id, type, title, message, is_read) VALUES

    ('b1100000-0000-0000-0000-000000000001',
     '31100000-0000-0000-0000-000000000003',
     '51100000-0000-0000-0000-000000000002',
     'payment_success', 'Payment confirmed — Annual Sports Day 2026',
     'Your payment of ₹300 for 2 tickets to Annual Sports Day 2026 was successful. QR code is ready under My Tickets.',
     TRUE),

    ('b1100000-0000-0000-0000-000000000002',
     '31100000-0000-0000-0000-000000000003',
     '51100000-0000-0000-0000-000000000001',
     'event_reminder', 'Diwali Mela is 3 days away!',
     'The Diwali Mela starts in 3 days at the Clubhouse. You have 3 tickets. Don''t forget your potluck dish!',
     FALSE),

    ('b1100000-0000-0000-0000-000000000003',
     '31100000-0000-0000-0000-000000000006',
     '51100000-0000-0000-0000-000000000002',
     'payment_success', 'Payment confirmed — Annual Sports Day 2026',
     'Your payment of $1.80 USD (₹150.30 settled) for 1 ticket to Annual Sports Day 2026 was successful.',
     TRUE),

    ('b1100000-0000-0000-0000-000000000004',
     '31100000-0000-0000-0000-000000000004',
     '51100000-0000-0000-0000-000000000005',
     'refund_processed', 'Refund of ₹100 processed',
     'Your partial refund of ₹100 for Children''s Day Carnival has been processed. It will reflect in 5–7 business days.',
     FALSE),

    ('b1100000-0000-0000-0000-000000000005',
     '31100000-0000-0000-0000-000000000005',
     '51100000-0000-0000-0000-000000000004',
     'event_reminder', 'Confirm your AGM attendance',
     'The AGM is 20 days away. Please confirm your attendance. Quorum requires 51% of flat owners.',
     FALSE),

    ('b1100000-0000-0000-0000-000000000006',
     '31100000-0000-0000-0000-000000000002',
     '51100000-0000-0000-0000-000000000002',
     'announcement', 'Sports Day — Schedule Released',
     'The event schedule for Annual Sports Day 2026 has been published. Cricket registration closes in 48 hours.',
     TRUE),

    ('b1100000-0000-0000-0000-000000000007',
     '31100000-0000-0000-0000-000000000004',
     '51100000-0000-0000-0000-000000000001',
     'registration_confirmed', 'You''re registered for Diwali Mela 2025',
     'Your registration for Diwali Mela 2025 (2 tickets) is confirmed. See you at the Clubhouse!',
     TRUE),

    ('b1100000-0000-0000-0000-000000000008',
     '31100000-0000-0000-0000-000000000011',
     '51100000-0000-0000-0000-000000000002',
     'payment_success', 'Payment confirmed — Annual Sports Day 2026',
     'Your payment of ₹150 for 1 participant ticket to Annual Sports Day 2026 was successful.',
     FALSE);

-- ---------------------------------------------------------------------------
-- SPONSOR
-- ---------------------------------------------------------------------------
INSERT INTO payment_svc.sponsor (id, user_id, organization_name, organization_type,
                     contact_name, contact_email, contact_phone) VALUES
    ('c1100000-0000-0000-0000-000000000001',
     '31100000-0000-0000-0000-000000000007',
     'TechCorp Solutions Pvt. Ltd.', 'private',
     'Kavya Reddy', 'kavya.reddy@techcorp.com', '+91-98800-77777'),
    ('c1100000-0000-0000-0000-000000000002',
     NULL,
     'Community Welfare Foundation', 'ngo',
     'Anand Kumar', 'anand.kumar@cwf.org', '+91-99900-88888');

-- ---------------------------------------------------------------------------
-- EVENT_SPONSORSHIP
-- ---------------------------------------------------------------------------
INSERT INTO payment_svc.event_sponsorship (id, event_id, sponsor_id, amount, currency_code,
                                status, payment_reference, notes) VALUES
    ('d1100000-0000-0000-0000-000000000001',
     '51100000-0000-0000-0000-000000000001',
     'c1100000-0000-0000-0000-000000000001',
     25000.00, 'INR', 'received', 'TXN-DIWALI-TECHCORP-001',
     'Sponsoring decorations and prizes for rangoli competition'),

    ('d1100000-0000-0000-0000-000000000002',
     '51100000-0000-0000-0000-000000000002',
     'c1100000-0000-0000-0000-000000000002',
     15000.00, 'INR', 'received', 'TXN-SPORTS-CWF-001',
     'Sponsoring sports kits and medals'),

    ('d1100000-0000-0000-0000-000000000003',
     '51100000-0000-0000-0000-000000000002',
     'c1100000-0000-0000-0000-000000000001',
     10000.00, 'INR', 'pledged', NULL,
     'Pledged to sponsor the refreshment counter');

-- ---------------------------------------------------------------------------
-- SPONSORSHIP_REFUND
-- ---------------------------------------------------------------------------
INSERT INTO payment_svc.sponsorship_refund (id, sponsorship_id, requested_by, amount,
                                 currency_code, reason, status) VALUES
    ('e1100000-0000-0000-0000-000000000001',
     'd1100000-0000-0000-0000-000000000003',
     '31100000-0000-0000-0000-000000000007',
     5000.00, 'INR',
     'Event capacity was reduced; requesting partial refund for the unsupported portion.',
     'pending');

-- ---------------------------------------------------------------------------
-- EVENT_EXPENSE
-- ---------------------------------------------------------------------------
INSERT INTO payment_svc.event_expense (id, event_id, description, amount, currency_code,
                            category, created_by) VALUES
    ('f1100000-0000-0000-0000-000000000001',
     '51100000-0000-0000-0000-000000000001',
     'Decoration materials — diyas, lanterns, flowers', 8500.00, 'INR',
     'venue', '31100000-0000-0000-0000-000000000002'),

    ('f1100000-0000-0000-0000-000000000002',
     '51100000-0000-0000-0000-000000000001',
     'Potluck setup and utensils', 3200.00, 'INR',
     'catering', '31100000-0000-0000-0000-000000000002'),

    ('f1100000-0000-0000-0000-000000000003',
     '51100000-0000-0000-0000-000000000001',
     'Sound system rental', 5000.00, 'INR',
     'equipment', '31100000-0000-0000-0000-000000000002'),

    ('f1100000-0000-0000-0000-000000000004',
     '51100000-0000-0000-0000-000000000002',
     'Cricket set and badminton nets', 6000.00, 'INR',
     'equipment', '31100000-0000-0000-0000-000000000002'),

    ('f1100000-0000-0000-0000-000000000005',
     '51100000-0000-0000-0000-000000000002',
     'Medals and trophies', 4500.00, 'INR',
     'other', '31100000-0000-0000-0000-000000000002'),

    ('f1100000-0000-0000-0000-000000000006',
     '51100000-0000-0000-0000-000000000002',
     'Refreshments for participants', 3800.00, 'INR',
     'catering', '31100000-0000-0000-0000-000000000002');

-- ---------------------------------------------------------------------------
-- COMPLIMENTARY_TICKET
-- ---------------------------------------------------------------------------
INSERT INTO registration_svc.complimentary_ticket (id, event_id, invited_by_user_id, inviter_type,
                                   ticket_count, notes, created_by) VALUES
    ('0c100000-0000-0000-0000-000000000001',
     '51100000-0000-0000-0000-000000000001',
     '31100000-0000-0000-0000-000000000002', 'committee_member',
     2, 'Committee member''s family guests',
     '31100000-0000-0000-0000-000000000002'),

    ('0c100000-0000-0000-0000-000000000002',
     '51100000-0000-0000-0000-000000000001',
     '31100000-0000-0000-0000-000000000001', 'organizer',
     3, 'Organizer''s family and neighbours',
     '31100000-0000-0000-0000-000000000001'),

    ('0c100000-0000-0000-0000-000000000003',
     '51100000-0000-0000-0000-000000000001',
     '31100000-0000-0000-0000-000000000007', 'sponsor',
     4, 'TechCorp sponsor team members',
     '31100000-0000-0000-0000-000000000002'),

    ('0c100000-0000-0000-0000-000000000004',
     '51100000-0000-0000-0000-000000000001',
     NULL, 'walk_in',
     15, 'Walk-in attendees at gate',
     '31100000-0000-0000-0000-000000000001'),

    ('0c100000-0000-0000-0000-000000000005',
     '51100000-0000-0000-0000-000000000002',
     NULL, 'walk_in',
     8, 'Walk-ins at entry gate on event day',
     '31100000-0000-0000-0000-000000000002');

-- ---------------------------------------------------------------------------
-- VENDOR
-- ---------------------------------------------------------------------------
INSERT INTO payment_svc.vendor (id, society_id, name, category,
                    contact_name, contact_email, contact_phone) VALUES
    ('0d100000-0000-0000-0000-000000000001',
     '11100000-0000-0000-0000-000000000001',
     'Raj Sweets & Snacks', 'food',
     'Rajan Pillai', 'rajan@rajsweets.in', '+91-98001-11001'),
    ('0d100000-0000-0000-0000-000000000002',
     '11100000-0000-0000-0000-000000000001',
     'Fun Games Zone', 'games',
     'Deepak Rao', 'deepak@fungames.in', '+91-97001-22002'),
    ('0d100000-0000-0000-0000-000000000003',
     '11100000-0000-0000-0000-000000000001',
     'Sparkle Merchandise', 'merchandise',
     'Sunita Bose', 'sunita@sparklemerch.in', '+91-96001-33003');

-- ---------------------------------------------------------------------------
-- EVENT_VENDOR
-- ---------------------------------------------------------------------------
INSERT INTO payment_svc.event_vendor (id, event_id, vendor_id, stall_number, fee_type,
                           fixed_fee, revenue_share_pct, actual_revenue, status, notes) VALUES
    ('0e100000-0000-0000-0000-000000000001',
     '51100000-0000-0000-0000-000000000001',
     '0d100000-0000-0000-0000-000000000001',
     'A-01', 'revenue_share', 0.00, 15.00, 20000.00, 'confirmed',
     'Sweets and snacks near main entrance'),

    ('0e100000-0000-0000-0000-000000000002',
     '51100000-0000-0000-0000-000000000001',
     '0d100000-0000-0000-0000-000000000002',
     'B-03', 'fixed', 2000.00, 0.00, NULL, 'confirmed',
     'Games stall for kids and adults'),

    ('0e100000-0000-0000-0000-000000000003',
     '51100000-0000-0000-0000-000000000001',
     '0d100000-0000-0000-0000-000000000003',
     'C-02', 'revenue_share', 0.00, 20.00, 9500.00, 'confirmed',
     'Diwali-themed gifts and decorative items');

-- ---------------------------------------------------------------------------
-- VENDOR_REVENUE_DISTRIBUTION
-- ---------------------------------------------------------------------------
INSERT INTO payment_svc.vendor_revenue_distribution (id, event_id, total_pool, currency_code,
                                          status, notes) VALUES
    ('0f100000-0000-0000-0000-000000000001',
     '51100000-0000-0000-0000-000000000001',
     6900.00, 'INR', 'draft',
     'Combined pool: Raj Sweets ₹3000 + Fun Games ₹2000 + Sparkle ₹1900');

-- ---------------------------------------------------------------------------
-- DISTRIBUTION_ENTRY
-- ---------------------------------------------------------------------------
INSERT INTO payment_svc.distribution_entry (id, distribution_id, recipient_type,
                                  recipient_user_id, recipient_sponsor_id,
                                  share_percentage, amount, status) VALUES
    ('0f200000-0000-0000-0000-000000000001',
     '0f100000-0000-0000-0000-000000000001',
     'sponsor', NULL, 'c1100000-0000-0000-0000-000000000001',
     30.00, 2070.00, 'pending'),

    ('0f200000-0000-0000-0000-000000000002',
     '0f100000-0000-0000-0000-000000000001',
     'sponsor', NULL, 'c1100000-0000-0000-0000-000000000002',
     10.00, 690.00, 'pending'),

    ('0f200000-0000-0000-0000-000000000003',
     '0f100000-0000-0000-0000-000000000001',
     'organizer', '31100000-0000-0000-0000-000000000002', NULL,
     30.00, 2070.00, 'pending'),

    ('0f200000-0000-0000-0000-000000000004',
     '0f100000-0000-0000-0000-000000000001',
     'society', NULL, NULL,
     30.00, 2070.00, 'pending');

-- ---------------------------------------------------------------------------
-- TICKET_TYPE
-- ---------------------------------------------------------------------------
INSERT INTO event_svc.ticket_type (id, event_id, name, description, price, is_free,
                          capacity, sort_order) VALUES
    ('0f300000-0000-0000-0000-000000000001',
     '51100000-0000-0000-0000-000000000001',
     'General Entry', 'Access to all open stalls, performances and rangoli area',
     0.00, TRUE, NULL, 1),
    ('0f300000-0000-0000-0000-000000000002',
     '51100000-0000-0000-0000-000000000001',
     'Dinner Pass', 'Grand potluck dinner buffet plate',
     150.00, FALSE, 200, 2),
    ('0f300000-0000-0000-0000-000000000003',
     '51100000-0000-0000-0000-000000000001',
     'Games Bundle', 'Unlimited Fun Games Zone access',
     50.00, FALSE, 150, 3),

    ('0f300000-0000-0000-0000-000000000004',
     '51100000-0000-0000-0000-000000000002',
     'Participant', 'Play in any category — includes kit + refreshments',
     150.00, FALSE, NULL, 1),
    ('0f300000-0000-0000-0000-000000000005',
     '51100000-0000-0000-0000-000000000002',
     'Spectator', 'Watch all events from spectator stands',
     50.00, FALSE, NULL, 2),
    ('0f300000-0000-0000-0000-000000000006',
     '51100000-0000-0000-0000-000000000002',
     'Kids Zone', 'Kids 5–12 — mini-games and activity corner',
     75.00, FALSE, 80, 3);

-- ---------------------------------------------------------------------------
-- REGISTRATION_ITEM
-- ---------------------------------------------------------------------------
INSERT INTO registration_svc.registration_item (id, registration_id, ticket_type_id, quantity, unit_price) VALUES
    ('0f400000-0000-0000-0000-000000000001',
     '61100000-0000-0000-0000-000000000004',
     '0f300000-0000-0000-0000-000000000004',
     2, 150.00),   -- Arjun: 2 participant @ ₹150

    ('0f400000-0000-0000-0000-000000000002',
     '61100000-0000-0000-0000-000000000005',
     '0f300000-0000-0000-0000-000000000005',
     1, 50.00),    -- Vikram: 1 spectator (shown as USD)

    ('0f400000-0000-0000-0000-000000000003',
     '61100000-0000-0000-0000-000000000001',
     '0f300000-0000-0000-0000-000000000001',
     3, 0.00),     -- Arjun: 3 general entry (free)

    ('0f400000-0000-0000-0000-000000000004',
     '61100000-0000-0000-0000-000000000011',
     '0f300000-0000-0000-0000-000000000004',
     1, 150.00);   -- Kiran: 1 participant @ ₹150

-- ---------------------------------------------------------------------------
-- Sponsor notification
-- ---------------------------------------------------------------------------
INSERT INTO core.notification (id, user_id, event_id, type, title, message, is_read) VALUES
    ('b1100000-0000-0000-0000-000000000009',
     '31100000-0000-0000-0000-000000000007',
     '51100000-0000-0000-0000-000000000001',
     'payment_success', 'Sponsorship confirmed — Diwali Mela 2025',
     'Your sponsorship of ₹25,000 for Diwali Mela 2025 has been received. Thank you!',
     TRUE),

    ('b1100000-0000-0000-0000-000000000010',
     '31100000-0000-0000-0000-000000000007',
     '51100000-0000-0000-0000-000000000002',
     'refund_processed', 'Refund request submitted — Annual Sports Day 2026',
     'Your refund request of ₹5,000 is under review. You will be notified once approved.',
     FALSE);
