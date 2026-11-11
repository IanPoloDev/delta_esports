import {serverDB} from '@/lib/supabase/server';
export async function POST(request:Request){if(request.headers.get('origin')!==new URL(request.url).origin)return new Response('Forbidden',{status:403});const db=await serverDB();await db?.auth.signOut();return Response.json({ok:true},{headers:{'Cache-Control':'no-store'}});}
