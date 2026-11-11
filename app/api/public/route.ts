import {createClient} from '@supabase/supabase-js';
import {supabaseConfig} from '@/lib/supabase/config';
import {emptySnapshot} from '@/lib/types';
export const dynamic='force-dynamic';
export async function GET(){
 const c=supabaseConfig();
 const headers={'Cache-Control':'no-store'};
 if(!c) return Response.json({...emptySnapshot,fetchedAt:new Date().toISOString()},{headers});
 // Anonymous client intentionally ignores visitor cookies: private staff rows never enter public cache.
 const db=createClient(c.url,c.key,{auth:{persistSession:false,autoRefreshToken:false}});
 const {data,error}=await db.rpc('public_snapshot');
 if(error) return Response.json({error:'No se pudieron obtener los datos oficiales.'},{status:503,headers});
 return Response.json(data,{headers});
}
