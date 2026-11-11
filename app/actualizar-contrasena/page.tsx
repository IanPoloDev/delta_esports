import {AuthForm} from '@/components/delta/auth-form';
import {serverDB} from '@/lib/supabase/server';
import {redirect} from 'next/navigation';
export const dynamic='force-dynamic';
export default async function Update(){const db=await serverDB();const result=await db?.auth.getUser();if(!result?.data.user)redirect('/login');return <AuthForm mode="update" configured={true}/>}
