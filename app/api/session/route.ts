import {serverDB} from '@/lib/supabase/server';
export const dynamic='force-dynamic';
export async function GET(){const db=await serverDB();if(!db)return Response.json({staff:false},{headers:{'Cache-Control':'private, no-store'}});const {data:{user}}=await db.auth.getUser();const {data:staff}=user?await db.rpc('is_staff'):{data:false};return Response.json({staff:!!staff},{headers:{'Cache-Control':'private, no-store'}});}
