import { impactStats } from "@/data/site";
import { createServerSupabaseClient } from "@/lib/supabase/server";

export async function getImpactStats() {
  const supabase = await createServerSupabaseClient();
  if (!supabase) return impactStats;
  const { data, error } = await supabase.from("impact_metrics").select("key,label,effective_value").order("display_order");
  if (error || !data?.length) return impactStats;
  return data.map((item) => ({ label: item.label, value: new Intl.NumberFormat("en").format(item.effective_value) }));
}
