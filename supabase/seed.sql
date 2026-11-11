-- Optional fixture for a NEW DEVELOPMENT project. Never publishes automatically.
begin;
insert into public.events(id,slug,name,description,is_demo,is_public,state,venue)
values('d0000000-0000-4000-8000-000000000001','demo-university-championship','DEMO · University Championship','Datos ficticios para validar la administración. No usar como resultados reales.',true,false,'draft','Campus de demostración');
insert into public.tournaments(event_id,slug,name,game,format,best_of) values
('d0000000-0000-4000-8000-000000000001','demo-smash-ultimate','DEMO · Smash Ultimate','smash','double',3),
('d0000000-0000-4000-8000-000000000001','demo-mortal-kombat','DEMO · Mortal Kombat','mk','double',3),
('d0000000-0000-4000-8000-000000000001','demo-fc27','DEMO · FC27','fc27','single',1);
insert into public.participants(event_id,gamer_tag,team)
select 'd0000000-0000-4000-8000-000000000001'::uuid,name,'Equipo de demostración'
from unnest(array['Nova','Raven','Kairo','Pixel','Ghost','Blaze','Zen','Frost']) as name;
insert into public.registrations(tournament_id,participant_id,state,seed)
select t.id,p.id,'checked_in',row_number() over(order by p.gamer_tag)
from public.tournaments t cross join public.participants p
where t.slug='demo-smash-ultimate' and p.event_id=t.event_id;
commit;
