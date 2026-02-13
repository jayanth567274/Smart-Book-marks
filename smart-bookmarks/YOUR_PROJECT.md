# 🚀 Your Supabase Project - Ready to Go!

## ✅ Your Credentials Are Already Configured!

**Project URL:** `https://uwarjonwvynhiiapqxfv.supabase.co`  
**Anon Key:** Already added to `.env.local` ✅

Your `.env.local` file is completely configured. You can skip the manual setup!

## 🎯 Quick Start (Just 3 Steps!)

### 1. Install Dependencies

```bash
npm install
```

### 2. Set Up Database

1. Go to SQL Editor: https://supabase.com/dashboard/project/uwarjonwvynhiiapqxfv/sql
2. Click **New query**
3. Copy the entire contents of `database.sql`
4. Paste and click **Run** (or Cmd/Ctrl + Enter)

You should see success messages for:
- ✅ CREATE TABLE bookmarks
- ✅ CREATE INDEX
- ✅ ALTER TABLE (Enable RLS)
- ✅ CREATE POLICY (4 policies)

### 3. Configure Google OAuth

1. Go to Google Cloud Console: https://console.cloud.google.com/
2. Create OAuth 2.0 credentials (see SETUP.md for details)
3. Add these redirect URIs:
   - `http://localhost:3000/auth/callback` (for development)
   - `https://uwarjonwvynhiiapqxfv.supabase.co/auth/v1/callback` (for Supabase)
4. Add your Google OAuth credentials to Supabase:
   - Go to: https://supabase.com/dashboard/project/uwarjonwvynhiiapqxfv/auth/providers
   - Enable Google provider
   - Add your Client ID and Client Secret

### 4. Start Development

```bash
npm run dev
```

Open http://localhost:3000 and you're ready to go! 🎉

1. In Supabase dashboard, go to **SQL Editor**
2. Click **New query**
3. Copy the entire contents of `database.sql`
4. Paste and click **Run** (or Cmd/Ctrl + Enter)

You should see messages like:
```
CREATE TABLE
CREATE INDEX
ALTER TABLE
CREATE POLICY
...
```

### 3. Configure Google OAuth

Follow these steps from `SETUP.md`:
- Create Google Cloud OAuth credentials
- Add your Supabase callback URL: `https://uwarjonwvynhiiapqxfv.supabase.co/auth/v1/callback`
- Add credentials to Supabase Auth settings

### 4. Verify Setup

Check if everything is working:

```sql
-- Run this in Supabase SQL Editor
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'bookmarks';
-- Should return: rowsecurity = true
```

### 5. Start Development

```bash
npm install
npm run dev
```

## Your .env.local File

Already created with your Supabase URL! Just add your anon key:

```env
NEXT_PUBLIC_SUPABASE_URL=https://uwarjonwvynhiiapqxfv.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_actual_anon_key_here
```

## Important URLs

- **Supabase Dashboard:** https://supabase.com/dashboard/project/uwarjonwvynhiiapqxfv
- **Database Editor:** https://supabase.com/dashboard/project/uwarjonwvynhiiapqxfv/editor
- **SQL Editor:** https://supabase.com/dashboard/project/uwarjonwvynhiiapqxfv/sql
- **Authentication:** https://supabase.com/dashboard/project/uwarjonwvynhiiapqxfv/auth/users
- **API Settings:** https://supabase.com/dashboard/project/uwarjonwvynhiiapqxfv/settings/api

## ✅ Pre-Configured Checklist

- [x] ~~Get anon key from Supabase~~ **Already done!**
- [x] ~~Add credentials to `.env.local`~~ **Already done!**
- [ ] Run `database.sql` in SQL Editor
- [ ] Verify RLS is enabled
- [ ] Set up Google OAuth in Google Cloud Console
- [ ] Add Google OAuth credentials to Supabase Auth
- [ ] Run `npm install`
- [ ] Run `npm run dev`
- [ ] Test login with Google
- [ ] Test adding a bookmark
- [ ] Test realtime sync (open 2 tabs)

---

**You're 80% done!** Just run the database setup and configure Google OAuth, then you're ready to code!
