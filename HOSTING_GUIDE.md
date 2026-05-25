# NUMA HRIS — Complete Hosting Guide
## For a 100-Employee Company on Enterprise Plan

---

## 📋 WHAT YOU HAVE

```
numa-hris-v2/
├── backend/                  ← Node.js API server
│   ├── server.js             ← Main entry point
│   ├── routes/               ← All API endpoints
│   │   ├── auth.js           ← Login, logout, change password
│   │   ├── employees.js      ← Employee CRUD
│   │   ├── payroll.js        ← Payroll processing
│   │   ├── leave.js          ← Leave requests & approvals
│   │   ├── attendance.js     ← Clock in/out
│   │   ├── users.js          ← User account management
│   │   └── dashboard.js      ← Dashboard summary
│   ├── middleware/
│   │   └── auth.js           ← JWT verification, role checks
│   ├── utils/
│   │   ├── supabase.js       ← Database client
│   │   └── payroll.js        ← PH contribution computations
│   ├── schema.sql            ← Run this first in Supabase
│   ├── seed-admin.sql        ← Creates your first admin account
│   ├── package.json
│   └── .env.example          ← Copy to .env and fill in values
└── frontend/
    └── public/
        ├── index.html        ← Entire frontend (one file!)
        └── manifest.json     ← PWA manifest
```

---

## 🚀 STEP 1: SET UP SUPABASE (Free Database)

**Time needed: 15 minutes**

1. Go to **https://supabase.com** → Sign up (free)
2. Click **"New project"**
   - Name: `numa-hris`
   - Database password: (save this somewhere safe!)
   - Region: **Southeast Asia (Singapore)**
3. Wait ~2 minutes for project to provision
4. Go to **SQL Editor** (left sidebar) → **New Query**
5. Paste contents of `backend/schema.sql` → Click **Run**
6. Run `backend/seed-admin.sql` in a new query

**Get your credentials:**
- Go to **Settings → API**
- Copy **Project URL** → this is your `SUPABASE_URL`
- Copy **anon public key** → this is your `SUPABASE_ANON_KEY`
- Copy **service_role secret** → this is your `SUPABASE_SERVICE_KEY`
  ⚠️ Keep the service_role key secret — never put it in frontend code!

---

## 🚀 STEP 2: DEPLOY BACKEND TO RAILWAY

**Time needed: 10 minutes | Cost: ~₱0/month (free tier)**

Railway gives you a free backend server perfect for 100 employees.

### Option A — Deploy via GitHub (Recommended)

1. Push your `backend/` folder to a GitHub repository
2. Go to **https://railway.app** → Sign up with GitHub
3. Click **"New Project"** → **"Deploy from GitHub repo"**
4. Select your repository
5. Railway auto-detects Node.js → Set:
   - **Root Directory**: `backend`
   - **Start Command**: `npm start`
6. Go to **Variables** tab and add:
   ```
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   SUPABASE_SERVICE_KEY=your-service-role-key
   JWT_SECRET=a-very-long-random-string-use-64-characters
   JWT_EXPIRES_IN=8h
   NODE_ENV=production
   FRONTEND_URL=https://your-frontend-domain.vercel.app
   ```
7. Click **Deploy** → Wait 2 minutes
8. Go to **Settings → Networking** → **Generate Domain**
9. Copy your Railway URL: `https://numa-hris-backend-xxxx.up.railway.app`

### Option B — Deploy via Railway CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# In your backend/ folder:
cd backend
railway init

# Set environment variables
railway variables set SUPABASE_URL=https://xxx.supabase.co
railway variables set SUPABASE_SERVICE_KEY=your-service-key
railway variables set JWT_SECRET=your-64-char-secret
railway variables set NODE_ENV=production

