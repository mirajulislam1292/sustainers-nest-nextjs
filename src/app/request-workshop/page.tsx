import type { Metadata } from "next";
import { PageIntro } from "@/components/page-intro";
import { PreviewForm } from "@/components/preview-form";

export const metadata: Metadata = { title: "Request a workshop" };

export default function RequestWorkshopPage() {
  return (
    <>
      <PageIntro
        index="05"
        title="Invite Sustainers NEST into your school."
        description="Tell us who the session is for, what your students are curious about and when you would like the workshop to happen."
      />
      <section className="form-section">
        <div className="site-container form-layout">
          <div className="contact-details">
            <p>What happens next</p>
            <ol>
              <li>We review your school’s priorities.</li>
              <li>We propose a session and available trainers.</li>
              <li>We confirm the schedule and preparation.</li>
            </ol>
          </div>
          <PreviewForm kind="workshop" />
        </div>
      </section>
    </>
  );
}
