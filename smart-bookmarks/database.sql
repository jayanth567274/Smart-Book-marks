-- 0. Optional: create a minimal schema-only backup (no data)
CREATE TABLE IF NOT EXISTS public.bookmarks_backup (LIKE public.bookmarks INCLUDING ALL);

-- 1. Ensure gen_random_uuid() is available
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 2. Set id default to gen_random_uuid (idempotent)
ALTER TABLE public.bookmarks
  ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- 3. Convert created_at to timestamptz and set NOT NULL/default
-- 3a. Fill NULLs with now() to allow NOT NULL
UPDATE public.bookmarks
SET created_at = now()
WHERE created_at IS NULL;

-- 3b. Alter column type converting timestamp -> timestamptz assuming stored values are UTC
ALTER TABLE public.bookmarks
  ALTER COLUMN created_at TYPE timestamptz
  USING created_at AT TIME ZONE 'UTC';

-- 3c. Ensure default and NOT NULL
ALTER TABLE public.bookmarks
  ALTER COLUMN created_at SET DEFAULT now(),
  ALTER COLUMN created_at SET NOT NULL;

-- 4. Add non-empty url constraint if missing (safe check)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'chk_bookmarks_url_nonempty'
  ) THEN
    ALTER TABLE public.bookmarks
      ADD CONSTRAINT chk_bookmarks_url_nonempty CHECK (char_length(url) > 0);
  END IF;
END$$;

-- 5. Create index if not exists
CREATE INDEX IF NOT EXISTS idx_bookmarks_user_created_at
  ON public.bookmarks (user_id, created_at DESC);

-- 6. Ensure RLS enabled (no-op if already)
ALTER TABLE public.bookmarks ENABLE ROW LEVEL SECURITY;

-- 7. Policies: drop if exists then create (idempotent)
DROP POLICY IF EXISTS bookmarks_select_authenticated ON public.bookmarks;
CREATE POLICY bookmarks_select_authenticated
  ON public.bookmarks
  FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS bookmarks_insert_authenticated ON public.bookmarks;
CREATE POLICY bookmarks_insert_authenticated
  ON public.bookmarks
  FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS bookmarks_update_authenticated ON public.bookmarks;
CREATE POLICY bookmarks_update_authenticated
  ON public.bookmarks
  FOR UPDATE
  TO authenticated
  USING ((SELECT auth.uid()) = user_id)
  WITH CHECK ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS bookmarks_delete_authenticated ON public.bookmarks;
CREATE POLICY bookmarks_delete_authenticated
  ON public.bookmarks
  FOR DELETE
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);

-- 8. Grants / revoke
GRANT SELECT, INSERT, UPDATE, DELETE ON public.bookmarks TO authenticated;
REVOKE ALL ON public.bookmarks FROM public;