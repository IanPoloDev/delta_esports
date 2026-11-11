begin;
alter table public.tournaments add column bracket_size int, add column revision int not null default 0, add column champion_id uuid references public.participants(id), add column runner_up_id uuid references public.participants(id);
alter table public.matches add column slot_a_resolved boolean not null default false, add column slot_b_resolved boolean not null default false, add column propagated boolean not null default false, add column is_bye boolean not null default false, add column result_details jsonb not null default '{}';
create table public.match_dependencies(source_id uuid not null references public.matches(id),target_id uuid not null references public.matches(id),target_slot text not null check(target_slot in ('a','b')),outcome text not null check(outcome in ('winner','loser')),primary key(target_id,target_slot),unique(source_id,outcome));
create table public.standings(tournament_id uuid not null references public.tournaments(id),participant_id uuid not null references public.participants(id),position int,wins int not null default 0,losses int not null default 0,state text not null default 'active',primary key(tournament_id,participant_id));
create table public.match_commands(request_id uuid primary key,actor_id uuid not null,match_id uuid not null references public.matches(id),payload jsonb not null,created_at timestamptz not null default now());
create index dependencies_source on public.match_dependencies(source_id);
alter table public.match_dependencies enable row level security;
alter table public.standings enable row level security;
alter table public.match_commands enable row level security;
create policy dependency_read on public.match_dependencies for select using(exists(select 1 from public.matches where id=source_id and public.can_read_tournament(tournament_id)));
create policy standings_read on public.standings for select using(public.can_read_tournament(tournament_id));
grant select on public.match_dependencies,public.standings to anon,authenticated;
revoke all on public.match_commands from anon,authenticated;
create function public.can_score(t uuid) returns boolean language sql stable security definer set search_path='' as $$
 select public.can_manage_tournament(t) or exists(select 1 from public.tournament_memberships where tournament_id=t and user_id=auth.uid()) or exists(select 1 from public.event_memberships m join public.tournaments x on x.event_id=m.event_id where x.id=t and m.user_id=auth.uid());
$$;
-- Configuration and registration are immutable after generating a bracket.
create function public.guard_competition() returns trigger language plpgsql security definer set search_path='' as $$
declare locked boolean; tid uuid;
begin
 if tg_table_name='tournaments' then
  if old.bracket_size is not null and (new.format<>old.format or new.game<>old.game or new.best_of<>old.best_of or new.grand_final_reset<>old.grand_final_reset) then raise exception 'El reglamento queda bloqueado al generar el bracket'; end if;
 else
  tid=coalesce(new.tournament_id,old.tournament_id);
  perform 1 from public.tournaments where id=tid for update;
  select bracket_size is not null into locked from public.tournaments where id=tid;
  if locked then raise exception 'Inscripciones y seeds bloqueados: el bracket ya está generado'; end if;
 end if;
 return new;
end; $$;
create trigger guard_tournament_rules before update on public.tournaments for each row execute function public.guard_competition();
create trigger guard_registration_competition before insert or update on public.registrations for each row execute function public.guard_competition();
-- Protect derived fields even from direct authenticated REST writes.
revoke update,insert on public.tournaments from authenticated;
grant insert(id,event_id,slug,name,game,format,best_of,grand_final_reset,state,is_public,rules) on public.tournaments to authenticated;
grant update(name,slug,rules,is_public) on public.tournaments to authenticated;
create function public.configure_tournament(p_id uuid,p_best_of int,p_reset boolean,p_format public.competition_format) returns void language plpgsql security definer set search_path='' as $$
begin
 perform 1 from public.tournaments where id=p_id for update;
 if not public.can_manage_tournament(p_id) then raise exception 'Acceso denegado' using errcode='42501'; end if;
 if p_best_of not in (1,3,5) or p_format not in ('single','double') then raise exception 'Configuración no compatible'; end if;
 if exists(select 1 from public.tournaments where id=p_id and ((game='fc27' and p_best_of<>1) or (game<>'fc27' and p_best_of not in (3,5)))) then raise exception 'FC usa goles; Smash/MK requieren mejor de 3 o 5'; end if;
 update public.tournaments set best_of=p_best_of,grand_final_reset=p_reset,format=p_format where id=p_id;
