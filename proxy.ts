import {createServerClient} from '@supabase/ssr';
import {NextRequest,NextResponse} from 'next/server';
import {supabaseConfig} from '@/lib/supabase/config';
export async function proxy(request:NextRequest){
 let response=NextResponse.next({request});
 const c=supabaseConfig();
 if(!c){if(request.nextUrl.pathname.startsWith('/admin'))return NextResponse.redirect(new URL('/login?setup=required',request.url));return response;}
 const db=createServerClient(c.url,c.key,{cookies:{getAll:()=>request.cookies.getAll(),setAll:values=>{values.forEach(({name,value})=>request.cookies.set(name,value));response=NextResponse.next({request});values.forEach(({name,value,options})=>response.cookies.set(name,value,options));}}});
 const {data:{user}}=await db.auth.getUser();
 if(request.nextUrl.pathname.startsWith('/admin')){
  const {data:staff}=user?await db.rpc('is_staff'):{data:false};
  if(!user||!staff){const redirect=NextResponse.redirect(new URL(user?'/login?access=denied':'/login',request.url));response.cookies.getAll().forEach(c=>redirect.cookies.set(c));redirect.headers.set('Cache-Control','private, no-store');return redirect;}
 }
 response.headers.set('Cache-Control','private, no-store');return response;
}
export const config={matcher:['/admin/:path*','/login','/api/session','/actualizar-contrasena']};
