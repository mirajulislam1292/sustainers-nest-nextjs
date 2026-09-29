import Link from "next/link";
import { redirect } from "next/navigation";
import { createServerSupabaseClient } from "@/lib/supabase/server";
import { isSupabaseConfigured } from "@/lib/supabase/config";

const links = [
  ["/dashboard", "Overview"], ["/dashboard/requests", "Workshop requests"],
  ["/dashboard/visits", "School visits"], ["/dashboard/journals", "Daily journals"],
  ["/dashboard/posts", "Editorial"], ["/dashboard/resources", "Training resources"],
  ["/dashboard/team", "Team directory"],
];

export default async function DashboardLayout({ children }: { children: React.ReactNode }) {
  if (!isSupabaseConfigured()) return <section className="dashboard-setup"><div><p className="section-number">Backend setup</p><h1>The dashboard is built and waiting for Supabase.</h1><p>Add the four values in <code>.env.example</code>, run the committed migration, and Google Workspace sign-in will activate.</p><Link className="text-link" href="/">Return to the public site</Link></div></section>;
  const supabase = await createServerSupabaseClient();
  const { data: { user } } = await supabase!.auth.getUser();
  if (!user) redirect("/sign-in");
  const { data: roles } = await supabase!.from("profile_roles").select("role").eq("user_id", user.id);
  return (
    <section className="dashboard-shell">
      <aside className="dashboard-sidebar">
        <Link className="brand dashboard-brand" href="/">Sustainers NEST</Link>
        <nav>{links.map(([href, label]) => <Link key={href} href={href}>{label}</Link>)}</nav>
        <div className="dashboard-identity"><p>{user.email}</p><span>{roles?.map((item) => item.role.replaceAll("_", " ")).join(" · ") || "Member"}</span></div>
        <form action="/auth/sign-out" method="post"><button type="submit">Sign out</button></form>
      </aside>
      <div className="dashboard-content">{children}</div>
    </section>
  );
}
