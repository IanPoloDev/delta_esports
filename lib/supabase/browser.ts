import { createBrowserClient } from '@supabase/ssr';
import { supabaseConfig } from './config';
export function browserDB() {
 const c=supabaseConfig();
 return c ? createBrowserClient(c.url,c.key) : null;
}
