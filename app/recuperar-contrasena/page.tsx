import {AuthForm} from '@/components/delta/auth-form';
import {supabaseConfig} from '@/lib/supabase/config';
export const dynamic='force-dynamic';
export default function Recover(){return <AuthForm mode="recover" configured={!!supabaseConfig()}/>}