# Deploy
railway up
```

---

## 🚀 STEP 3: DEPLOY FRONTEND TO VERCEL

**Time needed: 5 minutes | Cost: ₱0 (forever free)**

1. **Before deploying**, open `frontend/public/index.html`
   - Find this line near the top of the `<script>`:
     ```javascript
     : 'https://YOUR-BACKEND.up.railway.app';  // ← Change this!
     ```
   - Replace with your actual Railway URL:
     ```javascript
     : 'https://numa-hris-backend-xxxx.up.railway.app';
     ```

2. Push your `frontend/` folder to GitHub

3. Go to **https://vercel.com** → Sign up with GitHub
4. Click **"Add New Project"** → Import your repository
5. Set:
   - **Root Directory**: `frontend/public`
   - **Framework Preset**: Other (static site)
6. Click **Deploy** → Done in ~1 minute!
7. Your app is live at: `https://numa-hris.vercel.app`

**Set a custom domain (optional):**
- In Vercel → Settings → Domains → Add `hris.yourcompany.com`
- Update your DNS records as instructed

---

## 🚀 STEP 4: FIRST LOGIN & SETUP

1. Open your Vercel URL in a browser
2. Login with:
   - Email: `admin@yourcompany.com`
   - Password: `Admin@numa2024`
3. **IMMEDIATELY** change the password:
   - Click your name at bottom left → Settings → Change Password
4. Go to **User Accounts** → Add accounts for your HR team
5. Go to **Employee Records** → Add your 100 employees
6. For each employee, create a **User Account** linked to their employee record

---

## 💰 COST BREAKDOWN FOR 100 EMPLOYEES

| Service | Plan | Monthly Cost |
|---------|------|-------------|
| Supabase | Free tier | ₱0 |
| Railway | Hobby plan | ~₱280 ($5) |
| Vercel | Free tier | ₱0 |
| **Total** | | **~₱280/month** |

**Your revenue from this client:**
- Enterprise plan: ₱3,000/mo + (100 × ₱150) = **₱18,000/month**
- Hosting cost: ₱280/month
- **Net margin: ₱17,720/month (98.4%)**

If Railway free tier is too limited, upgrade to Pro ($20/mo = ~₱1,120) — margin stays excellent.

---

## 📱 SHARING WITH EMPLOYEES

Once deployed, share this with your client's team:

**For Desktop/Laptop:** Open Chrome → go to your Vercel URL → bookmark it

**For Mobile (Install as App):**
1. Open Chrome on Android → go to your URL
2. Tap the 3-dot menu → "Add to Home Screen" → Install
   (Works like a native app!)

**For iPhone:**
1. Open Safari → go to your URL
2. Tap Share button → "Add to Home Screen"

---

## 🔒 SECURITY CHECKLIST

Before going live:
- [ ] Changed default admin password
- [ ] Set a strong JWT_SECRET (64+ random characters)
- [ ] Supabase service key is only in Railway env vars (never in frontend)
- [ ] FRONTEND_URL in Railway only allows your Vercel domain
- [ ] All employees have unique passwords (not shared)
- [ ] Enabled 2FA on your Railway and Supabase accounts

**Generate a secure JWT_SECRET:**
```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

---

## 🆘 TROUBLESHOOTING

**Login says "Server error" or can't connect:**
→ Check that your Railway backend is running (Railway dashboard → Deployments)
→ Verify SUPABASE_URL and SUPABASE_SERVICE_KEY are set correctly in Railway

**"Token expired or invalid":**
→ User's session expired (8 hours by default) — just log in again
→ If constant, check your JWT_SECRET is the same across all Railway instances

**Employee can't see their profile:**
→ Make sure the User Account is linked to the correct Employee record
→ Check via Admin → User Accounts → Edit → Link Employee

**Payroll amounts are wrong:**
→ Check employee's basic_pay is set correctly in Employee Records
→ Payroll is computed from basic_pay at time of run, not retroactively

---

## 📞 PHILIPPINE GOVERNMENT CONTRIBUTION CONTACTS

| Agency | Hotline |
|--------|---------|
| SSS Employer Line | 1455 |
| PhilHealth | 1-800-10-744-5832 |
| Pag-IBIG | 724-4244 |
| BIR Contact Center | 8538-3200 |
| DOLE | 1349 |

---

*NUMA HRIS v2.0 | Built for Philippine MSMEs*
*Stack: Node.js + Supabase + Vanilla JS PWA*
