import Image from "next/image";
import Link from "next/link";
import { ArrowUpRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { impactStats, pillars, programs } from "@/data/site";

export default function HomePage() {
  return (
    <>
      <section className="hero-shell">
        <div className="site-container hero-grid">
          <div className="hero-copy">
            <p className="place-line">Dhaka, Bangladesh · Youth-led since 2024</p>
            <h1>Young minds, grounded in nature.</h1>
            <p className="hero-dek">
              We help young people turn ecological curiosity into practical action—through
              science, technology and work rooted in their own communities.
            </p>
            <div className="hero-actions">
              <Button asChild size="lg" className="primary-button">
                <Link href="/request-workshop">Request a school workshop</Link>
              </Button>
              <Link className="text-link" href="/about">
                Read our story <ArrowUpRight aria-hidden="true" />
              </Link>
            </div>
          </div>

          <figure className="hero-mark">
            <div className="logo-field">
              <Image
                src="/logo.jpg"
                alt="Sustainers NEST logo: a green nest encircling a growing leaf"
                width={840}
                height={840}
                priority
                sizes="(max-width: 800px) 90vw, 42vw"
              />
            </div>
            <figcaption>
              Nature gives us the pattern. Science gives us the evidence. Technology helps
              young people put both to work.
            </figcaption>
          </figure>
        </div>
      </section>

      <section className="impact-strip" aria-labelledby="impact-heading">
        <div className="site-container">
          <div className="section-heading-row">
            <h2 id="impact-heading">The work, in numbers</h2>
            <p>Figures currently published by Sustainers NEST.</p>
          </div>
          <dl className="impact-list">
            {impactStats.map((stat) => (
              <div key={stat.label}>
                <dt>{stat.label}</dt>
                <dd>{stat.value}</dd>
              </div>
            ))}
          </dl>
        </div>
      </section>

      <section className="content-section">
        <div className="site-container editorial-split">
          <div className="sticky-heading">
            <p className="section-number">01</p>
            <h2>One practice, three forces</h2>
            <p>
              Sustainability becomes useful when observation, evidence and making happen in
              the same room.
            </p>
          </div>
          <ol className="pillar-list">
            {pillars.map((pillar, index) => (
              <li key={pillar.name}>
                <span>0{index + 1}</span>
                <div>
                  <h3>{pillar.name}</h3>
                  <p>{pillar.description}</p>
                  <ul>
                    {pillar.points.map((point) => <li key={point}>{point}</li>)}
                  </ul>
                </div>
              </li>
            ))}
          </ol>
        </div>
      </section>

      <section className="content-section program-section">
        <div className="site-container">
          <div className="section-heading-row wide">
            <div>
              <p className="section-number">02</p>
              <h2>Programs built for doing</h2>
            </div>
            <Link className="text-link" href="/programs">
              Explore all programs <ArrowUpRight aria-hidden="true" />
            </Link>
          </div>
          <div className="program-index">
            {programs.slice(0, 4).map((program, index) => (
              <article key={program.slug}>
                <p>{String(index + 1).padStart(2, "0")}</p>
                <h3>{program.title}</h3>
                <p>{program.summary}</p>
              </article>
            ))}
          </div>
        </div>
      </section>

      <section className="field-note-section">
        <div className="site-container field-note-grid">
          <div>
            <p className="section-number light">03 · From the field</p>
            <h2>A shared voice for climate action in Narayanganj</h2>
          </div>
          <div>
            <p>
              Sustainers NEST volunteers joined students and local organizations during a
              Global Climate Strike gathering in Narayanganj—bringing the climate crisis back
              to the lives, livelihoods and choices of young people in Bangladesh.
            </p>
            <a
              className="text-link light-link"
              href="https://alordhara24.com/%E0%A6%97%E0%A7%8D%E0%A6%B2%E0%A7%8B%E0%A6%AC%E0%A6%BE%E0%A6%B2-%E0%A6%95%E0%A7%8D%E0%A6%B2%E0%A6%BE%E0%A6%87%E0%A6%AE%E0%A7%87%E0%A6%9F-%E0%A6%B8%E0%A7%8D%E0%A6%9F%E0%A7%8D%E0%A6%B0%E0%A6%BE%E0%A6%87/"
              target="_blank"
              rel="noreferrer"
            >
              Read the local report <ArrowUpRight aria-hidden="true" />
            </a>
          </div>
        </div>
      </section>

      <section className="closing-cta">
        <div className="site-container closing-grid">
          <h2>Bring a practical sustainability session to your school.</h2>
          <div>
            <p>
              Tell us about your students, your priorities and the dates that work. Our team
              will follow up to shape the right session.
            </p>
            <Button asChild size="lg" className="primary-button">
              <Link href="/request-workshop">Start a workshop request</Link>
            </Button>
          </div>
        </div>
      </section>
    </>
  );
}
