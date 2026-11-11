import {AuthForm} from '@/components/delta/auth-form';
import {supabaseConfig} from '@/lib/supabase/config';
export const dynamic='force-dynamic';
export default function Login(){return <AuthForm configured={!!supabaseConfig()}/>}
