import { createServerSupabaseClient } from "@/lib/supabase/server";

export async function getDashboardCounts() {
  const supabase = await createServerSupabaseClient();
  if (!supabase) return { requests: 0, visits: 0, journals: 0, posts: 0 };
  const [requests, visits, journals, posts] = await Promise.all([
    supabase.from("workshop_requests").select("id", { count: "exact", head: true }).eq("status", "pending"),
    supabase.from("school_visits").select("id", { count: "exact", head: true }).in("status", ["proposed", "approved", "scheduled"]),
    supabase.from("daily_journals").select("id", { count: "exact", head: true }).eq("status", "in_review"),
    supabase.from("posts").select("id", { count: "exact", head: true }).eq("status", "in_review"),
  ]);
  return { requests: requests.count || 0, visits: visits.count || 0, journals: journals.count || 0, posts: posts.count || 0 };
}
