import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';
import { supabaseConfig } from './config';
export async function serverDB() {
 const c=supabaseConfig(); if(!c) return null;
 const jar=await cookies();
 return createServerClient(c.url,c.key,{cookies:{getAll:()=>jar.getAll(),setAll:values=>{try{values.forEach(({name,value,options})=>jar.set(name,value,options));}catch{/* Read-only server component; /api/session refreshes cookies. */}}}});
}
export async function requireStaff() {
 const db=await serverDB(); if(!db) redirect('/login?setup=required');
 const {data:{user},error}=await db.auth.getUser(); if(error||!user) redirect('/login');
 const {data:staff}=await db.rpc('is_staff'); if(!staff) redirect('/login?access=denied');
 return {db,user};
}
