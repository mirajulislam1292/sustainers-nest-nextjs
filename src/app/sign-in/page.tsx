import type { Metadata } from "next";
import { SignInButton } from "@/components/sign-in-button";

export const metadata: Metadata = { title: "Member sign in" };

export default async function SignInPage({ searchParams }: { searchParams: Promise<{ error?: string }> }) {
  const { error } = await searchParams;
  return (
    <section className="auth-page">
      <div className="site-container auth-grid">
        <div><p className="section-number">Members</p><h1>Fieldwork continues here.</h1></div>
        <div className="auth-panel">
          <p>Use your organization account to access journals, visit reports, training resources and editorial tools.</p>
          <SignInButton />
          {error ? <p className="auth-message">Sign-in was not completed. Only approved @sustainersnest.org Google accounts can enter.</p> : null}
          <span>Access is enforced again in the database through row-level security.</span>
        </div>
      </div>
    </section>
  );
}
