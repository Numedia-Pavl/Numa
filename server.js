'use strict';
require('dotenv').config();

const express      = require('express');
const cors         = require('cors');
const helmet       = require('helmet');
const rateLimit    = require('express-rate-limit');

const authRoutes       = require('./routes/auth');
const employeeRoutes   = require('./routes/employees');
const payrollRoutes    = require('./routes/payroll');
const leaveRoutes      = require('./routes/leave');
const attendanceRoutes = require('./routes/attendance');
const userRoutes       = require('./routes/users');
const dashboardRoutes  = require('./routes/dashboard');

const app  = express();
const PORT = process.env.PORT || 3001;

// ── Security ─────────────────────────────────────────────
app.use(helmet({ contentSecurityPolicy: false }));
app.use(cors({
  origin: [
    process.env.FRONTEND_URL || 'http://localhost:5500',
    'http://127.0.0.1:5500',
    'http://localhost:3000'
  ],
  credentials: true
}));

// ── Rate Limiting ─────────────────────────────────────────
const limiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 300 });
const authLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 20,
  message: { success: false, message: 'Too many login attempts. Try again in 15 minutes.' }
});
app.use(limiter);

// ── Parsers ───────────────────────────────────────────────
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// ── Health Check ──────────────────────────────────────────
app.get('/health', (req, res) => {
  res.json({ status: 'ok', version: '2.0.0', timestamp: new Date().toISOString() });
});

// ── Routes ────────────────────────────────────────────────
app.use('/api/auth',       authLimiter, authRoutes);
app.use('/api/employees',  employeeRoutes);
app.use('/api/payroll',    payrollRoutes);
app.use('/api/leave',      leaveRoutes);
app.use('/api/attendance', attendanceRoutes);
app.use('/api/users',      userRoutes);
app.use('/api/dashboard',  dashboardRoutes);

// ── 404 ───────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

// ── Global Error Handler ─────────────────────────────────
app.use((err, req, res, next) => {
  console.error('[Error]', err.message);
  res.status(err.status || 500).json({
    success: false,
    message: process.env.NODE_ENV === 'production' ? 'Server error' : err.message
  });
});

app.listen(PORT, () => {
  console.log(`✅ NUMA HRIS Backend running on port ${PORT}`);
  console.log(`   Environment: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = app;
