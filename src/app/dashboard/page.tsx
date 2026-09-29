import { getDashboardCounts } from "@/lib/dashboard";

export default async function DashboardPage() {
  const counts = await getDashboardCounts();
  const items = [["Pending workshop requests", counts.requests], ["Upcoming visits", counts.visits], ["Journals awaiting review", counts.journals], ["Posts awaiting review", counts.posts]];
  return <><header className="dashboard-header"><p className="section-number">Operations</p><h1>What needs attention</h1><p>A live view of requests, fieldwork and publishing queues.</p></header><dl className="dashboard-metrics">{items.map(([label, value]) => <div key={label}><dt>{label}</dt><dd>{value}</dd></div>)}</dl><section className="dashboard-note"><h2>Built around the work</h2><p>Roles and row-level security decide who can approve visits, publish stories, manage people, and retrieve private trainer files.</p></section></>;
}