end; $$;
create function public.publish_tournament(p_id uuid) returns void language plpgsql security definer set search_path='' as $$
begin
 if not public.can_manage_tournament(p_id) then raise exception 'Acceso denegado' using errcode='42501'; end if;
 update public.tournaments set is_public=true,state=case when state='draft' then 'upcoming'::public.event_state else state end where id=p_id;
end; $$;
create function public.recompute_standings(t uuid) returns void language plpgsql security definer set search_path='' as $$
declare tour public.tournaments;
begin
 select * into tour from public.tournaments where id=t;
 insert into public.standings(tournament_id,participant_id,wins,losses,state)
 select t,r.participant_id,
 (select count(*) from public.matches m where m.tournament_id=t and m.state='completed' and not m.is_bye and m.winner_id=r.participant_id),
 (select count(*) from public.matches m where m.tournament_id=t and m.state='completed' and not m.is_bye and (m.player_a=r.participant_id or m.player_b=r.participant_id) and m.winner_id<>r.participant_id),'active'
 from public.registrations r where r.tournament_id=t and r.state in ('approved','confirmed','checked_in')
 on conflict(tournament_id,participant_id) do update set wins=excluded.wins,losses=excluded.losses;
 update public.standings set state=case when participant_id=tour.champion_id then 'champion' when participant_id=tour.runner_up_id or losses>=case when tour.format='double' then 2 else 1 end then 'eliminated' else 'active' end,position=null where tournament_id=t;
 if tour.state='completed' then
  with ranked as (
   select s.participant_id,rank() over(order by case when s.participant_id=tour.champion_id then 10002 when s.participant_id=tour.runner_up_id then 10001 else coalesce((select max(m.round) from public.matches m where m.tournament_id=t and m.state='completed' and not m.is_bye and (m.player_a=s.participant_id or m.player_b=s.participant_id) and m.winner_id<>s.participant_id and (tour.format='single' or m.bracket='lower')),0) end desc) as place
   from public.standings s where s.tournament_id=t
  ) update public.standings s set position=ranked.place,state=case when s.participant_id=tour.champion_id then 'champion' else 'eliminated' end from ranked where s.tournament_id=t and s.participant_id=ranked.participant_id;
 end if;
end; $$;
-- Resolves BYEs, forwards only completed outcomes and handles final/reset in the same transaction.
create function public.propagate_competition(t uuid) returns void language plpgsql security definer set search_path='' as $$
declare m public.matches; tour public.tournaments; edge record; target_player uuid; loser uuid; changed boolean; guard int=0;
begin
 loop
  guard=guard+1;if guard>2048 then raise exception 'Error de dependencias del bracket';end if;
  changed=false;
  for m in select * from public.matches where tournament_id=t and state='scheduled' and slot_a_resolved and slot_b_resolved and bracket<>'reset' order by round,position loop
   if m.player_a is null or m.player_b is null then
    update public.matches set state='completed',winner_id=coalesce(player_a,player_b),is_bye=true,version=version+1,updated_at=now() where id=m.id;
   else update public.matches set state='ready',version=version+1,updated_at=now() where id=m.id;
   end if;changed=true;
  end loop;
  for m in select * from public.matches where tournament_id=t and state='completed' and not propagated order by round,position loop
   select * into tour from public.tournaments where id=t;
   loser=case when m.winner_id=m.player_a then m.player_b when m.winner_id=m.player_b then m.player_a else null end;
   for edge in select * from public.match_dependencies where source_id=m.id loop
    target_player=case when edge.outcome='winner' then m.winner_id else loser end;
    if edge.target_slot='a' then update public.matches set player_a=target_player,slot_a_resolved=true,version=version+1,updated_at=now() where id=edge.target_id;
    else update public.matches set player_b=target_player,slot_b_resolved=true,version=version+1,updated_at=now() where id=edge.target_id;end if;
   end loop;
   if m.bracket='final' then
    if tour.grand_final_reset and m.winner_id=m.player_b then
     update public.matches set player_a=m.winner_id,player_b=loser,slot_a_resolved=true,slot_b_resolved=true,state='ready',version=version+1 where tournament_id=t and bracket='reset';
    else
     update public.tournaments set champion_id=m.winner_id,runner_up_id=loser,state='completed' where id=t;
     update public.matches set state='cancelled',version=version+1 where tournament_id=t and bracket='reset';
    end if;
   elsif m.bracket='reset' or (tour.format='single' and m.bracket='upper' and not exists(select 1 from public.match_dependencies where source_id=m.id)) then
    update public.tournaments set champion_id=m.winner_id,runner_up_id=loser,state='completed' where id=t;
   end if;
   update public.matches set propagated=true where id=m.id;changed=true;
  end loop;
  exit when not changed;
 end loop;
 perform public.recompute_standings(t);
