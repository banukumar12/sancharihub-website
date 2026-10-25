-- Existing projects: run this file once in your Supabase project's SQL Editor.
-- Safe to repeat. It affects future submissions, without publishing older hidden reviews.
begin;

alter table public.traveler_reviews alter column approved set default true;

drop policy if exists "Public submit pending reviews" on public.traveler_reviews;
drop policy if exists "Public submit published reviews" on public.traveler_reviews;
create policy "Public submit published reviews"
on public.traveler_reviews
for insert to anon
with check (approved = true);

commit;

-- The existing SELECT policy still exposes only approved reviews.
-- Existing narrow column grants and owner-only approval controls are unchanged.
-- No UPDATE is issued: previously unpublished reviews remain unpublished.
