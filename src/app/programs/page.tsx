import type { Metadata } from "next";
import Link from "next/link";
import { PageIntro } from "@/components/page-intro";
import { Button } from "@/components/ui/button";
import { programs } from "@/data/site";

export const metadata: Metadata = { title: "Programs" };

export default function ProgramsPage() {
  return (
    <>
      <PageIntro
        index="02"
        title="Learning that leaves the classroom changed."
        description="Six connected programs give young people room to observe, research, build and lead."
      />
      <section className="content-section compact-top">
        <div className="site-container full-program-list">
          {programs.map((program, index) => (
            <article key={program.slug} id={program.slug}>
              <p>{String(index + 1).padStart(2, "0")}</p>
              <div>
                <h2>{program.title}</h2>
                <p>{program.summary}</p>
              </div>
              <span>Nature · Science · Action</span>
            </article>
          ))}
        </div>
      </section>
      <section className="closing-cta small-cta">
        <div className="site-container closing-grid">
          <h2>Start with your school, students and local priorities.</h2>
          <div>
            <p>We will help shape a session around the context you already know best.</p>
            <Button asChild size="lg" className="primary-button">
              <Link href="/request-workshop">Request a workshop</Link>
            </Button>
          </div>
        </div>
      </section>
    </>
  );
}
