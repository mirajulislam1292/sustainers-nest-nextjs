import type { Metadata } from "next";
import { PageIntro } from "@/components/page-intro";
import { journalEntries } from "@/data/site";

export const metadata: Metadata = { title: "Journal" };

export default function JournalPage() {
  return (
    <>
      <PageIntro
        index="03"
        title="Notes from classrooms, communities and works in progress."
        description="The journal will bring together field reflections, program updates and longer editorial stories from Sustainers NEST members."
      />
      <section className="content-section compact-top">
        <div className="site-container journal-list">
          {journalEntries.map((entry) => (
            <article key={entry.title}>
              <div>
                <p>{entry.type}</p>
                <time>{entry.date}</time>
              </div>
              <h2>{entry.title}</h2>
              <p>{entry.excerpt}</p>
            </article>
          ))}
        </div>
      </section>
      <section className="journal-note">
        <div className="site-container prose-grid">
          <h2>Daily field journals are coming next</h2>
          <p>
            In the backend phase, authenticated volunteers will be able to write reflections
            after school visits. Editors will review entries before anything is published.
          </p>
        </div>
      </section>
    </>
  );
}
