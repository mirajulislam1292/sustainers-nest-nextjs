-- Sustainers NEST — production-oriented Supabase schema
-- PostgreSQL 15+ / Supabase. Run as a migration owner, not from the browser client.

begin;

create extension if not exists pgcrypto;
create extension if not exists citext;

create schema if not exists private;
revoke all on schema private from public;
alter default privileges in schema private revoke execute on functions from public;

create type public.app_role as enum (
  'super_admin',
  'executive_member',
  'site_editor',
  'volunteer',
  'blogger'
);
create type public.team_group as enum ('executive', 'core');
create type public.content_status as enum ('draft', 'submitted', 'published', 'rejected', 'archived');
create type public.post_kind as enum ('story', 'blog');
create type public.workshop_request_status as enum ('pending', 'scheduled', 'completed', 'declined', 'cancelled');
create type public.visit_status as enum ('proposed', 'approved', 'scheduled', 'completed', 'cancelled');
create type public.report_status as enum ('draft', 'submitted', 'approved', 'changes_requested');
create type public.resource_kind as enum ('script', 'slides', 'worksheet', 'other');
create type public.feature_kind as enum ('story', 'program', 'journal');

create table public.organization_profile (
  id boolean primary key default true check (id),
  name text not null,
  tagline text not null,
  hero_text text not null,
  mission text not null,
  vision text not null,
  email citext not null,
  location text not null,
  phone text,
  social_links jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email citext not null unique,
  full_name text not null default '',
  phone text,
  avatar_path text,
  is_active boolean not null default true,
  last_seen_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.profile_roles (
  user_id uuid not null references public.profiles(id) on delete cascade,
  role public.app_role not null,
  granted_by uuid references public.profiles(id) on delete set null,
  granted_at timestamptz not null default now(),
  primary key (user_id, role)
);

create table public.team_members (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid unique references public.profiles(id) on delete set null,
  group_name public.team_group not null,
  name text not null,
  designation text not null,
  bio text,
  photo_path text,
  social_links jsonb not null default '{}'::jsonb,
  impact_badges text[] not null default '{}',
  display_order integer not null default 0,
  is_public boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint social_links_is_object check (jsonb_typeof(social_links) = 'object')
);

create table public.programs (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  title text not null,
  summary text not null,
  body jsonb not null default '{}'::jsonb,
  cover_path text,
  status public.content_status not null default 'draft',
  display_order integer not null default 0,
  published_at timestamptz,
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  name text not null unique,
  created_at timestamptz not null default now()
);

create table public.posts (
  id uuid primary key default gen_random_uuid(),
  kind public.post_kind not null default 'blog',
  slug text not null unique check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  title text not null,
  dek text,
  body jsonb not null default '{}'::jsonb,
  body_text text not null default '',
  cover_path text,
  status public.content_status not null default 'draft',
  author_id uuid not null references public.profiles(id) on delete restrict,
  editor_id uuid references public.profiles(id) on delete set null,
  reading_minutes integer generated always as (greatest(1, ceil(array_length(regexp_split_to_array(trim(body_text), '\s+'), 1) / 220.0)::integer)) stored,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.post_categories (
  post_id uuid not null references public.posts(id) on delete cascade,
  category_id uuid not null references public.categories(id) on delete cascade,
  primary key (post_id, category_id)
);

create table public.schools (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  district text,
  address text,
  is_public boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.school_contacts (
  school_id uuid primary key references public.schools(id) on delete cascade,
  contact_name text,
  contact_email citext,
  contact_phone text,
  updated_at timestamptz not null default now()
);

create table public.workshop_requests (
  id uuid primary key default gen_random_uuid(),
  school_name text not null,
  district text,
  address text,
  authority_name text not null,
  authority_title text,
  email citext not null,
  phone text not null,
  preferred_dates date[] not null default '{}',
  estimated_students integer check (estimated_students is null or estimated_students > 0),
  age_group text,
  goals text,
  status public.workshop_request_status not null default 'pending',
  school_id uuid references public.schools(id) on delete set null,
  assigned_to uuid references public.profiles(id) on delete set null,
  internal_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.school_visits (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete restrict,
  request_id uuid unique references public.workshop_requests(id) on delete set null,
  program_id uuid references public.programs(id) on delete set null,
  title text not null,
  starts_at timestamptz,
  ends_at timestamptz,
  status public.visit_status not null default 'proposed',
  approved_by uuid references public.profiles(id) on delete set null,
  approved_at timestamptz,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint visit_time_order check (ends_at is null or starts_at is null or ends_at > starts_at)
);

create table public.visit_trainers (
  visit_id uuid not null references public.school_visits(id) on delete cascade,
  trainer_id uuid not null references public.profiles(id) on delete cascade,
  assigned_by uuid references public.profiles(id) on delete set null,
  assigned_at timestamptz not null default now(),
  primary key (visit_id, trainer_id)
);

create table public.visit_reports (
  id uuid primary key default gen_random_uuid(),
  visit_id uuid not null unique references public.school_visits(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete restrict,
  student_count integer not null check (student_count >= 0),
  trainer_notes text not null,
  public_summary text,
  status public.report_status not null default 'draft',
  reviewed_by uuid references public.profiles(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.daily_journals (
  id uuid primary key default gen_random_uuid(),
  visit_id uuid references public.school_visits(id) on delete set null,
  author_id uuid not null references public.profiles(id) on delete restrict,
  slug text unique check (slug is null or slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  title text not null,
  excerpt text,
  body jsonb not null default '{}'::jsonb,
  body_text text not null default '',
  cover_path text,
  status public.content_status not null default 'draft',
  editor_id uuid references public.profiles(id) on delete set null,
  reading_minutes integer generated always as (greatest(1, ceil(array_length(regexp_split_to_array(trim(body_text), '\s+'), 1) / 220.0)::integer)) stored,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.media_assets (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete restrict,
  bucket_id text not null check (bucket_id in ('public-media', 'member-uploads', 'training-resources')),
  object_path text not null,
  alt_text text,
  caption text,
  mime_type text,
  byte_size bigint check (byte_size is null or byte_size >= 0),
  post_id uuid references public.posts(id) on delete cascade,
  journal_id uuid references public.daily_journals(id) on delete cascade,
  report_id uuid references public.visit_reports(id) on delete cascade,
  display_order integer not null default 0,
  is_public boolean not null default false,
  created_at timestamptz not null default now(),
  unique (bucket_id, object_path),
  constraint media_one_parent check (num_nonnulls(post_id, journal_id, report_id) <= 1)
);

create table public.training_resources (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  kind public.resource_kind not null,
  storage_path text not null unique,
  version text,
  program_id uuid references public.programs(id) on delete set null,
  is_active boolean not null default true,
  uploaded_by uuid not null references public.profiles(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.homepage_features (
  id uuid primary key default gen_random_uuid(),
  feature_kind public.feature_kind not null,
  post_id uuid references public.posts(id) on delete cascade,
  program_id uuid references public.programs(id) on delete cascade,
  journal_id uuid references public.daily_journals(id) on delete cascade,
  display_order integer not null default 0,
  starts_at timestamptz,
  ends_at timestamptz,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  constraint feature_exactly_one_target check (num_nonnulls(post_id, program_id, journal_id) = 1),
  constraint feature_kind_matches_target check (
    (feature_kind = 'story' and post_id is not null) or
    (feature_kind = 'program' and program_id is not null) or
    (feature_kind = 'journal' and journal_id is not null)
  ),
  constraint feature_time_order check (ends_at is null or starts_at is null or ends_at > starts_at)
);

create table public.contact_messages (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email citext not null,
  subject text,
  message text not null,
  handled_by uuid references public.profiles(id) on delete set null,
  handled_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.impact_metrics (
  key text primary key check (key in ('students_reached', 'schools_covered', 'active_volunteers')),
  label text not null,
  calculated_value bigint not null default 0 check (calculated_value >= 0),
  override_value bigint check (override_value is null or override_value >= 0),
  effective_value bigint generated always as (coalesce(override_value, calculated_value)) stored,
  display_order integer not null,
  updated_at timestamptz not null default now()
);

create table public.audit_log (
  id bigint generated always as identity primary key,
  actor_id uuid references public.profiles(id) on delete set null,
  action text not null,
  entity_table text not null,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index posts_public_idx on public.posts (kind, published_at desc) where status = 'published';
create index journals_public_idx on public.daily_journals (published_at desc) where status = 'published';
create index visits_school_status_idx on public.school_visits (school_id, status);
create index visit_trainers_trainer_idx on public.visit_trainers (trainer_id, visit_id);
create index workshop_requests_status_idx on public.workshop_requests (status, created_at desc);
create index media_assets_parent_idx on public.media_assets (post_id, journal_id, report_id);
create index team_members_public_idx on public.team_members (group_name, display_order) where is_public;

create or replace function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function private.is_active_member()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid()) and p.is_active
  );
$$;

create or replace function private.has_role(required public.app_role)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profile_roles r
    join public.profiles p on p.id = r.user_id
    where r.user_id = (select auth.uid())
      and r.role = required
      and p.is_active
  );
$$;

create or replace function private.has_any_role(required public.app_role[])
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profile_roles r
    join public.profiles p on p.id = r.user_id
    where r.user_id = (select auth.uid())
      and r.role = any(required)
      and p.is_active
  );
$$;

create or replace function private.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  provider text := coalesce(new.raw_app_meta_data ->> 'provider', '');
begin
  if new.email is null
     or lower(split_part(new.email, '@', 2)) <> 'sustainersnest.org'
     or provider <> 'google' then
    raise exception 'Dashboard access requires Google sign-in with a @sustainersnest.org account';
  end if;

  insert into public.profiles (id, email, full_name, avatar_path)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name', ''),
    new.raw_user_meta_data ->> 'avatar_url'
  );

  insert into public.profile_roles (user_id, role)
  values (new.id, 'volunteer');
  return new;
end;
$$;

create or replace function private.set_profile_active(target_user uuid, active boolean)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null or not private.has_role('super_admin') then
    raise exception 'Only a super admin can change account status';
  end if;
  if target_user = (select auth.uid()) and not active then
    raise exception 'A super admin cannot deactivate their own account';
  end if;
  update public.profiles set is_active = active where id = target_user;
  if not found then raise exception 'Profile not found'; end if;
end;
$$;

create or replace function private.refresh_impact_metrics()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.impact_metrics (key, label, calculated_value, display_order)
  values
    ('students_reached', 'Students reached', 0, 1),
    ('schools_covered', 'Schools covered', 0, 2),
    ('active_volunteers', 'Active volunteers', 0, 3)
  on conflict (key) do nothing;

  update public.impact_metrics
  set calculated_value = coalesce((
        select sum(r.student_count)
        from public.visit_reports r
        join public.school_visits v on v.id = r.visit_id
        where r.status = 'approved' and v.status = 'completed'
      ), 0),
      updated_at = now()
  where key = 'students_reached';

  update public.impact_metrics
  set calculated_value = coalesce((
        select count(distinct v.school_id)
        from public.school_visits v
        join public.visit_reports r on r.visit_id = v.id
        where r.status = 'approved' and v.status = 'completed'
      ), 0),
      updated_at = now()
  where key = 'schools_covered';

  update public.impact_metrics
  set calculated_value = coalesce((
        select count(distinct r.user_id)
        from public.profile_roles r
        join public.profiles p on p.id = r.user_id
        where r.role = 'volunteer' and p.is_active
      ), 0),
      updated_at = now()
  where key = 'active_volunteers';

  return null;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function private.handle_new_auth_user();

create trigger profiles_updated_at before update on public.profiles for each row execute function private.set_updated_at();
create trigger team_members_updated_at before update on public.team_members for each row execute function private.set_updated_at();
create trigger programs_updated_at before update on public.programs for each row execute function private.set_updated_at();
create trigger posts_updated_at before update on public.posts for each row execute function private.set_updated_at();
create trigger schools_updated_at before update on public.schools for each row execute function private.set_updated_at();
create trigger school_contacts_updated_at before update on public.school_contacts for each row execute function private.set_updated_at();
create trigger workshop_requests_updated_at before update on public.workshop_requests for each row execute function private.set_updated_at();
create trigger school_visits_updated_at before update on public.school_visits for each row execute function private.set_updated_at();
create trigger visit_reports_updated_at before update on public.visit_reports for each row execute function private.set_updated_at();
create trigger daily_journals_updated_at before update on public.daily_journals for each row execute function private.set_updated_at();
create trigger training_resources_updated_at before update on public.training_resources for each row execute function private.set_updated_at();

create trigger impact_from_reports after insert or update or delete on public.visit_reports for each statement execute function private.refresh_impact_metrics();
create trigger impact_from_visits after insert or update or delete on public.school_visits for each statement execute function private.refresh_impact_metrics();
create trigger impact_from_profiles after insert or update or delete on public.profiles for each statement execute function private.refresh_impact_metrics();
create trigger impact_from_roles after insert or update or delete on public.profile_roles for each statement execute function private.refresh_impact_metrics();

insert into public.impact_metrics (key, label, calculated_value, display_order) values
  ('students_reached', 'Students reached', 0, 1),
  ('schools_covered', 'Schools covered', 0, 2),
  ('active_volunteers', 'Active volunteers', 0, 3)
on conflict (key) do nothing;

-- RLS is mandatory for every application table in the exposed public schema.
alter table public.profiles enable row level security;
alter table public.profile_roles enable row level security;
alter table public.team_members enable row level security;
alter table public.programs enable row level security;
alter table public.categories enable row level security;
alter table public.posts enable row level security;
alter table public.post_categories enable row level security;
alter table public.schools enable row level security;
alter table public.school_contacts enable row level security;
alter table public.workshop_requests enable row level security;
alter table public.school_visits enable row level security;
alter table public.visit_trainers enable row level security;
alter table public.visit_reports enable row level security;
alter table public.daily_journals enable row level security;
alter table public.media_assets enable row level security;
alter table public.training_resources enable row level security;
alter table public.homepage_features enable row level security;
alter table public.contact_messages enable row level security;
alter table public.impact_metrics enable row level security;
alter table public.audit_log enable row level security;
alter table public.organization_profile enable row level security;

-- Profiles and platform roles
create policy profiles_read_self on public.profiles for select to authenticated
  using ((select auth.uid()) = id);
create policy profiles_read_leadership on public.profiles for select to authenticated
  using (private.has_any_role(array['super_admin','executive_member']::public.app_role[]));
create policy profiles_update_self on public.profiles for update to authenticated
  using ((select auth.uid()) = id) with check ((select auth.uid()) = id);
create policy profiles_manage_super on public.profiles for all to authenticated
  using (private.has_role('super_admin')) with check (private.has_role('super_admin'));

create policy profile_roles_read_self on public.profile_roles for select to authenticated
  using ((select auth.uid()) = user_id);
create policy profile_roles_manage_super on public.profile_roles for all to authenticated
  using (private.has_role('super_admin')) with check (private.has_role('super_admin'));

-- Public directory and programs
create policy team_public_read on public.team_members for select to anon, authenticated using (is_public);
create policy team_manage_leadership on public.team_members for all to authenticated
  using (private.has_any_role(array['super_admin','executive_member']::public.app_role[]))
  with check (private.has_any_role(array['super_admin','executive_member']::public.app_role[]));

create policy programs_public_read on public.programs for select to anon, authenticated using (status = 'published');
create policy programs_editor_read on public.programs for select to authenticated
  using (private.has_any_role(array['super_admin','executive_member','site_editor']::public.app_role[]));
create policy programs_editor_write on public.programs for all to authenticated
  using (private.has_any_role(array['super_admin','executive_member','site_editor']::public.app_role[]))
  with check (private.has_any_role(array['super_admin','executive_member','site_editor']::public.app_role[]));

create policy categories_public_read on public.categories for select to anon, authenticated using (true);
create policy categories_editor_write on public.categories for all to authenticated
  using (private.has_any_role(array['super_admin','site_editor']::public.app_role[]))
  with check (private.has_any_role(array['super_admin','site_editor']::public.app_role[]));

-- Editorial posts: bloggers own drafts; editors control the publication workflow.
create policy posts_public_read on public.posts for select to anon, authenticated using (status = 'published');
create policy posts_author_read on public.posts for select to authenticated
  using (author_id = (select auth.uid()) or private.has_any_role(array['super_admin','site_editor']::public.app_role[]));
create policy posts_author_insert on public.posts for insert to authenticated
  with check (
    author_id = (select auth.uid())
    and status in ('draft','submitted')
    and private.has_any_role(array['super_admin','site_editor','blogger']::public.app_role[])
  );
create policy posts_author_update on public.posts for update to authenticated
  using (author_id = (select auth.uid()) and status in ('draft','submitted'))
  with check (author_id = (select auth.uid()) and status in ('draft','submitted'));
create policy posts_editor_manage on public.posts for all to authenticated
  using (private.has_any_role(array['super_admin','site_editor']::public.app_role[]))
  with check (private.has_any_role(array['super_admin','site_editor']::public.app_role[]));

create policy post_categories_public_read on public.post_categories for select to anon, authenticated
  using (exists (select 1 from public.posts p where p.id = post_id and p.status = 'published'));
create policy post_categories_author_write on public.post_categories for all to authenticated
  using (exists (select 1 from public.posts p where p.id = post_id and (p.author_id = (select auth.uid()) or private.has_any_role(array['super_admin','site_editor']::public.app_role[]))))
  with check (exists (select 1 from public.posts p where p.id = post_id and (p.author_id = (select auth.uid()) or private.has_any_role(array['super_admin','site_editor']::public.app_role[]))));

-- Schools, requests, visits, assignments, and reports
create policy schools_public_read on public.schools for select to anon, authenticated using (is_public);
create policy schools_member_read on public.schools for select to authenticated using (private.is_active_member());
create policy schools_leadership_write on public.schools for all to authenticated
  using (private.has_any_role(array['super_admin','executive_member']::public.app_role[]))
  with check (private.has_any_role(array['super_admin','executive_member']::public.app_role[]));
create policy school_contacts_leadership on public.school_contacts for all to authenticated
  using (private.has_any_role(array['super_admin','executive_member']::public.app_role[]))
  with check (private.has_any_role(array['super_admin','executive_member']::public.app_role[]));

-- Public forms must go through validated/rate-limited Route Handlers using a server secret.
-- There is deliberately no anon policy on workshop_requests or contact_messages.
create policy workshop_requests_leadership on public.workshop_requests for all to authenticated
  using (private.has_any_role(array['super_admin','executive_member']::public.app_role[]))
  with check (private.has_any_role(array['super_admin','executive_member']::public.app_role[]));

create policy visits_assigned_read on public.school_visits for select to authenticated
  using (
    private.has_any_role(array['super_admin','executive_member','site_editor']::public.app_role[])
    or exists (select 1 from public.visit_trainers vt where vt.visit_id = id and vt.trainer_id = (select auth.uid()))
  );
create policy visits_leadership_write on public.school_visits for all to authenticated
  using (private.has_any_role(array['super_admin','executive_member']::public.app_role[]))
  with check (private.has_any_role(array['super_admin','executive_member']::public.app_role[]));

create policy visit_trainers_self_read on public.visit_trainers for select to authenticated
  using (trainer_id = (select auth.uid()) or private.has_any_role(array['super_admin','executive_member']::public.app_role[]));
create policy visit_trainers_leadership_write on public.visit_trainers for all to authenticated
  using (private.has_any_role(array['super_admin','executive_member']::public.app_role[]))
  with check (private.has_any_role(array['super_admin','executive_member']::public.app_role[]));

create policy reports_assigned_read on public.visit_reports for select to authenticated
  using (
    author_id = (select auth.uid())
    or exists (select 1 from public.visit_trainers vt where vt.visit_id = visit_id and vt.trainer_id = (select auth.uid()))
    or private.has_any_role(array['super_admin','executive_member','site_editor']::public.app_role[])
  );
create policy reports_trainer_insert on public.visit_reports for insert to authenticated
  with check (
    author_id = (select auth.uid())
    and status in ('draft','submitted')
    and exists (select 1 from public.visit_trainers vt where vt.visit_id = visit_id and vt.trainer_id = (select auth.uid()))
  );
create policy reports_author_update on public.visit_reports for update to authenticated
  using (author_id = (select auth.uid()) and status in ('draft','changes_requested'))
  with check (author_id = (select auth.uid()) and status in ('draft','submitted'));
create policy reports_leadership_manage on public.visit_reports for all to authenticated
  using (private.has_any_role(array['super_admin','executive_member']::public.app_role[]))
  with check (private.has_any_role(array['super_admin','executive_member']::public.app_role[]));

-- Journals: authors draft; editors choose what becomes public.
create policy journals_public_read on public.daily_journals for select to anon, authenticated using (status = 'published');
create policy journals_author_read on public.daily_journals for select to authenticated
  using (author_id = (select auth.uid()) or private.has_any_role(array['super_admin','site_editor']::public.app_role[]));
create policy journals_author_insert on public.daily_journals for insert to authenticated
  with check (author_id = (select auth.uid()) and status in ('draft','submitted') and private.is_active_member());
create policy journals_author_update on public.daily_journals for update to authenticated
  using (author_id = (select auth.uid()) and status in ('draft','submitted','rejected'))
  with check (author_id = (select auth.uid()) and status in ('draft','submitted'));
create policy journals_editor_manage on public.daily_journals for all to authenticated
  using (private.has_any_role(array['super_admin','site_editor']::public.app_role[]))
  with check (private.has_any_role(array['super_admin','site_editor']::public.app_role[]));

create policy media_public_read on public.media_assets for select to anon, authenticated using (is_public and bucket_id = 'public-media');
create policy media_owner_read on public.media_assets for select to authenticated
  using (owner_id = (select auth.uid()) or private.has_any_role(array['super_admin','executive_member','site_editor']::public.app_role[]));
create policy media_owner_insert on public.media_assets for insert to authenticated
  with check (owner_id = (select auth.uid()) and private.is_active_member());
create policy media_owner_update on public.media_assets for update to authenticated
  using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy media_staff_manage on public.media_assets for all to authenticated
  using (private.has_any_role(array['super_admin','executive_member','site_editor']::public.app_role[]))
  with check (private.has_any_role(array['super_admin','executive_member','site_editor']::public.app_role[]));

create policy resources_member_read on public.training_resources for select to authenticated
  using (is_active and private.is_active_member());
create policy resources_leadership_write on public.training_resources for all to authenticated
  using (private.has_any_role(array['super_admin','executive_member']::public.app_role[]))
  with check (private.has_any_role(array['super_admin','executive_member']::public.app_role[]));

create policy features_public_read on public.homepage_features for select to anon, authenticated
  using ((starts_at is null or starts_at <= now()) and (ends_at is null or ends_at > now()));
create policy features_editor_write on public.homepage_features for all to authenticated
  using (private.has_any_role(array['super_admin','site_editor']::public.app_role[]))
  with check (private.has_any_role(array['super_admin','site_editor']::public.app_role[]));

create policy contact_messages_staff on public.contact_messages for all to authenticated
  using (private.has_any_role(array['super_admin','executive_member']::public.app_role[]))
  with check (private.has_any_role(array['super_admin','executive_member']::public.app_role[]));

create policy impact_metrics_public_read on public.impact_metrics for select to anon, authenticated using (true);
create policy impact_metrics_override on public.impact_metrics for update to authenticated
  using (private.has_any_role(array['super_admin','executive_member']::public.app_role[]))
  with check (private.has_any_role(array['super_admin','executive_member']::public.app_role[]));

create policy audit_super_read on public.audit_log for select to authenticated using (private.has_role('super_admin'));
create policy organization_profile_public_read on public.organization_profile for select to anon, authenticated using (true);
create policy organization_profile_editor_update on public.organization_profile for update to authenticated
  using (private.has_any_role(array['super_admin','site_editor']::public.app_role[]))
  with check (private.has_any_role(array['super_admin','site_editor']::public.app_role[]));

-- Explicit Data API grants (new Supabase projects no longer auto-expose tables).
revoke all on all tables in schema public from anon, authenticated;
grant usage on schema public to anon, authenticated;
grant select on public.team_members, public.programs, public.categories, public.posts,
  public.post_categories, public.schools, public.daily_journals, public.media_assets,
  public.homepage_features, public.impact_metrics, public.organization_profile to anon, authenticated;
grant select on public.profiles to authenticated;
grant update (full_name, phone, avatar_path, last_seen_at) on public.profiles to authenticated;
grant select, insert, update, delete on public.profile_roles, public.team_members,
  public.programs, public.categories, public.posts, public.post_categories, public.schools,
  public.school_contacts, public.workshop_requests, public.school_visits, public.visit_trainers, public.visit_reports,
  public.daily_journals, public.media_assets, public.training_resources,
  public.homepage_features, public.contact_messages to authenticated;
grant update (override_value) on public.impact_metrics to authenticated;
grant update on public.organization_profile to authenticated;
grant select on public.audit_log to authenticated;
grant usage on schema private to authenticated;
grant execute on function private.is_active_member() to authenticated;
grant execute on function private.has_role(public.app_role) to authenticated;
grant execute on function private.has_any_role(public.app_role[]) to authenticated;
grant execute on function private.set_profile_active(uuid, boolean) to authenticated;

-- Storage buckets. public-media is public; the other two require signed-in access.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
  ('public-media', 'public-media', true, 15728640, array['image/jpeg','image/png','image/webp','image/avif']),
  ('member-uploads', 'member-uploads', false, 26214400, array['image/jpeg','image/png','image/webp','application/pdf']),
  ('training-resources', 'training-resources', false, 52428800, array[
    'application/pdf',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ])
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy storage_member_upload_insert on storage.objects for insert to authenticated
  with check (
    bucket_id = 'member-uploads'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and private.is_active_member()
  );
create policy storage_member_upload_read on storage.objects for select to authenticated
  using (
    bucket_id = 'member-uploads'
    and (owner_id = (select auth.uid())::text or private.has_any_role(array['super_admin','executive_member','site_editor']::public.app_role[]))
  );
create policy storage_member_upload_update on storage.objects for update to authenticated
  using (bucket_id = 'member-uploads' and owner_id = (select auth.uid())::text)
  with check (bucket_id = 'member-uploads' and owner_id = (select auth.uid())::text);
create policy storage_member_upload_delete on storage.objects for delete to authenticated
  using (bucket_id = 'member-uploads' and (owner_id = (select auth.uid())::text or private.has_any_role(array['super_admin','executive_member']::public.app_role[])));

create policy storage_public_media_write on storage.objects for insert to authenticated
  with check (bucket_id = 'public-media' and private.has_any_role(array['super_admin','executive_member','site_editor']::public.app_role[]));
create policy storage_public_media_update on storage.objects for update to authenticated
  using (bucket_id = 'public-media' and private.has_any_role(array['super_admin','executive_member','site_editor']::public.app_role[]))
  with check (bucket_id = 'public-media' and private.has_any_role(array['super_admin','executive_member','site_editor']::public.app_role[]));
create policy storage_public_media_delete on storage.objects for delete to authenticated
  using (bucket_id = 'public-media' and private.has_any_role(array['super_admin','executive_member','site_editor']::public.app_role[]));

create policy storage_training_read on storage.objects for select to authenticated
  using (bucket_id = 'training-resources' and private.is_active_member());
create policy storage_training_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'training-resources' and private.has_any_role(array['super_admin','executive_member']::public.app_role[]));
create policy storage_training_update on storage.objects for update to authenticated
  using (bucket_id = 'training-resources' and private.has_any_role(array['super_admin','executive_member']::public.app_role[]))
  with check (bucket_id = 'training-resources' and private.has_any_role(array['super_admin','executive_member']::public.app_role[]));
create policy storage_training_delete on storage.objects for delete to authenticated
  using (bucket_id = 'training-resources' and private.has_any_role(array['super_admin','executive_member']::public.app_role[]));

-- Verified reusable content from the existing repository. Claims/stats that appear
-- unverified are intentionally not seeded as facts.
insert into public.organization_profile
  (id, name, tagline, hero_text, mission, vision, email, location, social_links)
values (
  true,
  'Sustainers NEST',
  'Integrating Nature, Science & Technology for a Sustainable Future',
  'We nurture young innovators to harmonize ecological wisdom with cutting-edge technology, creating solutions that regenerate our planet.',
  'To empower young people with the knowledge, tools, and opportunities to develop practical sustainability solutions through nature, science, and technology.',
  'A future where every young person can turn ecological curiosity into informed action for thriving communities and a healthier planet.',
  'info@sustainersnest.org',
  'Dhaka, Bangladesh',
  '{}'::jsonb
)
on conflict (id) do update set
  name = excluded.name,
  tagline = excluded.tagline,
  hero_text = excluded.hero_text,
  mission = excluded.mission,
  vision = excluded.vision,
  email = excluded.email,
  location = excluded.location;

insert into public.categories (slug, name) values
  ('environment', 'Environment'),
  ('education', 'Education'),
  ('field-notes', 'Field Notes'),
  ('technology', 'Technology')
on conflict do nothing;

insert into public.programs (slug, title, summary, status, display_order) values
  ('green-campus-initiative', 'Green Campus Initiative', 'Transforming school environments into living laboratories with rooftop gardens, composting systems, biodiversity zones, and environmental monitoring stations run by students.', 'draft', 1),
  ('youth-research-lab', 'Youth Research Lab', 'A mentorship-driven program where young scientists tackle environmental challenges through experimentation and discovery.', 'draft', 2),
  ('ecotech-hackathons', 'EcoTech Hackathons', 'Innovation sprints where teams design and prototype technology solutions for sustainability problems.', 'draft', 3),
  ('earth-champions-program', 'Earth Champions Program', 'Environmental stewardship education that equips young people with knowledge and leadership capacity.', 'draft', 4),
  ('sustainability-summits', 'Sustainability Summits', 'Gatherings bringing young leaders, experts, and policymakers together to co-create actionable sustainability plans.', 'draft', 5),
  ('kids-for-nature', 'Kids for Nature', 'Interactive sessions, group activities, and learning materials that foster children’s connection with the natural world.', 'draft', 6)
on conflict (slug) do nothing;

commit;

-- One-time bootstrap after the first Workspace user signs in:
-- insert into public.profile_roles (user_id, role)
-- select id, 'super_admin' from public.profiles where email = 'founder@sustainersnest.org'
-- on conflict do nothing;
