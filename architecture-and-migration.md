# Sustainers NEST application blueprint

Prepared from repository commit `bc891088872970417bb9163d287cbc3f15684836` on the `main` branch (2026-05-05), plus the live site and current Next.js/Supabase documentation.

## 1. Repository audit and reusable content

### What exists today

The repository is a multi-page static application, not React or Next.js. It uses HTML, one large CSS file, vanilla JavaScript, the Supabase browser CDN, and Vercel clean-URL rewrites.

Current routes:

- `/` — homepage
- `/about` — story, mission, vision, approach, timeline, team, partners
- `/programs` — programs and program-impact counters
- `/events` — upcoming events, past events, announcements
- `/get-involved` — pathways, application form, FAQ
- `/contact` — contact form and contact information
- `/signin`, `/signup` — email/password authentication
- `/admin` — a single-page admin interface for messages, applications, events, programs, announcements, team, stats, and subscribers

Current database objects are `profiles`, `events`, `programs`, `team_members`, `timeline_items`, `partners`, `faq_items`, `announcements`, `site_stats`, `page_sections`, `contact_submissions`, `join_applications`, `newsletter_subscribers`, and `event_registrations`.

### Verified copy worth preserving

**Positioning**

> Integrating Nature, Science & Technology for a Sustainable Future

> We nurture young innovators to harmonize ecological wisdom with cutting-edge technology—creating solutions that sustain our planet for generations to come.

**Mission**

> To empower young people with the knowledge, skills, and collaborative platforms to build innovative, nature-inspired solutions for a sustainable world through the integration of science and technology.

**Vision**

> A world where every young person is equipped to be an agent of sustainable change—where ecological wisdom and technological innovation work hand-in-hand to restore and protect our planet.

**Long-form organization description**

Sustainers NEST is described as a youth-driven organization founded in Bangladesh at the intersection of nature, science, and technology. It creates immersive programs, fosters research, and builds communities of young changemakers, from grassroots environmental projects to technology initiatives.

**Three pillars**

- Nature: ecosystem restoration, biomimicry design, regenerative agriculture.
- Science: climate research, material innovation, data-driven solutions.
- Technology: AI for sustainability, IoT and smart systems, renewable engineering.

**Programs currently named in the repository**

- Green Campus Initiative
- Youth Research Lab
- EcoTech Hackathons
- Earth Champions Program
- Sustainability Summits
- Kids for Nature

These have been seeded as `draft`, not `published`, in the new schema because the repository does not establish which claims have been verified by the organization.

**Existing contact information**

- Email: `info@sustainersnest.org`
- Location: Dhaka, Bangladesh
- Phone is only a placeholder: `+880 1XXX-XXXXXX`

### Missing or unverified data — do not invent it

- No real team member names exist. The seed data contains only “Founder,” “Vice President,” “Director of Tech,” and “Director of Outreach.”
- No real social links exist. Facebook, Instagram, LinkedIn, and YouTube anchors all use `href="#"`.
- No school-visit or impact photographs exist. The only image asset is `logo.jpg`.
- Partner names are placeholders (`Partner 1` through `Partner 5`).
- Several impact claims appear only as seed/demo counters: 500 young innovators, 50 projects, 12 countries, 2,500 trees, 1,200 community members, and similar figures. These should not ship as factual public claims until validated.
- The timeline claims a 2024 founding, a three-school pilot, a 200-person hackathon, and expansion to 12 countries. Confirm these before publishing.
- The README calls the repository confidential/proprietary even though it is publicly accessible; reconcile licensing and disclosure language.

### Immediate risks in the existing implementation

- Authentication is email/password with a two-value `admin/member` role model, not Google Workspace OAuth or the requested RBAC model.
- Admin authorization is partly based on one hard-coded Gmail address in SQL.
- The `SECURITY DEFINER` helper is created in the exposed `public` schema without explicitly revoking default function execution.
- All admin capabilities live in one browser-side script, which makes authorization easy to confuse with UI visibility.
- Public forms insert directly from the browser with no server-side bot control, rate limiting, or validation boundary.
- Rich content is stored as arbitrary HTML strings in a generic key/value table. This is difficult to validate, version, migrate, and render safely.

