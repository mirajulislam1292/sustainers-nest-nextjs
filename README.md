# Sustainers NEST

The new public website and application foundation for [sustainersnest.org](https://sustainersnest.org).

## Run locally

```bash
pnpm install
cp .env.example .env.local
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000).

## Checks

```bash
pnpm lint
pnpm build
```

## Structure

- `src/app` — Next.js App Router pages and metadata
- `src/components` — shared layout and shadcn/ui primitives
- `src/data/site.ts` — verified content migrated from the legacy site
- `supabase/migrations` — deployable backend schema, five-role RBAC, RLS and storage policies
- `src/app/dashboard` — protected operational workspace for members
- `src/app/api` — validated public submission endpoints
- `architecture-and-migration.md` — backend and migration blueprint
- `legacy-static` — preserved previous static implementation

## Connect Supabase

1. Create a Supabase project and run `supabase/migrations/20260929202035_initial_platform.sql` in its SQL editor (or link the CLI and push the migration).
2. Enable Google under Authentication → Providers and add the Google client ID and secret.
3. Add `http://localhost:3000/auth/callback` and the production callback URL to Supabase redirect URLs.
4. Add the project URL, publishable key and secret key to `.env.local` using `.env.example`.
5. After the first approved Workspace user signs in, run the documented one-time `super_admin` bootstrap statement at the bottom of the migration.

Only Google users with an `@sustainersnest.org` address can be provisioned. Public forms return a clear email fallback until Supabase is configured; secret keys never enter client bundles.
