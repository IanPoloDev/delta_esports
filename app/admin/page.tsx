import {requireStaff} from '@/lib/supabase/server';
import {AdminDashboard} from '@/components/delta/admin-dashboard';
export const dynamic='force-dynamic';
export default async function AdminPage(){
 const {db,user}=await requireStaff();
 const tables=['events','tournaments','participants','registrations','announcements','audit_logs','event_memberships','tournament_memberships','matches','match_dependencies','standings'] as const;
 const result=await Promise.all(tables.map(t=>db.from(t).select('*').limit(1000)));
 if(result.some(r=>r.error))return <div className="error-page"><h1>No se pudo cargar la administración</h1><p>Comprueba que las migraciones y los permisos estén configurados en Supabase.</p><a className="primary" href="/admin">Reintentar</a></div>;
 const {data:admin}=await db.rpc('is_admin');
 return <AdminDashboard initial={Object.fromEntries(tables.map((t,i)=>[t,result[i].data||[]]))} userId={user.id} superAdmin={!!admin}/>;
}
