# NUMA HRIS v2.0
### Philippine MSME HR Information System

---

## For the Developer — Quick Reference

### Architecture
```
Browser (index.html)
    ↕ HTTPS + JWT
Backend (Node.js/Express on Railway)
    ↕ Supabase client
Database (PostgreSQL on Supabase)
```

### Local Development

```bash
# 1. Set up database (one-time)
# → Run backend/schema.sql in Supabase SQL Editor
# → Run backend/seed-admin.sql to create admin account

# 2. Configure backend
cd backend
cp .env.example .env
# → Fill in your Supabase URL, keys, and JWT secret

# 3. Install and run backend
npm install
npm run dev        # uses nodemon for auto-restart

# 4. Open frontend
# → Use VS Code Live Server on frontend/public/index.html
# → Or: npx serve frontend/public -p 5500
```

### Environment Variables (backend/.env)
```
SUPABASE_URL=         ← From Supabase Settings → API
SUPABASE_ANON_KEY=    ← From Supabase Settings → API
SUPABASE_SERVICE_KEY= ← From Supabase Settings → API (secret!)
JWT_SECRET=           ← Generate: node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
PORT=3001
NODE_ENV=development
FRONTEND_URL=http://localhost:5500
```

### API Endpoints Summary

| Method | Path | Access | Description |
|--------|------|--------|-------------|
| POST | /api/auth/login | Public | Login |
| GET | /api/auth/me | Any | Own user info |
| POST | /api/auth/change-password | Any | Change own password |
| GET | /api/employees | HR/Admin | List all employees |
| GET | /api/employees/me | Any | Own profile |
| GET | /api/employees/:id | HR or own | Single employee |
| POST | /api/employees | HR/Admin | Create employee |
| PUT | /api/employees/:id | HR/Admin | Update employee |
| GET | /api/payroll | HR/Admin | List payroll runs |
| GET | /api/payroll/my-payslips | Any | Own payslips |
| POST | /api/payroll/compute | HR/Admin | Preview computation |
| POST | /api/payroll/run | HR/Admin | Process payroll |
| GET | /api/leave | Role-filtered | Leave requests |
| GET | /api/leave/balance | Any | Own leave balance |
| POST | /api/leave | Any | File leave request |
| PUT | /api/leave/:id/approve | Supervisor/HR | Approve leave |
| PUT | /api/leave/:id/reject | Supervisor/HR | Reject leave |
| GET | /api/attendance | Role-filtered | Attendance records |
| POST | /api/attendance/clock-in | Any | Clock in |
| PUT | /api/attendance/clock-out | Any | Clock out |
| GET | /api/users | HR/Admin | List users |
| POST | /api/users | Admin | Create user |
| PUT | /api/users/:id | Admin | Update user |
| GET | /api/dashboard/summary | HR/Admin | Dashboard stats |

### User Roles
| Role | Access |
|------|--------|
| employee | Own profile, payslips, attendance, leave |
| supervisor / manager | + Team leave approvals |
| hr / hr_manager / payroll_officer | + All HR modules |
| admin | Everything including user management |

### Payroll Computation (server-authoritative)
- **SSS**: 2024 contribution table (backend/utils/payroll.js)
- **PhilHealth**: 5% total, split 50/50, capped at ₱100,000 MSC
- **Pag-IBIG**: 2% employee + 2% employer, capped at ₱100 each
- **Withholding Tax**: TRAIN Law 2024 monthly brackets

### Deployment
See `HOSTING_GUIDE.md` for full deployment instructions.

### Default Login (after running seed-admin.sql)
- Email: admin@yourcompany.com
- Password: Admin@numa2024
- ⚠️ Change immediately after first login!
