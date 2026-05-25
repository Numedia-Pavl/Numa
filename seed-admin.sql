-- ══════════════════════════════════════════════════════════
-- NUMA HRIS — Seed First Admin Account
-- Run AFTER schema.sql
-- Password below is: Admin@numa2024  ← CHANGE IMMEDIATELY after first login
-- ══════════════════════════════════════════════════════════

-- 1. Create a dummy employee record for the admin
INSERT INTO employees (
  employee_id, first_name, last_name, email,
  position, employment_type, employment_status, basic_pay
) VALUES (
  'ADMIN-001', 'System', 'Administrator', 'admin@yourcompany.com',
  'System Administrator', 'regular', 'active', 0
) ON CONFLICT (email) DO NOTHING;

-- 2. Create the admin user account
-- Password hash below = bcrypt('Admin@numa2024', 12)
INSERT INTO users (email, password_hash, full_name, roles, is_active, employee_id)
SELECT
  'admin@yourcompany.com',
  '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4oD3RGjVjC',
  'System Administrator',
  ARRAY['admin','hr','hr_manager','employee'],
  true,
  id
FROM employees WHERE email = 'admin@yourcompany.com'
ON CONFLICT (email) DO NOTHING;
