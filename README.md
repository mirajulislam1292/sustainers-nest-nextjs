# Sustainers NEST

The new public website and application foundation for [sustainersnest.org](https://sustainersnest.org).

## Run locally

```bash
pnpm install
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
- `supabase-schema.sql` — proposed backend schema, RBAC, RLS and storage policies
- `architecture-and-migration.md` — backend and migration blueprint
- `legacy-static` — preserved previous static implementation

The public forms are intentionally preview-only until the Supabase project is connected. They do not transmit or store personal data.