The public Supabase publishable/anonymous key is not itself a secret, but it should be provided through environment configuration rather than duplicated as a source fallback. The service-role key must never be exposed to the browser.

## 2. Product and visual direction

The redesign should feel like a field journal with institutional rigor, not a sustainability template.

### Public site

- Use a real school-visit photograph as the homepage’s dominant object. Prefer one editorial crop with a short caption, date, school, and photographer credit—not a carousel.
- Set the hero in a two-column editorial composition: concise statement and action on one side, full-bleed field photography on the other. On mobile, the image follows the statement.
- Present impact as a quiet typographic band: three large figures with plain-language definitions and “updated from approved reports” copy. Do not put each number in a card.
- Use story-led modules: one lead story, two secondary stories, then a chronological journal stream. Large photography, strong headlines, restrained metadata.
- Treat programs as a numbered index or chapter list with a supporting photograph, not six interchangeable cards.
- Use a readable serif for editorial headlines/body accents and a neutral sans-serif for navigation, metadata, forms, and the dashboard. Keep line length near 65–75 characters and body line height around 1.6–1.75.
- Color should come mainly from photography. The UI palette should be warm white, ink, a deep leaf green, and one muted clay or mustard accent.
- Avoid pills unless they perform filtering. Avoid decorative gradients, glowing orbs, floating badges, repeated eyebrow labels, and icon-first feature cards.

### Team directory

- Executive team: portrait-led rows or a two-column editorial grid with name, title, concise biography, and verified links.
- Core/general members: a compact, image-led directory with role and evidence-based impact badges (for example, “8 workshops” or “420 students”), calculated from approved visit assignments/reports.
- Never create beneficiary student profiles. Group photographs need school/guardian consent and a publication flag before they enter the public bucket.

### Internal dashboard

- Use a stable sidebar, page title, contextual actions, filters, and data tables. Do not turn every figure or action into a dashboard card.
- The default screen should show actionable queues: workshop requests awaiting review, reports awaiting approval, drafts awaiting editorial review, and upcoming visits requiring trainers.
- Use a right-side detail panel or dedicated detail route for review workflows; preserve list context.
- Make status, assignee, due date, and last activity scannable. Reserve color for status and risk.

## 3. Authorization model

Users can have more than one role. This is important because a volunteer may also be a blogger.

| Capability | Super Admin | Executive | Site Editor | Volunteer | Blogger |
|---|---:|---:|---:|---:|---:|
| Manage platform roles | Yes | No | No | No | No |
| Manage public team directory | Yes | Yes | No | No | No |
| Review workshop requests and visits | Yes | Yes | No | Assigned visits | No |
| Assign trainers | Yes | Yes | No | No | No |
| Submit visit reports | Yes | Yes | No | Assigned visits | No |
| Write personal journals | Yes | Yes | Yes | Yes | Optional if also a member |
| Review/publish journals | Yes | No | Yes | No | No |
| Draft blog/story posts | Yes | Optional | Yes | No | Yes |
| Publish editorial content | Yes | No | Yes | No | No |
| Read training resources | Yes | Yes | Yes | Yes | Only if also an active member |
| Manage training resources | Yes | Yes | No | No | No |
| View high-level analytics | Yes | Yes | Optional editorial metrics | Own activity | Own posts |

All security decisions belong in PostgreSQL RLS and server-side route/action checks. Navigation visibility is convenience, not authorization.

## 4. Google Workspace OAuth

1. In Google Cloud, create or select the Sustainers NEST organization project.
2. Configure the OAuth consent screen. If the organization controls Google Workspace, set the audience to **Internal**; otherwise use an external app with approved test/production users while Workspace is configured.
3. Add only `openid`, email, and profile scopes unless another Google API is genuinely required.
4. Create a Web OAuth client.
5. Add authorized origins for `https://sustainersnest.org`, the chosen preview domain, and localhost during development.
6. Add Supabase’s callback URL: `https://<project-ref>.supabase.co/auth/v1/callback`. A custom auth domain such as `auth.sustainersnest.org` is preferable for user trust.
7. Enable Google in Supabase Auth and set the client ID/secret.
8. Set Supabase Site URL to the production origin and allow exact local/preview callback URLs.
9. Initiate login with `signInWithOAuth({ provider: 'google', options: { redirectTo: '<origin>/auth/callback', queryParams: { hd: 'sustainersnest.org', prompt: 'select_account' } } })`.
10. In `/auth/callback`, exchange the code for a session and redirect only after a server-side domain check.
11. Keep the database trigger from the supplied schema. The Google `hd` parameter is only a user-interface hint; the trigger enforces both the Google provider and the `@sustainersnest.org` domain.
12. After the first Workspace user signs in, bootstrap the first `super_admin` role once through the Supabase SQL editor. Thereafter, only a super admin can manage platform roles.