end; $$;
create function public.generate_bracket(p_tournament uuid) returns void language plpgsql security definer set search_path='' as $$
declare tour public.tournaments; players uuid[]; order_seeds int[]=array[1,2]; next_seeds int[]; total int; n int=2;k int=1;r int;j int;s int;cnt int;dest int;source uuid;target uuid; i int;
begin
 select * into tour from public.tournaments where id=p_tournament for update;
 if not found or not public.can_manage_tournament(p_tournament) then raise exception 'Acceso denegado' using errcode='42501';end if;
 if tour.bracket_size is not null then raise exception 'El bracket ya fue generado';end if;
 if tour.format not in ('single','double') then raise exception 'Solo eliminación simple o doble';end if;
 if (tour.game='fc27' and tour.best_of<>1) or (tour.game<>'fc27' and tour.best_of not in (3,5)) then raise exception 'Revisa el formato de puntuación';end if;
 select array_agg(participant_id order by seed nulls last,created_at,id),count(*) into players,total from public.registrations where tournament_id=p_tournament and state in ('approved','confirmed','checked_in');
 if total<2 or total>256 then raise exception 'Se requieren entre 2 y 256 participantes aprobados';end if;
 while n<total loop n=n*2;k=k+1;end loop;
 while array_length(order_seeds,1)<n loop
  next_seeds='{}';s=array_length(order_seeds,1)*2+1;
  foreach i in array order_seeds loop next_seeds=array_append(next_seeds,i);next_seeds=array_append(next_seeds,s-i);end loop;order_seeds=next_seeds;
 end loop;
 -- Normalize seeds to the accepted ordering, while retaining uniqueness.
 update public.registrations set seed=null where tournament_id=p_tournament;
 for i in 1..total loop update public.registrations set seed=i where tournament_id=p_tournament and participant_id=players[i];end loop;
 update public.tournaments set bracket_size=n,revision=revision+1,state='upcoming' where id=p_tournament;
 for r in 1..k loop
  cnt=n/(2^r)::int;
  for j in 1..cnt loop
   insert into public.matches(tournament_id,round,bracket,position,player_a,player_b,slot_a_resolved,slot_b_resolved)
   values(p_tournament,r,'upper',j,case when r=1 then players[order_seeds[2*j-1]] end,case when r=1 then players[order_seeds[2*j]] end,r=1,r=1);
  end loop;
 end loop;
 if tour.format='double' then
  if k>1 then
   for r in 1..2*(k-1) loop
    cnt=n/(2^((r+1)/2+1))::int;
    for j in 1..cnt loop insert into public.matches(tournament_id,round,bracket,position) values(p_tournament,r,'lower',j);end loop;
   end loop;
  end if;
  insert into public.matches(tournament_id,round,bracket,position) values(p_tournament,1,'final',1);
  if tour.grand_final_reset then
   insert into public.matches(tournament_id,round,bracket,position) values(p_tournament,1,'reset',1) returning id into target;
   select id into source from public.matches where tournament_id=p_tournament and bracket='final';
   insert into public.match_dependencies values(source,target,'a','winner'),(source,target,'b','loser');
  end if;
 end if;
 for r in 1..k loop
  for j in 1..n/(2^r)::int loop
   select id into source from public.matches where tournament_id=p_tournament and bracket='upper' and round=r and position=j;
   if r<k then
    select id into target from public.matches where tournament_id=p_tournament and bracket='upper' and round=r+1 and position=(j+1)/2;
    insert into public.match_dependencies values(source,target,case when j%2=1 then 'a' else 'b' end,'winner');
   elsif tour.format='double' then
    select id into target from public.matches where tournament_id=p_tournament and bracket='final';insert into public.match_dependencies values(source,target,'a','winner');
   end if;
   if tour.format='double' then
    if k=1 then select id into target from public.matches where tournament_id=p_tournament and bracket='final';insert into public.match_dependencies values(source,target,'b','loser');
    elsif r=1 then select id into target from public.matches where tournament_id=p_tournament and bracket='lower' and round=1 and position=(j+1)/2;insert into public.match_dependencies values(source,target,case when j%2=1 then 'a' else 'b' end,'loser');
    else
     cnt=n/(2^r)::int;dest=case when cnt>1 then ((j-1) # 1)+1 else 1 end;
     select id into target from public.matches where tournament_id=p_tournament and bracket='lower' and round=2*r-2 and position=dest;
     insert into public.match_dependencies values(source,target,'b','loser');
    end if;
   end if;
  end loop;
 end loop;
 if tour.format='double' and k>1 then
  for r in 1..2*(k-1) loop
   for j in 1..n/(2^((r+1)/2+1))::int loop
    select id into source from public.matches where tournament_id=p_tournament and bracket='lower' and round=r and position=j;
    if r=2*(k-1) then select id into target from public.matches where tournament_id=p_tournament and bracket='final';insert into public.match_dependencies values(source,target,'b','winner');
    else
     select id into target from public.matches where tournament_id=p_tournament and bracket='lower' and round=r+1 and position=case when r%2=1 then j else (j+1)/2 end;
     insert into public.match_dependencies values(source,target,case when r%2=1 or j%2=1 then 'a' else 'b' end,'winner');
    end if;
   end loop;
  end loop;
 end if;
 perform public.propagate_competition(p_tournament);
end; $$;
create function public.start_match(p_match uuid,p_version int) returns void language plpgsql security definer set search_path='' as $$
declare t uuid;m public.matches;
begin
 select tournament_id into t from public.matches where id=p_match;perform 1 from public.tournaments where id=t for update;
 select * into m from public.matches where id=p_match for update;
 if not public.can_score(t) then raise exception 'Acceso denegado' using errcode='42501';end if;
 if p_version is null or m.version<>p_version or m.state<>'ready' then raise exception 'La partida cambió; actualiza antes de continuar' using errcode='40001';end if;
 update public.matches set state='live',version=version+1,updated_at=now() where id=p_match;
 update public.tournaments set state='live',revision=revision+1 where id=t;
end; $$;
create function public.report_result(p_match uuid,p_version int,p_score_a int,p_score_b int,p_details jsonb default '{}',p_request uuid default gen_random_uuid()) returns void language plpgsql security definer set search_path='' as $$
declare t uuid;m public.matches;tour public.tournaments;win uuid;need int;pa int;pb int;ea int;eb int;a int;b int;payload jsonb;prior public.match_commands;
begin
 if auth.uid() is null then raise exception 'Acceso denegado' using errcode='42501';end if;
 select tournament_id into t from public.matches where id=p_match;
 perform 1 from public.tournaments where id=t for update;select * into m from public.matches where id=p_match for update;
 if not found or not public.can_score(t) then raise exception 'Acceso denegado' using errcode='42501';end if;
 payload=jsonb_build_object('version',p_version,'a',p_score_a,'b',p_score_b,'details',p_details);
 select * into prior from public.match_commands where request_id=p_request;
 if found then if prior.actor_id=auth.uid() and prior.match_id=p_match and prior.payload=payload then return;else raise exception 'Identificador de envío ya utilizado';end if;end if;
 if p_version is null or m.version<>p_version then raise exception 'La partida fue actualizada por otro árbitro; revisa el resultado' using errcode='40001';end if;
 if m.state not in ('ready','live') or m.player_a is null or m.player_b is null then raise exception 'La partida no está lista o ya finalizó';end if;
 if p_score_a is null or p_score_b is null or p_score_a<0 or p_score_b<0 or greatest(p_score_a,p_score_b)>99 then raise exception 'Puntuación inválida';end if;
 select * into tour from public.tournaments where id=t;
 a=p_score_a;b=p_score_b;
 if tour.game<>'fc27' then
  need=(tour.best_of+1)/2;
  if not ((a=need and b<need) or (b=need and a<need)) then raise exception 'El set no corresponde al mejor de %',tour.best_of;end if;
  if p_details<>'{}'::jsonb then raise exception 'Los sets no admiten prórroga ni penaltis';end if;
 else
  if p_details is null or jsonb_typeof(p_details)<>'object' then raise exception 'Detalle inválido';end if;
  if exists(select 1 from jsonb_object_keys(p_details) as k where k not in ('extra_a','extra_b','penalties_a','penalties_b')) then raise exception 'Campos de resultado no permitidos';end if;
  ea=coalesce((p_details->>'extra_a')::int,0);eb=coalesce((p_details->>'extra_b')::int,0);
  pa=(p_details->>'penalties_a')::int;pb=(p_details->>'penalties_b')::int;
  if ea<0 or eb<0 or greatest(ea,eb)>99 or (a<>b and (ea<>0 or eb<>0)) then raise exception 'Prórroga inválida';end if;
  a=a+ea;b=b+eb;
  if a=b then
   if pa is null or pb is null or pa=pb or least(pa,pb)<0 or greatest(pa,pb)>99 then raise exception 'Un empate eliminatorio requiere penaltis válidos';end if;
   if (greatest(pa,pb)>5 and abs(pa-pb)<>1) or (greatest(pa,pb)<=5 and (abs(pa-pb)>3 or (greatest(pa,pb)=5 and least(pa,pb)<3))) then raise exception 'Marcador de penaltis incompatible con una tanda reglamentaria';end if;
   win=case when pa>pb then m.player_a else m.player_b end;
  elsif pa is not null or pb is not null then raise exception 'No se admiten penaltis sin empate';end if;
 end if;
 if win is null then win=case when a>b then m.player_a else m.player_b end;end if;
 insert into public.match_commands values(p_request,auth.uid(),p_match,payload,now());
 update public.matches set score_a=a,score_b=b,result_details=case when tour.game='fc27' then p_details||jsonb_build_object('regular_a',p_score_a,'regular_b',p_score_b) else '{}'::jsonb end,winner_id=win,state='completed',version=version+1,updated_at=now() where id=p_match;
 update public.tournaments set state='live',revision=revision+1 where id=t;
 perform public.propagate_competition(t);
end; $$;
-- Safe correction: reopen only a terminal result whose downstream matches have not started or been auto-resolved.
create function public.reopen_result(p_match uuid,p_version int,p_reason text) returns void language plpgsql security definer set search_path='' as $$
declare t uuid;m public.matches;d record;target public.matches;
begin
 select tournament_id into t from public.matches where id=p_match;perform 1 from public.tournaments where id=t for update;select * into m from public.matches where id=p_match for update;
 if not public.can_manage_tournament(t) then raise exception 'Solo un organizador puede corregir resultados' using errcode='42501';end if;
 if length(trim(p_reason))<10 or length(p_reason)>1000 then raise exception 'Explica el motivo de la corrección (10–1000 caracteres)';end if;
 if p_version is null or m.version<>p_version or m.state<>'completed' or m.is_bye then raise exception 'Resultado no corregible o versión desactualizada';end if;
 if m.bracket in ('final','reset') then raise exception 'Final cerrada: requiere revisión administrativa; no se reabre automáticamente';end if;
 for d in select * from public.match_dependencies where source_id=m.id loop
  select * into target from public.matches where id=d.target_id;
  if target.state not in ('scheduled','ready') then raise exception 'Hay partidas dependientes iniciadas o resueltas. Corrección bloqueada';end if;
 end loop;
 for d in select * from public.match_dependencies where source_id=m.id loop
  if d.target_slot='a' then update public.matches set player_a=null,slot_a_resolved=false,state='scheduled',version=version+1 where id=d.target_id;
  else update public.matches set player_b=null,slot_b_resolved=false,state='scheduled',version=version+1 where id=d.target_id;end if;
 end loop;
 update public.matches set state='ready',score_a=0,score_b=0,winner_id=null,propagated=false,result_details=jsonb_build_object('correction_reason',p_reason),version=version+1 where id=p_match;
 update public.tournaments set state='live',champion_id=null,runner_up_id=null,revision=revision+1 where id=t;
 perform public.recompute_standings(t);
end; $$;
create trigger match_audit after insert or update on public.matches for each row execute function public.audit_change();
-- RLS-invoker snapshot: one PostgreSQL statement sees one consistent committed state.
create function public.public_snapshot() returns jsonb language sql stable security invoker set search_path='' as $$
 select jsonb_build_object('events',coalesce((select jsonb_agg(x) from public.events x),'[]'),'tournaments',coalesce((select jsonb_agg(x) from public.tournaments x),'[]'),'participants',coalesce((select jsonb_agg(x) from public.participants x),'[]'),'registrations',coalesce((select jsonb_agg(x) from public.registrations x),'[]'),'matches',coalesce((select jsonb_agg(x) from public.matches x),'[]'),'dependencies',coalesce((select jsonb_agg(x) from public.match_dependencies x),'[]'),'standings',coalesce((select jsonb_agg(x) from public.standings x),'[]'),'announcements',coalesce((select jsonb_agg(x) from public.announcements x),'[]'),'mode','official','fetchedAt',now());
$$;
revoke execute on function public.can_score(uuid),public.guard_competition(),public.configure_tournament(uuid,int,boolean,public.competition_format),public.publish_tournament(uuid),public.recompute_standings(uuid),public.propagate_competition(uuid),public.generate_bracket(uuid),public.start_match(uuid,int),public.report_result(uuid,int,int,int,jsonb,uuid),public.reopen_result(uuid,int,text),public.public_snapshot() from public;
grant execute on function public.can_score(uuid),public.configure_tournament(uuid,int,boolean,public.competition_format),public.publish_tournament(uuid),public.generate_bracket(uuid),public.start_match(uuid,int),public.report_result(uuid,int,int,int,jsonb,uuid),public.reopen_result(uuid,int,text) to authenticated;
grant execute on function public.public_snapshot() to anon,authenticated;
alter publication supabase_realtime add table public.match_dependencies,public.standings;
commit;

-- Event referees may read their private event tournaments, without managing them.
create or replace function public.can_read_tournament(t uuid) returns boolean language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.tournaments x join public.events e on e.id=x.event_id where x.id=t and x.is_public and x.state<>'draft' and e.is_public and e.state<>'draft')
 or exists(select 1 from public.tournaments where id=t and public.can_manage_event(event_id))
 or exists(select 1 from public.tournament_memberships where tournament_id=t and user_id=(select auth.uid()))
 or exists(select 1 from public.tournaments x join public.event_memberships m on m.event_id=x.event_id where x.id=t and m.user_id=(select auth.uid()));
$$;
