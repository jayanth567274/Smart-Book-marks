# Smart Bookmarks - Architecture Diagram

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                           USER BROWSER                               │
│                                                                       │
│  ┌──────────────────┐        ┌──────────────────┐                   │
│  │   Login Page     │        │    Dashboard     │                   │
│  │  (/login)        │        │  (/dashboard)    │                   │
│  │                  │        │                  │                   │
│  │  ┌────────────┐  │        │  ┌────────────┐ │                   │
│  │  │   Google   │  │        │  │  Bookmark  │ │                   │
│  │  │   OAuth    │  │        │  │    List    │ │                   │
│  │  │   Button   │  │        │  │  (Realtime)│ │                   │
│  │  └────────────┘  │        │  └────────────┘ │                   │
│  └──────────────────┘        └──────────────────┘                   │
│           │                            │                             │
│           │                            │                             │
│           ▼                            ▼                             │
│  ┌────────────────────────────────────────────────┐                 │
│  │         Next.js Middleware Layer               │                 │
│  │  • Checks auth.getUser()                       │                 │
│  │  • Redirects if not authenticated              │                 │
│  │  • Refreshes session tokens                    │                 │
│  └────────────────────────────────────────────────┘                 │
└───────────────────────────┬───────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        VERCEL HOSTING                                │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                    Next.js 14 App Router                        │ │
│  │                                                                  │ │
│  │  Server Components:          Client Components:                 │ │
│  │  • app/page.tsx             • DashboardClient.tsx              │ │
│  │  • app/dashboard/page.tsx   • BookmarkForm.tsx                 │ │
│  │  • app/login/page.tsx       • BookmarkItem.tsx                 │ │
│  │                              • GoogleSignInButton.tsx          │ │
│  │                                                                  │ │
│  │  Server Routes:                                                  │ │
│  │  • /auth/callback (OAuth handler)                              │ │
│  └────────────────────────────────────────────────────────────────┘ │
└────────────────────────────┬──────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          SUPABASE                                    │
│                                                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    Authentication                             │  │
│  │  ┌─────────────┐                                              │  │
│  │  │   Google    │  OAuth 2.0 Flow:                            │  │
│  │  │   OAuth     │  1. User clicks "Sign in with Google"       │  │
│  │  │  Provider   │  2. Redirect to Google                       │  │
│  │  └─────────────┘  3. User approves                            │  │
│  │         │          4. Google → Supabase callback              │  │
│  │         ▼          5. Supabase → App callback                 │  │
│  │  ┌─────────────┐  6. Session created                          │  │
│  │  │   Session   │                                               │  │
│  │  │  Management │                                               │  │
│  │  └─────────────┘                                               │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                PostgreSQL Database                            │  │
│  │                                                                │  │
│  │  ┌────────────────────────────────────────────────┐           │  │
│  │  │         bookmarks TABLE                        │           │  │
│  │  │  ┌──────────────────────────────────────────┐  │           │  │
│  │  │  │ id          │ UUID (PK)                  │  │           │  │
│  │  │  │ user_id     │ UUID → auth.users(id)      │  │           │  │
│  │  │  │ title       │ TEXT                       │  │           │  │
│  │  │  │ url         │ TEXT                       │  │           │  │
│  │  │  │ created_at  │ TIMESTAMPTZ                │  │           │  │
│  │  │  └──────────────────────────────────────────┘  │           │  │
│  │  │                                                  │           │  │
│  │  │  Row Level Security (RLS) Policies:             │           │  │
│  │  │  ✓ INSERT: auth.uid() = user_id                │           │  │
│  │  │  ✓ SELECT: auth.uid() = user_id                │           │  │
│  │  │  ✓ DELETE: auth.uid() = user_id                │           │  │
│  │  │  ✓ UPDATE: auth.uid() = user_id                │           │  │
│  │  └────────────────────────────────────────────────┘           │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    Realtime Engine                            │  │
│  │                                                                │  │
│  │  WebSocket Connection:                                        │  │
│  │  • Listens to postgres_changes                               │  │
│  │  • Filters by user_id                                         │  │
│  │  • Broadcasts INSERT/UPDATE/DELETE events                    │  │
│  │  • Multiple tabs stay in sync                                │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagrams

### 1. User Login Flow

```
User                  Next.js                Google               Supabase
 │                      │                       │                     │
 │  Click "Sign in"    │                       │                     │
 ├────────────────────>│                       │                     │
 │                      │  Redirect to Google   │                     │
 │                      ├──────────────────────>│                     │
 │                      │                       │                     │
 │  Approve consent     │                       │                     │
 ├──────────────────────────────────────────────>│                     │
 │                      │                       │                     │
 │                      │  Authorization code   │                     │
 │                      │<──────────────────────┤                     │
 │                      │                       │                     │
 │                      │  Exchange code for session                  │
 │                      ├─────────────────────────────────────────────>│
 │                      │                       │                     │
 │                      │  Session tokens (JWT) │                     │
 │                      │<─────────────────────────────────────────────┤
 │                      │                       │                     │
 │  Redirect to /dashboard                     │                     │
 │<─────────────────────┤                       │                     │
 │                      │                       │                     │
```