For high-risk operations such as role changes, consider requiring MFA assurance level 2 and writing an audit-log record.

## 5. Next.js App Router structure

This structure assumes Next.js 16+, TypeScript, Tailwind CSS, shadcn/ui, Lucide, Supabase SSR, Zod, and a structured rich-text editor such as Tiptap. In Next.js 16 the request boundary file is `proxy.ts`, not `middleware.ts`.

```text
sustainers-nest/
├── public/
│   ├── brand/
│   └── placeholders/                 # only neutral fallbacks, never fake impact photos
├── src/
│   ├── app/
│   │   ├── (public)/
│   │   │   ├── layout.tsx
│   │   │   ├── page.tsx              # homepage
│   │   │   ├── about/page.tsx
│   │   │   ├── team/page.tsx
│   │   │   ├── programs/page.tsx
│   │   │   ├── programs/[slug]/page.tsx
│   │   │   ├── stories/page.tsx
│   │   │   ├── stories/[slug]/page.tsx
│   │   │   ├── journal/page.tsx
│   │   │   ├── journal/[slug]/page.tsx
│   │   │   ├── request-workshop/page.tsx
│   │   │   └── contact/page.tsx
│   │   ├── (auth)/
│   │   │   └── sign-in/page.tsx
│   │   ├── auth/callback/route.ts
│   │   ├── (dashboard)/
│   │   │   └── dashboard/
│   │   │       ├── layout.tsx
│   │   │       ├── page.tsx
│   │   │       ├── requests/
│   │   │       │   ├── page.tsx
│   │   │       │   └── [id]/page.tsx
│   │   │       ├── visits/
│   │   │       │   ├── page.tsx
│   │   │       │   ├── new/page.tsx
│   │   │       │   └── [id]/page.tsx
│   │   │       ├── reports/
│   │   │       │   ├── page.tsx
│   │   │       │   └── [id]/page.tsx
│   │   │       ├── journals/
│   │   │       │   ├── page.tsx
│   │   │       │   ├── new/page.tsx
│   │   │       │   └── [id]/edit/page.tsx
│   │   │       ├── posts/
│   │   │       │   ├── page.tsx
│   │   │       │   ├── new/page.tsx
│   │   │       │   └── [id]/edit/page.tsx
│   │   │       ├── resources/page.tsx
│   │   │       ├── team/page.tsx
│   │   │       ├── analytics/page.tsx
│   │   │       └── settings/roles/page.tsx
│   │   ├── api/
│   │   │   ├── public/contact/route.ts
│   │   │   ├── public/workshop-requests/route.ts
│   │   │   ├── webhooks/route.ts
│   │   │   └── revalidate/route.ts
│   │   ├── error.tsx
│   │   ├── global-error.tsx
│   │   ├── not-found.tsx
│   │   ├── robots.ts
│   │   ├── sitemap.ts
│   │   ├── opengraph-image.tsx
│   │   ├── layout.tsx
│   │   └── globals.css
│   ├── components/
│   │   ├── ui/                        # shadcn primitives only
│   │   ├── editorial/                 # story lead, byline, prose, gallery
│   │   ├── field/                     # visit/report/journal forms
│   │   ├── dashboard/                 # shell, data table, filters, review panel
│   │   └── shared/                    # header, footer, image-with-credit
│   ├── features/
│   │   ├── auth/
│   │   ├── content/
│   │   ├── journals/
│   │   ├── reports/
│   │   ├── resources/
│   │   ├── team/
│   │   └── workshops/
│   ├── lib/
│   │   ├── supabase/
│   │   │   ├── browser.ts
│   │   │   ├── server.ts
│   │   │   ├── admin.ts               # server-only; never imported by client code
│   │   │   └── database.types.ts
│   │   ├── auth/
│   │   │   ├── permissions.ts
│   │   │   └── require-role.ts
│   │   ├── validation/
│   │   ├── rate-limit/
│   │   ├── content/
│   │   └── utils.ts
│   ├── server/
│   │   ├── actions/
│   │   ├── queries/
│   │   └── services/
│   └── styles/
│       ├── tokens.css
│       └── prose.css
├── supabase/
│   ├── migrations/
│   │   └── <timestamp>_initial_platform.sql
│   ├── seed.sql
│   ├── tests/
│   │   └── rls.test.sql
│   └── config.toml
├── tests/
│   ├── e2e/
│   ├── integration/
│   └── unit/
├── proxy.ts
├── next.config.ts
├── components.json
├── eslint.config.mjs
├── instrumentation.ts
├── package.json
├── pnpm-lock.yaml
└── .env.example
```

