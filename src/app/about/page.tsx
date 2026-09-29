import type { Metadata } from "next";
import Link from "next/link";
import { PageIntro } from "@/components/page-intro";

export const metadata: Metadata = { title: "About" };

export default function AboutPage() {
  return (
    <>
      <PageIntro
        index="01"
        title="A place for young people to make sustainability practical."
        description="Sustainers NEST is a youth-driven organization in Bangladesh, built on the belief that ecological wisdom and technological imagination belong together."
      />
      <section className="content-section">
        <div className="site-container prose-grid">
          <h2>Why we exist</h2>
          <div className="long-copy">
            <p>
              The solutions to our planet’s greatest challenges sit at the intersection of
              nature, science and technology. We create immersive programs, foster research
              and build communities where young changemakers can work at that intersection.
            </p>
            <p>
              From grassroots environmental projects to technology initiatives, we give young
              people tools, mentorship and a platform for measurable work in their own
              communities and beyond.
            </p>
          </div>
        </div>
      </section>
      <section className="statement-section">
        <div className="site-container statement-grid">
          <article>
            <p>Mission</p>
            <h2>
              Empower young people with the knowledge, skills and collaborative platforms to
              build innovative, nature-inspired solutions.
            </h2>
          </article>
          <article>
            <p>Vision</p>
            <h2>
              A world where every young person can be an agent of sustainable change—and where
              ecological wisdom and technological innovation work hand in hand.
            </h2>
          </article>
        </div>
      </section>
      <section className="content-section">
        <div className="site-container prose-grid">
          <h2>The people behind the work</h2>
          <div className="long-copy">
            <p>
              The existing public archive names leadership roles but does not yet include
              verified names, biographies or portraits. We are preparing a public directory
              that treats every member accurately and with their consent.
            </p>
            <p>
              If you are part of the Sustainers NEST team and want to update your listing,
              write to <a href="mailto:info@sustainersnest.org">info@sustainersnest.org</a>.
            </p>
            <Link className="text-link" href="/contact">Contact the organization</Link>
          </div>
        </div>
      </section>
    </>
  );
}
