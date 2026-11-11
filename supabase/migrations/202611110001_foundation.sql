-- Delta Esports · foundation. Apply with Supabase SQL Editor or supabase db push.
begin;
create extension if not exists pgcrypto;
create type public.staff_role as enum ('organizer','referee');
create type public.event_state as enum ('draft','upcoming','registration','live','completed','cancelled');
create type public.competition_format as enum ('single','double','groups','swiss');
create type public.game_code as enum ('smash','mk','fc27');
create table public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 display_name text not null check (length(display_name) between 1 and 80),
 created_at timestamptz not null default now()
);
-- Never populated from user metadata. Bootstrap only from trusted SQL.
create table public.platform_admins (user_id uuid primary key references auth.users(id) on delete cascade);
create table public.events (
 id uuid primary key default gen_random_uuid(), slug text unique not null check(slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
 name text not null check(length(name) between 3 and 120), description text not null default '',
 venue text not null default '', starts_at timestamptz, timezone text not null default 'America/Panama',
 state public.event_state not null default 'draft', is_public boolean not null default false,
 is_demo boolean not null default false, created_at timestamptz not null default now()
);
create table public.event_memberships (
 event_id uuid not null references public.events(id) on delete cascade,
 user_id uuid not null references auth.users(id) on delete cascade,
 role public.staff_role not null, primary key(event_id,user_id)
);
create table public.tournaments (
 id uuid primary key default gen_random_uuid(), event_id uuid not null references public.events(id),
 slug text unique not null check(slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'), name text not null check(length(name) between 3 and 120),
 game public.game_code not null, format public.competition_format not null default 'double',
 best_of int not null default 3 check(best_of in (1,3,5,7)), grand_final_reset boolean not null default true,
 state public.event_state not null default 'draft', is_public boolean not null default false,
 rules text not null default '', created_at timestamptz not null default now()
);
create table public.tournament_memberships (
 tournament_id uuid not null references public.tournaments(id) on delete cascade,
 user_id uuid not null references auth.users(id) on delete cascade,
 role public.staff_role not null, primary key(tournament_id,user_id)
);
create table public.participants (
 id uuid primary key default gen_random_uuid(), event_id uuid not null references public.events(id),
 gamer_tag text not null check(length(gamer_tag) between 2 and 40), team text not null default '',
 created_at timestamptz not null default now(), unique(event_id,gamer_tag), unique(id,event_id)
);
create table public.participant_contacts (
 participant_id uuid primary key references public.participants(id) on delete cascade,
 full_name text not null default '', email text, phone text
);
create table public.registrations (
 id uuid primary key default gen_random_uuid(), tournament_id uuid not null references public.tournaments(id),
 participant_id uuid not null references public.participants(id),
 state text not null default 'pending' check(state in ('pending','approved','confirmed','checked_in','withdrawn','disqualified')),
 seed int check(seed>0), checked_in_at timestamptz, created_at timestamptz not null default now(),
 unique(tournament_id,participant_id), unique(tournament_id,seed)
);
create table public.announcements (
 id uuid primary key default gen_random_uuid(), event_id uuid not null references public.events(id),
 title text not null check(length(title) between 3 and 120), body text not null check(length(body) between 1 and 4000),
 published boolean not null default false, created_at timestamptz not null default now()
);
create table public.matches (
 id uuid primary key default gen_random_uuid(), tournament_id uuid not null references public.tournaments(id),
 round int not null check(round>0), bracket text not null check(bracket in ('upper','lower','final','reset','group','swiss')),
 position int not null check(position>0), player_a uuid references public.participants(id), player_b uuid references public.participants(id),
 score_a int not null default 0 check(score_a>=0), score_b int not null default 0 check(score_b>=0),
 winner_id uuid references public.participants(id),
 state text not null default 'scheduled' check(state in ('scheduled','ready','live','completed','disputed','cancelled')),
 version int not null default 1, scheduled_at timestamptz, station text, updated_at timestamptz not null default now(),
 check(player_a is null or player_b is null or player_a<>player_b),
 check(winner_id is null or winner_id=player_a or winner_id=player_b), unique(tournament_id,bracket,round,position)
);
create table public.audit_logs (
 id bigint generated always as identity primary key, actor_id uuid references auth.users(id),
 event_id uuid references public.events(id), entity text not null, entity_id text not null,
 action text not null, previous jsonb, current jsonb, created_at timestamptz not null default now()
);
create index tournaments_event on public.tournaments(event_id);
create index participants_event on public.participants(event_id);
create index memberships_user on public.event_memberships(user_id);
create index tournament_memberships_user on public.tournament_memberships(user_id);
create index registrations_tournament on public.registrations(tournament_id);
create index matches_tournament on public.matches(tournament_id);
create index announcements_event on public.announcements(event_id,created_at desc);
create index audit_event on public.audit_logs(event_id,created_at desc);

create function public.is_admin() returns boolean language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.platform_admins where user_id=(select auth.uid()));
$$;
create function public.can_manage_event(e uuid) returns boolean language sql stable security definer set search_path='' as $$
 select public.is_admin() or exists(select 1 from public.event_memberships where event_id=e and user_id=(select auth.uid()) and role='organizer');
$$;
create function public.can_read_event(e uuid) returns boolean language sql stable security definer set search_path='' as $$
 select public.is_admin() or exists(select 1 from public.events where id=e and is_public and state<>'draft')
 or exists(select 1 from public.event_memberships where event_id=e and user_id=(select auth.uid()))
 or exists(select 1 from public.tournament_memberships m join public.tournaments t on t.id=m.tournament_id where t.event_id=e and m.user_id=(select auth.uid()));
$$;
create function public.can_manage_tournament(t uuid) returns boolean language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.tournaments where id=t and public.can_manage_event(event_id))
 or exists(select 1 from public.tournament_memberships where tournament_id=t and user_id=(select auth.uid()) and role='organizer');