### Application boundaries

- Server Components read directly from Supabase; do not make internal HTTP calls back into the same app.
- Server Actions handle authenticated dashboard mutations and call domain services after Zod validation.
- Route Handlers are reserved for public forms, OAuth callbacks, webhooks, signed-download endpoints, and external integrations.
- `proxy.ts` refreshes Supabase auth cookies and performs coarse unauthenticated redirects. Each protected page/action must still authorize from trusted server state and RLS.
- Use Node.js runtime by default.
- Public pages query only published rows. Draft preview requires an authenticated editor and a preview route/state.
- Store editor documents as validated JSON plus a plain-text projection for search and reading-time calculation. Sanitize any rendered HTML.
- Generate Supabase types in CI and fail the build when the committed types drift from the linked schema.

## 6. Data and storage behavior

The supplied SQL file creates normalized content, school, visit, report, journal, resource, media, team, role, and request tables; three buckets; complete RLS policies; explicit API grants; and automatic impact aggregation.

Buckets:

- `public-media`: approved website photography and headshots. Public read; editorial/leadership write.
- `member-uploads`: private report photos and working files. Uploads live under `<user-id>/...`; owners and reviewers can read.
- `training-resources`: private scripts, slides, PDFs, and worksheets. Active members can read; executives manage.

Impact totals come only from approved reports attached to completed visits:

- Students reached = sum of approved report student counts.
- Schools covered = distinct schools with a completed visit and approved report.
- Active volunteers = active users holding the volunteer role.

The `override_value` field supports a documented executive correction without destroying the calculated source value. The UI should render `coalesce(override_value, calculated_value)` and show when a number has been overridden.

Public contact and workshop-request forms intentionally do not receive direct anonymous table access. Submit them to validated, rate-limited Route Handlers protected by bot detection; the server then writes with a narrowly held secret. Never expose that secret to the browser.

## 7. Clean fork and migration sequence

### Phase A — preserve and branch

1. Fork `KawserMahamudJunyed/sustainers-nest` to the organization’s GitHub account.
2. Clone the fork and add the original repository as `upstream`.
3. Protect `main`: require pull requests, checks, and at least one reviewer; disable force pushes.
4. Create a branch such as `redesign/app-router-foundation`.
5. Tag the existing site, for example `legacy-static-2026-05-05`, so rollback is trivial.
6. Move the current static implementation into `legacy-static/` in one commit. Do not mix this mechanical move with the redesign.

Suggested commands:

```bash
git clone https://github.com/<organization>/sustainers-nest.git
cd sustainers-nest
git remote add upstream https://github.com/KawserMahamudJunyed/sustainers-nest.git
git fetch --all --prune
git tag legacy-static-2026-05-05
git switch -c redesign/app-router-foundation
mkdir legacy-static
git mv *.html *.js styles.css logo.jpg api vercel.json legacy-static/
git commit -m "chore: preserve legacy static site"
```

### Phase B — scaffold the application

