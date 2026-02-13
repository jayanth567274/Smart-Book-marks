# 🔖 Smart Bookmarks

A modern, real-time bookmark management application built with Next.js 14, Supabase, and Google OAuth. Save, organize, and access your favorite links from anywhere with automatic synchronization across all your devices.

![Smart Bookmarks](https://img.shields.io/badge/Next.js-14+-black?style=flat&logo=next.js)
![Supabase](https://img.shields.io/badge/Supabase-Powered-green?style=flat&logo=supabase)
![TypeScript](https://img.shields.io/badge/TypeScript-5+-blue?style=flat&logo=typescript)
![Tailwind CSS](https://img.shields.io/badge/Tailwind-CSS-38B2AC?style=flat&logo=tailwind-css)

## ✨ Features

- **🔐 Secure Authentication**: Google OAuth integration via Supabase Auth
- **⚡ Real-time Sync**: Automatic updates across all open tabs and devices using Supabase Realtime
- **🛡️ Row Level Security**: Database-level security ensures users can only access their own bookmarks
- **🎨 Modern UI**: Clean, responsive design built with Tailwind CSS
- **📱 Mobile Friendly**: Fully responsive layout that works on all devices
- **🚀 Fast & Scalable**: Built on Next.js 14 App Router for optimal performance
- **☁️ Cloud Hosted**: Serverless architecture with Vercel and Supabase

## 🛠️ Tech Stack

### Frontend
- **[Next.js 14](https://nextjs.org/)** - React framework with App Router
- **[React 18](https://react.dev/)** - UI library
- **[TypeScript](https://www.typescriptlang.org/)** - Type safety
- **[Tailwind CSS](https://tailwindcss.com/)** - Utility-first CSS framework

### Backend & Database
- **[Supabase](https://supabase.com/)** - Backend as a Service
  - PostgreSQL database
  - Authentication (Google OAuth)
  - Row Level Security (RLS)
  - Realtime subscriptions
  - Serverless functions

### Deployment
- **[Vercel](https://vercel.com/)** - Hosting and deployment platform

## 📋 Prerequisites

Before you begin, ensure you have the following installed:
- Node.js 18.x or higher
- npm or yarn package manager
- A Supabase account (free tier is sufficient)
- A Google Cloud account (for OAuth setup)
- A Vercel account (for deployment)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/smart-bookmarks.git
cd smart-bookmarks
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Set Up Environment Variables

Create a `.env.local` file in the root directory:

```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 4. Set Up Supabase Database

1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy the contents of `database.sql` and execute it
4. This will create the `bookmarks` table and set up RLS policies

### 5. Configure Google OAuth

See the [SETUP.md](SETUP.md) file for detailed instructions on configuring Google OAuth.

### 6. Run the Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to see your app!

## 📁 Project Structure

```
smart-bookmarks/
├── app/                          # Next.js App Router
│   ├── auth/                     # Auth-related routes
│   │   ├── callback/            # OAuth callback handler
│   │   └── auth-code-error/     # Error page
│   ├── dashboard/               # Main dashboard page
│   │   └── page.tsx
│   ├── login/                   # Login page
│   │   └── page.tsx
│   ├── layout.tsx               # Root layout
│   ├── page.tsx                 # Home page (redirects)
│   └── globals.css              # Global styles
├── components/                   # React components
│   ├── BookmarkForm.tsx         # Form to add bookmarks
│   ├── BookmarkItem.tsx         # Individual bookmark display
│   ├── BookmarkList.tsx         # List of bookmarks
│   ├── DashboardClient.tsx      # Main dashboard client component
│   ├── GoogleSignInButton.tsx   # Google OAuth button
│   └── SignOutButton.tsx        # Sign out button
├── lib/                         # Utility functions
│   ├── supabase/               # Supabase client utilities
│   │   ├── client.ts           # Browser client
│   │   ├── server.ts           # Server client
│   │   └── middleware.ts       # Middleware client
│   └── types/                  # TypeScript types
│       └── database.ts         # Database type definitions
├── middleware.ts               # Next.js middleware (auth)
├── database.sql               # Database schema and RLS policies
├── SETUP.md                   # Detailed setup guide
└── README.md                  # This file
```

## 🔒 Security Implementation

### Row Level Security (RLS)

The application implements comprehensive Row Level Security policies to ensure data isolation:

#### Database Schema
```sql
CREATE TABLE public.bookmarks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  url TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
```

#### RLS Policies

1. **INSERT Policy**: Users can only create bookmarks for themselves
   ```sql
   CREATE POLICY "Users can insert their own bookmarks"
   ON public.bookmarks FOR INSERT
   WITH CHECK (auth.uid() = user_id);
   ```

2. **SELECT Policy**: Users can only view their own bookmarks
   ```sql
   CREATE POLICY "Users can view their own bookmarks"
   ON public.bookmarks FOR SELECT
   USING (auth.uid() = user_id);
   ```

3. **DELETE Policy**: Users can only delete their own bookmarks
   ```sql
   CREATE POLICY "Users can delete their own bookmarks"
   ON public.bookmarks FOR DELETE
   USING (auth.uid() = user_id);
   ```

4. **UPDATE Policy**: Users can only update their own bookmarks
   ```sql
   CREATE POLICY "Users can update their own bookmarks"
   ON public.bookmarks FOR UPDATE
   USING (auth.uid() = user_id);
   ```

### Why RLS is Important

- **Database-level security**: Protection even if application code is compromised
- **Zero-trust architecture**: No user can access another user's data, period
- **Automatic enforcement**: Policies are enforced by PostgreSQL automatically
- **API-level protection**: Works with Supabase client, REST API, and GraphQL

### Authentication Flow

1. User clicks "Continue with Google"
2. Redirected to Google OAuth consent screen
3. After approval, Google redirects to Supabase callback URL
4. Supabase exchanges code for session
5. User is redirected to dashboard with authenticated session
6. All subsequent requests include user JWT token
7. RLS policies automatically filter queries based on `auth.uid()`

## 🔄 Real-time Functionality

### How It Works

The application uses Supabase Realtime to provide instant updates:

```typescript
useEffect(() => {
  const channel = supabase
    .channel('bookmarks-changes')
    .on('postgres_changes', {
      event: '*',
      schema: 'public',
      table: 'bookmarks',
      filter: `user_id=eq.${userId}`,
    }, (payload) => {
      // Handle INSERT, UPDATE, DELETE events
    })
    .subscribe()

  return () => {
    supabase.removeChannel(channel)
  }
}, [userId])
```

### Real-time Features

- **Instant sync**: Changes appear in all open tabs within milliseconds
- **Event-driven updates**: Only relevant changes trigger UI updates
- **Automatic cleanup**: Subscriptions are properly cleaned up on unmount
- **Filtered updates**: Only receives updates for the current user's bookmarks

## 🎯 Challenges Faced & Solutions

### Challenge 1: Managing Supabase Clients Across Server/Client Components

**Problem**: Next.js 14 App Router requires different client implementations for server components, client components, and middleware.

**Solution**: Created three separate Supabase client utilities:
- `lib/supabase/server.ts` - For Server Components (uses cookies)
- `lib/supabase/client.ts` - For Client Components (browser-based)
- `lib/supabase/middleware.ts` - For middleware (handles session refresh)

### Challenge 2: Proper Session Management in Middleware

**Problem**: Session cookies need to be refreshed without creating redirect loops.

**Solution**: Implemented proper middleware that:
- Checks authentication status
- Refreshes session if needed
- Redirects unauthenticated users to login
- Allows authenticated users through
- Properly handles OAuth callback routes

### Challenge 3: Real-time Subscription Memory Leaks

**Problem**: Subscriptions not being cleaned up properly could cause memory leaks.

**Solution**: 
- Used React's `useEffect` cleanup function
- Properly removed channel on component unmount
- Ensured subscriptions are filtered by user_id

### Challenge 4: TypeScript Type Safety with Supabase

**Problem**: Maintaining type safety across database operations.

**Solution**: Created comprehensive TypeScript types:
- Database schema types in `lib/types/database.ts`
- Proper typing for all Supabase queries
- Type-safe component props

### Challenge 5: OAuth Redirect URI Configuration

**Problem**: Complex redirect flow between Google OAuth → Supabase → Application.

**Solution**: 
- Properly configured all redirect URIs in Google Cloud Console
- Set up Supabase as the intermediary
- Handled both development and production URLs
- Created error handling page for failed authentications

## 🚀 Deployment Guide

### Deploying to Vercel

1. **Push to GitHub**
   ```bash
   git add .
   git commit -m "Ready for deployment"
   git push origin main
   ```

2. **Import to Vercel**
   - Go to [vercel.com](https://vercel.com)
   - Click "New Project"
   - Import your GitHub repository

3. **Configure Environment Variables**
   Add these in Vercel project settings:
   ```
   NEXT_PUBLIC_SUPABASE_URL
   NEXT_PUBLIC_SUPABASE_ANON_KEY
   ```

4. **Update OAuth Redirect URIs**
   After deployment, add your Vercel URL to:
   - Google Cloud Console (Authorized redirect URIs)
   - Supabase (Site URL in Authentication settings)

5. **Deploy**
   Click deploy and wait ~2 minutes

See [SETUP.md](SETUP.md) for detailed deployment instructions.

## 📱 Features Roadmap

### Planned Features
- [ ] Bookmark categories and tags
- [ ] Search and filter bookmarks
- [ ] Import bookmarks from browser
- [ ] Export bookmarks (JSON, CSV, HTML)
- [ ] Browser extension for one-click bookmarking
- [ ] Bookmark sharing (public links)
- [ ] Collections/folders
- [ ] Bookmark analytics (most visited, etc.)
- [ ] Dark mode improvements
- [ ] Keyboard shortcuts
- [ ] Bulk operations (delete, move, tag)
- [ ] Archive functionality
- [ ] Duplicate detection

### Future Improvements
- [ ] Full-text search with PostgreSQL FTS
- [ ] Automatic favicon fetching
- [ ] Link preview cards
- [ ] Broken link detection
- [ ] Backup and restore
- [ ] Multi-language support
- [ ] API endpoints for third-party integrations
- [ ] Collaborative collections

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Next.js](https://nextjs.org/) - The React Framework
- [Supabase](https://supabase.com/) - Open Source Firebase Alternative
- [Vercel](https://vercel.com/) - Deployment Platform
- [Tailwind CSS](https://tailwindcss.com/) - CSS Framework

## 📞 Support

If you have any questions or run into issues:
- Check the [SETUP.md](SETUP.md) for detailed setup instructions
- Review the [Troubleshooting](#troubleshooting) section
- Open an issue on GitHub
- Check [Supabase Documentation](https://supabase.com/docs)

## ⭐ Show Your Support

Give a ⭐️ if this project helped you!

---

**Built with ❤️ using Next.js and Supabase**