$$;
create function public.can_read_tournament(t uuid) returns boolean language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.tournaments x join public.events e on e.id=x.event_id where x.id=t and x.is_public and x.state<>'draft' and e.is_public and e.state<>'draft')
 or exists(select 1 from public.tournaments where id=t and public.can_manage_event(event_id))
 or exists(select 1 from public.tournament_memberships where tournament_id=t and user_id=(select auth.uid()));
$$;
create function public.is_staff() returns boolean language sql stable security definer set search_path='' as $$
 select public.is_admin() or exists(select 1 from public.event_memberships where user_id=(select auth.uid())) or exists(select 1 from public.tournament_memberships where user_id=(select auth.uid()));
$$;

alter table public.profiles enable row level security;
alter table public.platform_admins enable row level security;
alter table public.events enable row level security;
alter table public.event_memberships enable row level security;
alter table public.tournaments enable row level security;
alter table public.tournament_memberships enable row level security;
alter table public.participants enable row level security;
alter table public.participant_contacts enable row level security;
alter table public.registrations enable row level security;
alter table public.announcements enable row level security;
alter table public.matches enable row level security;
alter table public.audit_logs enable row level security;
create policy profile_self on public.profiles for select to authenticated using(id=(select auth.uid()) or public.is_admin());
create policy event_read on public.events for select using(public.can_read_event(id));
create policy event_create on public.events for insert to authenticated with check(public.is_admin());
create policy event_edit on public.events for update to authenticated using(public.can_manage_event(id)) with check(public.can_manage_event(id));
create policy members_read on public.event_memberships for select to authenticated using(user_id=(select auth.uid()) or public.can_manage_event(event_id));
create policy tournament_read on public.tournaments for select using(public.can_read_tournament(id));
create policy tournament_create on public.tournaments for insert to authenticated with check(public.can_manage_event(event_id));
create policy tournament_edit on public.tournaments for update to authenticated using(public.can_manage_tournament(id)) with check(public.can_manage_tournament(id));
create policy t_members_read on public.tournament_memberships for select to authenticated using(user_id=(select auth.uid()) or public.can_manage_tournament(tournament_id));
create policy participant_read on public.participants for select using(public.can_manage_event(event_id) or exists(select 1 from public.registrations r where r.participant_id=participants.id and r.state in ('approved','confirmed','checked_in') and public.can_read_tournament(r.tournament_id)));
create policy participant_create on public.participants for insert to authenticated with check(public.can_manage_event(event_id));
create policy participant_edit on public.participants for update to authenticated using(public.can_manage_event(event_id)) with check(public.can_manage_event(event_id));
create policy contacts_staff on public.participant_contacts for all to authenticated using(exists(select 1 from public.participants p where p.id=participant_id and public.can_manage_event(p.event_id))) with check(exists(select 1 from public.participants p where p.id=participant_id and public.can_manage_event(p.event_id)));
create policy registration_read on public.registrations for select using(public.can_manage_tournament(tournament_id) or (state in ('approved','confirmed','checked_in') and public.can_read_tournament(tournament_id)));
create policy registration_write on public.registrations for insert to authenticated with check(public.can_manage_tournament(tournament_id));
create policy registration_edit on public.registrations for update to authenticated using(public.can_manage_tournament(tournament_id)) with check(public.can_manage_tournament(tournament_id));
create policy announcement_read on public.announcements for select using((published and public.can_read_event(event_id)) or public.can_manage_event(event_id));
create policy announcement_create on public.announcements for insert to authenticated with check(public.can_manage_event(event_id));
create policy announcement_edit on public.announcements for update to authenticated using(public.can_manage_event(event_id)) with check(public.can_manage_event(event_id));
create policy match_read on public.matches for select using(public.can_read_tournament(tournament_id));
-- Match writes intentionally denied until the transactional competition engine is implemented.
create policy audit_read on public.audit_logs for select to authenticated using(public.can_manage_event(event_id) or public.is_admin());