### 2. Add Bookmark Flow

```
User                DashboardClient        Supabase DB         Realtime
 │                      │                       │                 │
 │  Fill form & submit │                       │                 │
 ├────────────────────>│                       │                 │
 │                      │                       │                 │
 │                      │  INSERT bookmark      │                 │
 │                      │  WITH user_id         │                 │
 │                      ├──────────────────────>│                 │
 │                      │                       │                 │
 │                      │  RLS checks:          │                 │
 │                      │  auth.uid() = user_id │                 │
 │                      │                       │                 │
 │                      │  ✓ Allowed            │                 │
 │                      │<──────────────────────┤                 │
 │                      │                       │                 │
 │                      │                       │  Broadcast      │
 │                      │                       │  INSERT event   │
 │                      │                       ├────────────────>│
 │                      │                       │                 │
 │                      │  Realtime notification                  │
 │                      │<────────────────────────────────────────┤
 │                      │                       │                 │
 │  UI updates          │                       │                 │
 │  (new bookmark shown)                        │                 │
 │<─────────────────────┤                       │                 │
 │                      │                       │                 │
```

### 3. Realtime Sync Across Tabs

```
Tab 1               Supabase Realtime         Tab 2
 │                        │                      │
 │  Add bookmark          │                      │
 ├───────────────────────>│                      │
 │                        │                      │
 │                        │  Broadcast INSERT    │
 │                        ├─────────────────────>│
 │                        │                      │
 │                        │                      │  Update UI
 │                        │                      │  Show new bookmark
 │                        │                      │<─┘
 │                        │                      │
```

### 4. Row Level Security in Action

```
User A (auth.uid = aaa)         Database RLS           User B (auth.uid = bbb)
     │                               │                           │
     │  SELECT * FROM bookmarks      │                           │
     ├──────────────────────────────>│                           │
     │                               │                           │
     │  RLS applies filter:          │                           │
     │  WHERE user_id = 'aaa'        │                           │
     │                               │                           │
     │  Returns User A's bookmarks   │                           │
     │<──────────────────────────────┤                           │
     │                               │                           │
     │                               │  SELECT * FROM bookmarks  │
     │                               │<──────────────────────────┤
     │                               │                           │
     │                               │  RLS applies filter:      │
     │                               │  WHERE user_id = 'bbb'    │
     │                               │                           │
     │                               │  Returns User B's bookmarks
     │                               ├──────────────────────────>│
     │                               │                           │

Result: User A CANNOT see User B's data, even with same query!
```

## Component Communication

```
┌────────────────────────────────────────────────┐
│         app/dashboard/page.tsx                  │
│         (Server Component)                      │
│                                                 │
│  1. Gets user from Supabase                    │
│  2. Fetches initial bookmarks                  │
│  3. Passes data to client component            │
└────────────────────┬───────────────────────────┘
                     │
                     ▼
┌────────────────────────────────────────────────┐
│         DashboardClient.tsx                     │
│         (Client Component)                      │
│                                                 │
│  • Manages bookmarks state                     │
│  • Sets up Realtime subscription               │
│  • Handles add/delete operations               │
└────┬────────────────────────┬──────────────────┘
     │                        │
     ▼                        ▼
┌──────────────┐      ┌─────────────────┐
│ BookmarkForm │      │  BookmarkList   │
│              │      │                 │
│ • Title      │      │  • Maps items   │
│ • URL        │      │  • Empty state  │
│ • Submit     │      │                 │
└──────────────┘      └────────┬────────┘
                               │
                               ▼
                      ┌──────────────────┐
                      │  BookmarkItem    │
                      │                  │
                      │  • Display       │
                      │  • Delete button │
                      └──────────────────┘
```

## Security Layers

```
┌───────────────────────────────────────────────────┐
│  Layer 1: Next.js Middleware                      │
│  • Checks if user is authenticated                │
│  • Redirects to /login if not                     │
│  • Runs on EVERY request                          │
└───────────────────────────────────────────────────┘
                      │
                      ▼
┌───────────────────────────────────────────────────┐
│  Layer 2: Supabase Auth                           │
│  • Validates JWT tokens                           │
│  • Provides auth.uid() for RLS                    │
│  • Manages sessions                               │
└───────────────────────────────────────────────────┘
                      │
                      ▼
┌───────────────────────────────────────────────────┐
│  Layer 3: Row Level Security (RLS)                │
│  • PostgreSQL-level security                      │
│  • Cannot be bypassed                             │
│  • Enforces user data isolation                   │
└───────────────────────────────────────────────────┘
```

## Key Benefits of This Architecture

1. **Security First**
   - Multiple security layers
   - Database-level protection
   - No way to bypass RLS

2. **Real-time Sync**
   - Instant updates across devices
   - No polling required
   - Efficient WebSocket connection

3. **Performance**
   - Server Components for initial load
   - Client Components only where needed
   - Optimized database queries

4. **Scalability**
   - Serverless architecture
   - Auto-scaling database
   - CDN for static assets

5. **Developer Experience**
   - Type-safe with TypeScript
   - Clear separation of concerns
   - Easy to understand and maintain