1. Scaffold a temporary Next.js App Router project with TypeScript, Tailwind, ESLint, `src/`, and pnpm.
2. Copy the generated files into the repository root, excluding its `.git` directory.
3. Install pinned versions of `@supabase/supabase-js`, `@supabase/ssr`, Zod, Lucide, shadcn dependencies, the chosen editor, and test tooling. Commit the lockfile.
4. Add `.env.example` with public URL/publishable key names only. Put real values in local/Vercel environment settings.
5. Configure image domains, security headers, CSP, strict TypeScript, formatting, linting, unit tests, and Playwright.
6. Build the route groups and shared layouts before porting individual pages.

### Phase C — create and test Supabase

1. Create separate development, staging, and production Supabase projects (or branches if your plan supports them).
2. Install the Supabase CLI, run `supabase init`, and discover current CLI syntax with `supabase --help`.
3. Create a migration with `supabase migration new initial_platform`; place the supplied schema in that generated file rather than inventing a timestamp.
4. Apply it locally, generate TypeScript types, and run database tests.
5. Test every role with positive and negative RLS cases, including cross-user access, draft/public content, inactive accounts, and private storage.
6. Run Supabase database/security advisors before linking or deploying.
7. Configure Google OAuth and exact redirect URLs only after local auth tests pass.
8. Bootstrap the first super admin after their first successful Workspace sign-in.

### Phase D — migrate content without carrying over demo claims

1. Seed the verified mission, vision, organization description, pillars, and six program names/descriptions.
2. Keep programs in draft until an executive confirms the descriptions.
3. Do not migrate placeholder team records, partner names, phone number, social links, or unverified counters.
4. Ask the organization for a content sheet containing real team names, designations, bios, headshots, and verified social URLs.
5. Ask for original school-visit media plus consent/publication status, school/date captions, and photographer credits.
6. Import historic visits and reports first; let approved records generate the impact totals.
7. Redirect old `/events` and `/get-involved` URLs to the closest new destinations if those routes are retired.

### Phase E — incremental delivery

Use small pull requests in this order:

1. App shell, tokens, fonts, header/footer, accessibility baseline.
2. Supabase clients, OAuth callback, `proxy.ts`, protected layout, role helpers.
3. Schema migration, RLS tests, storage policies, generated types.
4. Public homepage/about/team/program pages using verified content.
5. Workshop and contact form handlers with validation, rate limiting, and bot protection.
6. Visit scheduling, trainer assignment, report submission, and photo upload.
7. Journal and blog editorial workflow.
8. Training resource hub with signed/private downloads.
9. Team management, role management, analytics, and audit views.
10. Data import, redirects, SEO, performance/accessibility review, staging acceptance, and production cutover.

Each PR should include its migration when relevant, role-by-role authorization tests, screenshots for UI changes, and rollback notes. Never edit production tables manually to “fix” a migration; create a corrective migration.

## 8. Launch acceptance criteria

- Every dashboard route rejects unauthenticated users and non-Workspace accounts.
- RLS tests prove each role can access only its intended rows and storage objects.
- No service-role or secret key appears in browser bundles, logs, or committed files.
- Public impact figures reconcile to approved reports.
- Every public person/photo has consent and accessibility text.
- Team names and social URLs are real and verified.
- No placeholder statistics, partners, phone numbers, or social links remain.
- Core Web Vitals are measured using real media sizes; hero images use `next/image`, responsive `sizes`, and an intentional LCP strategy.
- Keyboard navigation, focus states, reduced motion, color contrast, form errors, and screen-reader labels pass review.
- Metadata, canonical URLs, sitemap, robots rules, Open Graph images, redirects, privacy policy, and data-retention policy are in place.
- Backups, error monitoring, audit logging, and a rollback runbook are tested before DNS cutover.

## References

- Existing repository: https://github.com/KawserMahamudJunyed/sustainers-nest
- Live site: https://sustainersnest.org/
- Next.js project organization: https://nextjs.org/docs/app/getting-started/project-structure
- Supabase Google sign-in: https://supabase.com/docs/guides/auth/social-login/auth-google
- Supabase RLS: https://supabase.com/docs/guides/database/postgres/row-level-security
- Supabase RBAC/custom claims: https://supabase.com/docs/guides/api/custom-claims-and-role-based-access-control-rbac
- Supabase Storage access control: https://supabase.com/docs/guides/storage/security/access-control
