# Smart Bookmarks - Complete Folder Structure

```
smart-bookmarks/
│
├── app/                                    # Next.js 14 App Router directory
│   ├── auth/                              # Authentication routes
│   │   ├── callback/                      # OAuth callback handling
│   │   │   └── route.ts                  # Server route for OAuth callback
│   │   └── auth-code-error/              # Error handling for failed auth
│   │       └── page.tsx                  # Error page component
│   │
│   ├── dashboard/                         # Protected dashboard route
│   │   └── page.tsx                      # Dashboard page (Server Component)
│   │
│   ├── login/                            # Login route
│   │   └── page.tsx                      # Login page component
│   │
│   ├── layout.tsx                        # Root layout (metadata, fonts)
│   ├── page.tsx                          # Home page (redirects to dashboard/login)
│   └── globals.css                       # Global styles with Tailwind directives
│
├── components/                            # Reusable React components
│   ├── BookmarkForm.tsx                  # Form to add new bookmarks (Client)
│   ├── BookmarkItem.tsx                  # Single bookmark display (Client)
│   ├── BookmarkList.tsx                  # List wrapper for bookmarks (Client)
│   ├── DashboardClient.tsx               # Dashboard logic with Realtime (Client)
│   ├── GoogleSignInButton.tsx            # Google OAuth login button (Client)
│   └── SignOutButton.tsx                 # Sign out functionality (Client)
│
├── lib/                                   # Utility libraries and helpers
│   ├── supabase/                         # Supabase client configurations
│   │   ├── client.ts                     # Browser client for Client Components
│   │   ├── server.ts                     # Server client for Server Components
│   │   └── middleware.ts                 # Middleware client for auth checks
│   │
│   └── types/                            # TypeScript type definitions
│       └── database.ts                   # Database schema types
│
├── middleware.ts                          # Next.js middleware (route protection)
│
├── .env.local.example                     # Example environment variables file
├── .gitignore                            # Git ignore rules
├── database.sql                          # Complete SQL schema and RLS policies
├── next.config.js                        # Next.js configuration
├── package.json                          # Project dependencies and scripts
├── postcss.config.js                     # PostCSS configuration for Tailwind
├── README.md                             # Main project documentation
├── SETUP.md                              # Detailed setup instructions
├── tailwind.config.js                    # Tailwind CSS configuration
└── tsconfig.json                         # TypeScript configuration

```

## File Descriptions

### Configuration Files

| File | Purpose |
|------|---------|
| `package.json` | Dependencies, scripts, and project metadata |
| `tsconfig.json` | TypeScript compiler configuration |
| `next.config.js` | Next.js framework configuration |
| `tailwind.config.js` | Tailwind CSS customization |
| `postcss.config.js` | PostCSS plugins (Tailwind, Autoprefixer) |
| `.gitignore` | Files and folders to exclude from Git |
| `.env.local.example` | Template for environment variables |

### Application Routes (App Router)

| Route | File | Type | Purpose |
|-------|------|------|---------|
| `/` | `app/page.tsx` | Server | Redirects to dashboard or login |
| `/login` | `app/login/page.tsx` | Server | Login page with Google OAuth |
| `/dashboard` | `app/dashboard/page.tsx` | Server | Main application dashboard |
| `/auth/callback` | `app/auth/callback/route.ts` | Server | Handles OAuth callback from Google |
| `/auth/auth-code-error` | `app/auth/auth-code-error/page.tsx` | Server | Error page for failed authentication |

### Components

| Component | Type | Purpose |
|-----------|------|---------|
| `BookmarkForm.tsx` | Client | Form for adding new bookmarks |
| `BookmarkItem.tsx` | Client | Displays a single bookmark with delete option |
| `BookmarkList.tsx` | Client | Renders list of bookmarks or empty state |
| `DashboardClient.tsx` | Client | Main dashboard logic with Realtime subscription |
| `GoogleSignInButton.tsx` | Client | Google OAuth sign-in button |
| `SignOutButton.tsx` | Client | Sign-out functionality |

### Library Files

| File | Purpose |
|------|---------|
| `lib/supabase/client.ts` | Supabase client for browser/Client Components |
| `lib/supabase/server.ts` | Supabase client for Server Components |
| `lib/supabase/middleware.ts` | Supabase client for middleware (auth checks) |
| `lib/types/database.ts` | TypeScript types for database schema |

### Database & Documentation

| File | Purpose |
|------|---------|
| `database.sql` | Complete SQL for tables, RLS policies, indexes |
| `README.md` | Main documentation and project overview |
| `SETUP.md` | Step-by-step setup and deployment guide |

## Key Architectural Decisions

### 1. App Router Over Pages Router
- Uses Next.js 14 App Router for better performance
- Server Components by default (Client Components only when needed)
- Nested layouts and route groups

### 2. Supabase Client Pattern
Three separate clients to handle different contexts:
- **Server Client**: For Server Components (uses cookies)
- **Browser Client**: For Client Components (localStorage)
- **Middleware Client**: For authentication checks

### 3. Component Organization
- **Server Components**: Data fetching, initial render
- **Client Components**: Interactivity, state management, Realtime
- Clear separation of concerns

### 4. Security-First Design
- Row Level Security enforced at database level
- Middleware protects all routes
- No sensitive keys in client code
- Proper session management

### 5. Real-time Architecture
- Supabase Realtime for instant updates
- Proper subscription cleanup
- Optimistic UI updates

## Environment Variables

Required variables in `.env.local`:

```env
NEXT_PUBLIC_SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

⚠️ **Security Notes:**
- Only use `NEXT_PUBLIC_` prefix for variables needed in browser
- Never commit `.env.local` to version control
- Never use `service_role` key in client-side code

## Build Output

When you run `npm run build`, Next.js creates:

```
.next/
├── server/           # Server-side code
├── static/          # Static assets
└── cache/           # Build cache
```

## Deployment Structure

When deployed to Vercel:

```
Vercel Edge Network
├── Static Assets (CDN)
├── Serverless Functions (API Routes)
└── Server Components (On-demand rendering)
```

---

This structure follows Next.js 14 best practices and provides a clear separation of concerns for maintainability and scalability.
