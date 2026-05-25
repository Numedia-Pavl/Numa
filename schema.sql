-- ╔══════════════════════════════════════════════════════════╗
-- ║  NUMA HRIS — PostgreSQL Schema v2.0                      ║
-- ║  Run this in: Supabase > SQL Editor > New Query          ║
-- ╚══════════════════════════════════════════════════════════╝

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── DEPARTMENTS ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS departments (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name        TEXT NOT NULL UNIQUE,
  code        TEXT,
  description TEXT,
  is_active   BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── EMPLOYEES ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS employees (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  employee_id       TEXT UNIQUE,                          -- e.g. EMP-2024-001
  first_name        TEXT NOT NULL,
  last_name         TEXT NOT NULL,
  middle_name       TEXT,
  email             TEXT UNIQUE,
  phone             TEXT,
  address           TEXT,
  date_of_birth     DATE,
  gender            TEXT CHECK (gender IN ('male','female','other')),
  civil_status      TEXT,

  -- Employment
  position          TEXT,
  department_id     UUID REFERENCES departments(id),
  supervisor_id     UUID REFERENCES employees(id),
  date_hired        DATE,
  employment_type   TEXT DEFAULT 'regular' CHECK (employment_type IN ('regular','probationary','contractual','part_time')),
  employment_status TEXT DEFAULT 'active'  CHECK (employment_status IN ('active','inactive','terminated','resigned')),
  basic_pay         NUMERIC(12,2) DEFAULT 0,
  allowances        NUMERIC(12,2) DEFAULT 0,

  -- Government IDs
  sss_number        TEXT,
  philhealth_number TEXT,
  pagibig_number    TEXT,
  tin_number        TEXT,

  -- Emergency contact
  emergency_contact_name  TEXT,
  emergency_contact_phone TEXT,
  emergency_contact_relation TEXT,

  archived_at       TIMESTAMPTZ,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- ── USERS (login accounts) ────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email         TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  full_name     TEXT NOT NULL,
  roles         TEXT[] DEFAULT ARRAY['employee'],
  employee_id   UUID REFERENCES employees(id),
  is_active     BOOLEAN DEFAULT TRUE,
  last_login    TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ── LEAVE BALANCES ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS leave_balances (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  employee_id     UUID UNIQUE REFERENCES employees(id) ON DELETE CASCADE,
  sick_leave      NUMERIC(5,1) DEFAULT 15,
  vacation_leave  NUMERIC(5,1) DEFAULT 15,
  emergency_leave NUMERIC(5,1) DEFAULT 3,
  year            INT DEFAULT EXTRACT(YEAR FROM NOW()),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ── LEAVE REQUESTS ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS leave_requests (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  employee_id UUID NOT NULL REFERENCES employees(id),
  leave_type  TEXT NOT NULL CHECK (leave_type IN ('sick','vacation','emergency','maternity','paternity','other')),
  start_date  DATE NOT NULL,
  end_date    DATE NOT NULL,
  days_count  NUMERIC(4,1) GENERATED ALWAYS AS (end_date - start_date + 1) STORED,
  reason      TEXT,
  status      TEXT DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected','cancelled')),
  remarks     TEXT,
  approved_by UUID REFERENCES users(id),
  approved_at TIMESTAMPTZ,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── ATTENDANCE ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS attendance (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  employee_id      UUID NOT NULL REFERENCES employees(id),
  date             DATE NOT NULL,
  clock_in         TIME,
  clock_out        TIME,
  status           TEXT DEFAULT 'present' CHECK (status IN ('present','absent','half_day','on_leave','holiday')),
  late_minutes     INT DEFAULT 0,
  overtime_minutes INT DEFAULT 0,
  days_absent      NUMERIC(3,1) DEFAULT 0,
  notes            TEXT,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(employee_id, date)
);

-- ── PAYROLL RUNS ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS payroll_runs (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  period_start DATE NOT NULL,
  period_end   DATE NOT NULL,
  pay_date     DATE NOT NULL,
  status       TEXT DEFAULT 'draft' CHECK (status IN ('draft','processing','completed','cancelled')),
  created_by   UUID REFERENCES users(id),
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ── PAYROLL RECORDS (individual payslips) ─────────────────
CREATE TABLE IF NOT EXISTS payroll_records (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  payroll_run_id   UUID NOT NULL REFERENCES payroll_runs(id),
  employee_id      UUID NOT NULL REFERENCES employees(id),
  basic_pay        NUMERIC(12,2),
  allowances       NUMERIC(12,2) DEFAULT 0,
  overtime_pay     NUMERIC(12,2) DEFAULT 0,
  gross_pay        NUMERIC(12,2),
  -- Deductions
  sss_ee           NUMERIC(10,2) DEFAULT 0,
  sss_er           NUMERIC(10,2) DEFAULT 0,
  philhealth_ee    NUMERIC(10,2) DEFAULT 0,
  philhealth_er    NUMERIC(10,2) DEFAULT 0,
  pagibig_ee       NUMERIC(10,2) DEFAULT 0,
  pagibig_er       NUMERIC(10,2) DEFAULT 0,
  withholding_tax  NUMERIC(12,2) DEFAULT 0,
  other_deductions NUMERIC(12,2) DEFAULT 0,
  total_deductions NUMERIC(12,2),
  net_pay          NUMERIC(12,2),
  computation_details JSONB,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(payroll_run_id, employee_id)
);

-- ── ACTIVITY LOGS ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS activity_logs (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID REFERENCES users(id),
  action      TEXT NOT NULL,
  description TEXT,
  ip_address  TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── INDEXES ───────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_employees_status       ON employees(employment_status);
CREATE INDEX IF NOT EXISTS idx_employees_department   ON employees(department_id);
CREATE INDEX IF NOT EXISTS idx_attendance_date        ON attendance(date);
CREATE INDEX IF NOT EXISTS idx_attendance_employee    ON attendance(employee_id);
CREATE INDEX IF NOT EXISTS idx_leave_employee         ON leave_requests(employee_id);
CREATE INDEX IF NOT EXISTS idx_leave_status           ON leave_requests(status);
CREATE INDEX IF NOT EXISTS idx_payroll_records_run    ON payroll_records(payroll_run_id);
CREATE INDEX IF NOT EXISTS idx_activity_logs_user     ON activity_logs(user_id);

-- ── SEED: Default Departments ──────────────────────────────
INSERT INTO departments (name, code) VALUES
  ('Human Resources', 'HR'),
  ('Finance',         'FIN'),
  ('Operations',      'OPS'),
  ('Information Technology', 'IT'),
  ('Sales & Marketing', 'SALES'),
  ('Administration',  'ADMIN')
ON CONFLICT (name) DO NOTHING;

-- ╔══════════════════════════════════════════════════════════╗
-- ║  NEXT STEP: Create your first admin account             ║
-- ║  Run the seed-admin.sql file or use the app's           ║
-- ║  /api/auth/setup-admin endpoint (first run only).       ║
-- ╚══════════════════════════════════════════════════════════╝
