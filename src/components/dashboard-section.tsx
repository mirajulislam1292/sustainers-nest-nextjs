export function DashboardSection({ title, description }: { title: string; description: string }) {
  return <><header className="dashboard-header"><p className="section-number">Workspace</p><h1>{title}</h1><p>{description}</p></header><div className="dashboard-empty"><p>No records yet.</p><span>When Supabase is connected, authorized records will appear here according to the member’s role.</span></div></>;
}
