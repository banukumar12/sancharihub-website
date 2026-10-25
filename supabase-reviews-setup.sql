-- Run in your Supabase project's SQL Editor.
-- Safe to repeat: existing reviews keep their current approval status.
begin;
create table if not exists public.traveler_reviews (
 id bigint generated always as identity primary key,
 name text not null check (char_length(trim(name)) between 1 and 60),
 trip text not null check (trip in ('Gokarna','Dandeli','Kerala Theyyam','Other trip')),
 rating integer not null check (rating between 1 and 5),
 experience text not null check (char_length(trim(experience)) between 10 and 1000),
 approved boolean not null default true,
 created_at timestamptz not null default now()
);
-- CREATE TABLE IF NOT EXISTS does not update an existing column's default.
alter table public.traveler_reviews alter column approved set default true;
alter table public.traveler_reviews enable row level security;
revoke all on public.traveler_reviews from anon, authenticated;
grant usage on schema public to anon;
-- The client cannot select/filter or set approved; only the database owner can hide reviews.
grant select (name, trip, rating, experience, created_at), insert (name, trip, rating, experience) on public.traveler_reviews to anon;
grant usage on sequence public.traveler_reviews_id_seq to anon;
drop policy if exists "Public read approved reviews" on public.traveler_reviews;
create policy "Public read approved reviews" on public.traveler_reviews for select to anon using (approved = true);
drop policy if exists "Public submit pending reviews" on public.traveler_reviews;
drop policy if exists "Public submit published reviews" on public.traveler_reviews;
create policy "Public submit published reviews" on public.traveler_reviews for insert to anon with check (approved = true);
commit;
-- New reviews are published automatically. Existing unpublished reviews remain hidden.
-- The owner can hide a review in Supabase Table Editor by setting approved=false.