-- Membership writes have one trusted entry point; no self-promotion via client metadata.
create function public.assign_staff(p_user uuid,p_role public.staff_role,p_event uuid default null,p_tournament uuid default null)
returns void language plpgsql security definer set search_path='' as $$
begin
 if (p_event is null)=(p_tournament is null) then raise exception 'Indica un evento o un torneo'; end if;
 if p_event is not null then
   if not public.can_manage_event(p_event) then raise exception 'Acceso denegado' using errcode='42501'; end if;
   insert into public.event_memberships values(p_event,p_user,p_role) on conflict(event_id,user_id) do update set role=excluded.role;
 else
   if not exists(select 1 from public.tournaments where id=p_tournament and public.can_manage_event(event_id)) then raise exception 'Acceso denegado' using errcode='42501'; end if;
   insert into public.tournament_memberships values(p_tournament,p_user,p_role) on conflict(tournament_id,user_id) do update set role=excluded.role;
 end if;
end; $$;
-- An event/tournament/participant may never be moved across permission scopes.
create function public.guard_scope() returns trigger language plpgsql set search_path='' as $$
begin
 if tg_table_name in ('tournaments','participants','announcements') and new.event_id<>old.event_id then raise exception 'El evento es inmutable'; end if;
 return new;
end; $$;
create trigger tournament_scope before update on public.tournaments for each row execute function public.guard_scope();
create trigger participant_scope before update on public.participants for each row execute function public.guard_scope();
create trigger announcement_scope before update on public.announcements for each row execute function public.guard_scope();
create function public.validate_registration() returns trigger language plpgsql security definer set search_path='' as $$
begin
 if not exists(select 1 from public.participants p join public.tournaments t on t.event_id=p.event_id where p.id=new.participant_id and t.id=new.tournament_id) then raise exception 'Participante y torneo deben pertenecer al mismo evento'; end if;
 if tg_op='UPDATE' and (new.tournament_id<>old.tournament_id or new.participant_id<>old.participant_id) then raise exception 'La inscripción no puede cambiar de participante ni torneo'; end if;
 return new;
end; $$;
create trigger registration_scope before insert or update on public.registrations for each row execute function public.validate_registration();
create function public.audit_change() returns trigger language plpgsql security definer set search_path='' as $$
declare row_data jsonb; e uuid;
begin
 row_data=to_jsonb(new);
 if tg_table_name='events' then e=new.id;
 elsif row_data ? 'event_id' then e=(row_data->>'event_id')::uuid;
 elsif row_data ? 'tournament_id' then select event_id into e from public.tournaments where id=(row_data->>'tournament_id')::uuid;
 end if;
 insert into public.audit_logs(actor_id,event_id,entity,entity_id,action,previous,current)
 values(auth.uid(),e,tg_table_name,coalesce(row_data->>'id',row_data->>'user_id'),tg_op,case when tg_op='UPDATE' then to_jsonb(old) end,row_data);
 return new;
end; $$;
create trigger event_audit after insert or update on public.events for each row execute function public.audit_change();
create trigger tournament_audit after insert or update on public.tournaments for each row execute function public.audit_change();
create trigger participant_audit after insert or update on public.participants for each row execute function public.audit_change();
create trigger registration_audit after insert or update on public.registrations for each row execute function public.audit_change();
create trigger announcement_audit after insert or update on public.announcements for each row execute function public.audit_change();
create trigger event_staff_audit after insert or update on public.event_memberships for each row execute function public.audit_change();
create trigger tournament_staff_audit after insert or update on public.tournament_memberships for each row execute function public.audit_change();

revoke all on public.profiles,public.platform_admins,public.events,public.event_memberships,public.tournaments,public.tournament_memberships,public.participants,public.participant_contacts,public.registrations,public.announcements,public.matches,public.audit_logs from anon,authenticated;
grant select on public.events,public.tournaments,public.participants,public.registrations,public.matches,public.announcements to anon,authenticated;
grant select on public.profiles,public.event_memberships,public.tournament_memberships,public.audit_logs,public.participant_contacts to authenticated;
grant insert,update on public.events,public.tournaments,public.participants,public.registrations,public.announcements,public.participant_contacts to authenticated;
revoke execute on function public.is_admin(),public.is_staff(),public.can_manage_event(uuid),public.can_read_event(uuid),public.can_manage_tournament(uuid),public.can_read_tournament(uuid),public.assign_staff(uuid,public.staff_role,uuid,uuid),public.guard_scope(),public.validate_registration(),public.audit_change() from public;
grant execute on function public.is_admin(),public.is_staff(),public.can_manage_event(uuid),public.can_read_event(uuid),public.can_manage_tournament(uuid),public.can_read_tournament(uuid) to anon,authenticated;
grant execute on function public.assign_staff(uuid,public.staff_role,uuid,uuid) to authenticated;
-- Only public data tables are in the realtime publication.
alter publication supabase_realtime add table public.events,public.tournaments,public.participants,public.registrations,public.matches,public.announcements;
commit;
