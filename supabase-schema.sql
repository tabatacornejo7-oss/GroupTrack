-- GroupTrack initial schema for Supabase (PostgreSQL).
-- Run once in Supabase Dashboard > SQL Editor > New query.

create table if not exists public.gt_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null,
  created_at timestamptz not null default now()
);

create unique index if not exists gt_profiles_username_unique
  on public.gt_profiles (lower(username));

create table if not exists public.gt_projects (
  id text primary key,
  code text not null unique,
  owner_id uuid not null references auth.users(id) on delete cascade,
  members uuid[] not null default '{}',
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  constraint gt_projects_code_format check (code ~ '^[A-Z0-9]{6}$')
);

create index if not exists gt_projects_members_gin on public.gt_projects using gin (members);

create or replace function public.gt_create_profile()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.gt_profiles (id, username)
  values (new.id, trim(new.raw_user_meta_data ->> 'username'));
  return new;
end;
$$;

drop trigger if exists gt_auth_user_profile on auth.users;
create trigger gt_auth_user_profile
  after insert on auth.users
  for each row execute procedure public.gt_create_profile();

alter table public.gt_profiles enable row level security;
alter table public.gt_projects enable row level security;

drop policy if exists "Authenticated users can view usernames" on public.gt_profiles;
create policy "Authenticated users can view usernames"
  on public.gt_profiles for select to authenticated using (true);

drop policy if exists "Members can view their projects" on public.gt_projects;
create policy "Members can view their projects"
  on public.gt_projects for select to authenticated
  using (auth.uid() = any (members));

drop policy if exists "Users can create their own projects" on public.gt_projects;
create policy "Users can create their own projects"
  on public.gt_projects for insert to authenticated
  with check (owner_id = auth.uid() and auth.uid() = any (members));

drop policy if exists "Members can update their projects" on public.gt_projects;
create policy "Members can update their projects"
  on public.gt_projects for update to authenticated
  using (auth.uid() = any (members))
  with check (auth.uid() = any (members));

drop policy if exists "Owners can delete their projects" on public.gt_projects;
create policy "Owners can delete their projects"
  on public.gt_projects for delete to authenticated
  using (owner_id = auth.uid());

create or replace function public.gt_join_project(invite_code text)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  found_id text;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;
  update public.gt_projects
    set members = array_append(members, auth.uid())
    where code = upper(trim(invite_code))
      and not (auth.uid() = any (members))
    returning id into found_id;
  if found_id is null then
    select id into found_id from public.gt_projects where code = upper(trim(invite_code));
  end if;
  if found_id is null then
    raise exception 'Invalid project invitation code';
  end if;
  return found_id;
end;
$$;

revoke all on function public.gt_join_project(text) from public;
grant execute on function public.gt_join_project(text) to authenticated;
grant select on public.gt_profiles to authenticated;
grant select, insert, update, delete on public.gt_projects to authenticated;

-- Private file bucket. Object policies allow only authenticated project members.
insert into storage.buckets (id, name, public)
values ('grouptrack-documents', 'grouptrack-documents', false)
on conflict (id) do nothing;

drop policy if exists "Project members can read documents" on storage.objects;
create policy "Project members can read documents"
  on storage.objects for select to authenticated
  using (bucket_id = 'grouptrack-documents' and (storage.foldername(name))[1] in (
    select id from public.gt_projects where auth.uid() = any (members)
  ));

drop policy if exists "Project members can upload documents" on storage.objects;
create policy "Project members can upload documents"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'grouptrack-documents' and (storage.foldername(name))[1] in (
    select id from public.gt_projects where auth.uid() = any (members)
  ));

drop policy if exists "Project members can delete documents" on storage.objects;
create policy "Project members can delete documents"
  on storage.objects for delete to authenticated
  using (bucket_id = 'grouptrack-documents' and (storage.foldername(name))[1] in (
    select id from public.gt_projects where auth.uid() = any (members)
  ));

