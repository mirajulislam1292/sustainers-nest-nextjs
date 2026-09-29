import "server-only";
import { createClient } from "@supabase/supabase-js";
import { supabaseUrl } from "./config";

export function createAdminSupabaseClient() {
  const key = process.env.SUPABASE_SECRET_KEY;
  if (!supabaseUrl || !key) return null;
  return createClient(supabaseUrl, key, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
}
