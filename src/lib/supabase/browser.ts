import { createBrowserClient } from "@supabase/ssr";
import { supabasePublishableKey, supabaseUrl } from "./config";

export function createBrowserSupabaseClient() {
  if (!supabaseUrl || !supabasePublishableKey) return null;
  return createBrowserClient(supabaseUrl, supabasePublishableKey);
}
