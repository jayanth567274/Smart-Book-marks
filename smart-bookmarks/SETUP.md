# Smart Bookmarks - Complete Setup Guide

This guide will walk you through setting up the Smart Bookmarks application from scratch, including Supabase configuration, Google OAuth setup, and Vercel deployment.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Supabase Setup](#supabase-setup)
3. [Google OAuth Configuration](#google-oauth-configuration)
4. [Local Development Setup](#local-development-setup)
5. [Database Setup](#database-setup)
6. [Testing RLS Policies](#testing-rls-policies)
7. [Vercel Deployment](#vercel-deployment)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before you begin, make sure you have:
- Node.js 18.x or higher installed
- A Supabase account (free tier works fine)
- A Google Cloud account for OAuth
- A Vercel account (for deployment)
- Git installed on your machine

---

## Supabase Setup

### Step 1: Create a New Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Click "New Project"
3. Fill in the details:
   - **Name**: smart-bookmarks (or any name you prefer)
   - **Database Password**: Choose a strong password (save this!)
   - **Region**: Select the region closest to your users
4. Click "Create new project"
5. Wait for the project to be provisioned (takes ~2 minutes)

### Step 2: Get Your Supabase Credentials

1. Once your project is ready, go to **Project Settings** (gear icon in sidebar)
2. Navigate to **API** section
3. Copy the following values:
   - **Project URL** (looks like: `https://xxxxxxxxxxxxx.supabase.co`)
   - **anon public** key (a long JWT token)

**Keep these safe! You'll need them for environment variables.**

---

## Google OAuth Configuration

### Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a project" → "New Project"
3. Enter project name: `smart-bookmarks`
4. Click "Create"

### Step 2: Enable Google+ API

1. In your Google Cloud project, go to **APIs & Services** → **Library**
2. Search for "Google+ API"
3. Click on it and click "Enable"

### Step 3: Configure OAuth Consent Screen

1. Go to **APIs & Services** → **OAuth consent screen**
2. Select "External" user type
3. Click "Create"
4. Fill in the required fields:
   - **App name**: Smart Bookmarks
   - **User support email**: Your email
   - **Developer contact**: Your email
5. Click "Save and Continue"
6. Skip "Scopes" (click "Save and Continue")
7. Add test users if in development mode
8. Click "Save and Continue"

### Step 4: Create OAuth Credentials

1. Go to **APIs & Services** → **Credentials**
2. Click "Create Credentials" → "OAuth client ID"
3. Select "Web application"
4. Configure:
   - **Name**: Smart Bookmarks Web Client
   - **Authorized JavaScript origins**:
     - `http://localhost:3000` (for local dev)
     - Your Vercel domain (e.g., `https://your-app.vercel.app`)
   - **Authorized redirect URIs**:
     - `http://localhost:3000/auth/callback` (local)
     - `https://your-app.vercel.app/auth/callback` (production)
     - **IMPORTANT**: Add your Supabase callback URL:
       `https://YOUR_PROJECT_ID.supabase.co/auth/v1/callback`
5. Click "Create"
6. **Save your Client ID and Client Secret** - you'll need these!

### Step 5: Configure Google OAuth in Supabase

1. Go to your Supabase project dashboard
2. Navigate to **Authentication** → **Providers**
3. Find "Google" in the list
4. Enable it and fill in:
   - **Client ID**: Your Google OAuth Client ID
   - **Client Secret**: Your Google OAuth Client Secret
5. Click "Save"

### Step 6: Update Google OAuth Redirect URIs (Important!)

After enabling Google in Supabase, you'll see the callback URL:
```
https://YOUR_PROJECT_ID.supabase.co/auth/v1/callback
```

Make sure this URL is added to your Google OAuth credentials (Step 4 above).

---

## Local Development Setup

### Step 1: Clone/Create the Project

```bash
# Navigate to your projects folder
cd ~/projects

# Create the smart-bookmarks directory (if not exists)
mkdir smart-bookmarks
cd smart-bookmarks
```

### Step 2: Install Dependencies

```bash
npm install
```

### Step 3: Set Up Environment Variables

1. Copy the example environment file:
```bash
cp .env.local.example .env.local
```

2. Edit `.env.local` and add your Supabase credentials:
```env
NEXT_PUBLIC_SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

**Security Note**: Never commit `.env.local` to git! It's already in `.gitignore`.

---

## Database Setup

### Step 1: Run the SQL Schema

1. Go to your Supabase dashboard
2. Click on **SQL Editor** in the left sidebar
3. Click "New query"
4. Copy the entire contents of `database.sql` and paste it into the editor
5. Click "Run" (or press Cmd/Ctrl + Enter)

You should see success messages for each statement.

### Step 2: Verify the Setup

Run these verification queries in the SQL Editor:

```sql
-- Check if table exists and RLS is enabled
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'bookmarks';

-- Should return: rowsecurity = true

-- Check policies
SELECT * FROM pg_policies WHERE tablename = 'bookmarks';

-- Should return 4 policies (INSERT, SELECT, DELETE, UPDATE)
```

### Step 3: Enable Realtime (if not already enabled)

1. In Supabase dashboard, go to **Database** → **Replication**
2. Find the `bookmarks` table
3. Make sure it's enabled for Realtime
4. If not, click the toggle to enable it

---

## Testing RLS Policies

### Test 1: Verify Users Can Only See Their Own Data

1. Create two test accounts by logging in with different Google accounts
2. Add bookmarks with each account
3. Verify that:
   - User A can only see User A's bookmarks
   - User B can only see User B's bookmarks
   - No cross-user data leakage

### Test 2: Try Direct Database Access

In Supabase SQL Editor, try to bypass RLS (this should fail):

```sql
-- This should work (returns only your bookmarks)
SELECT * FROM bookmarks;

-- Try to select another user's bookmarks
-- (Replace USER_ID with another user's ID)
SELECT * FROM bookmarks WHERE user_id = 'ANOTHER_USER_ID';

-- This should return empty or only your data due to RLS
```

---

## Running Locally

```bash
# Start the development server
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### Testing Realtime Features

1. Open the app in two different browser windows/tabs
2. Sign in with the same account in both
3. Add a bookmark in one window
4. Watch it appear instantly in the other window!

---

## Vercel Deployment

### Step 1: Push to GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin YOUR_GITHUB_REPO_URL
git push -u origin main
```

### Step 2: Deploy to Vercel

1. Go to [https://vercel.com](https://vercel.com)
2. Click "New Project"
3. Import your GitHub repository
4. Configure the project:
   - **Framework Preset**: Next.js
   - **Root Directory**: ./
   - **Build Command**: `npm run build` (auto-detected)
   - **Output Directory**: `.next` (auto-detected)

### Step 3: Add Environment Variables in Vercel

1. In the project settings, go to "Environment Variables"
2. Add the following variables:
   ```
   NEXT_PUBLIC_SUPABASE_URL = https://xxxxxxxxxxxxx.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY = your_supabase_anon_key_here
   ```
3. Make sure to add them for all environments (Production, Preview, Development)

### Step 4: Update OAuth Redirect URLs

After deployment, get your Vercel URL (e.g., `https://smart-bookmarks.vercel.app`)

1. Go back to Google Cloud Console
2. Update **Authorized redirect URIs** to include:
   ```
   https://your-vercel-app.vercel.app/auth/callback
   ```
3. Update **Authorized JavaScript origins**:
   ```
   https://your-vercel-app.vercel.app
   ```

### Step 5: Deploy!

Click "Deploy" in Vercel. Your app will be live in ~2 minutes.

---

## Troubleshooting

### Issue: "Invalid login credentials" or OAuth errors

**Solution**: 
- Verify your Google OAuth Client ID and Secret in Supabase
- Check that redirect URIs match exactly (including trailing slashes)
- Make sure the Supabase callback URL is in Google OAuth settings

### Issue: Bookmarks not showing up

**Solution**:
- Check browser console for errors
- Verify RLS policies are correctly set up
- Make sure you're logged in with the correct account
- Check Supabase logs in the dashboard

### Issue: Realtime not working

**Solution**:
- Verify Realtime is enabled for the `bookmarks` table in Supabase
- Check that the subscription is being set up (console.log in useEffect)
- Make sure cleanup is happening properly

### Issue: "Failed to fetch" errors

**Solution**:
- Verify your Supabase URL and anon key are correct
- Check CORS settings in Supabase (should be automatic)
- Ensure the domain is in allowed domains (Supabase → Authentication → URL Configuration)

### Issue: Deployment fails on Vercel

**Solution**:
- Check build logs in Vercel dashboard
- Verify all dependencies are in `package.json`
- Make sure environment variables are set
- Try `npm run build` locally first

---

## Security Checklist

Before going to production, verify:

- ✅ RLS is enabled on all tables
- ✅ All policies are tested and working
- ✅ Environment variables are never committed to git
- ✅ Using `anon` key, NOT `service_role` key in client code
- ✅ HTTPS is enforced (automatic with Vercel)
- ✅ Google OAuth is configured with correct domains
- ✅ No sensitive data in client-side code

---

## Next Steps

- Add bookmark categories/tags
- Implement bookmark search
- Add import/export functionality
- Add browser extension
- Implement sharing features

---

## Support

If you run into issues:
1. Check the [Supabase Docs](https://supabase.com/docs)
2. Check the [Next.js Docs](https://nextjs.org/docs)
3. Review error messages in browser console
4. Check Supabase logs in the dashboard

---

**Congratulations! Your Smart Bookmarks app is now running! 🎉**
