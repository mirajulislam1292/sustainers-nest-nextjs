import type { Metadata } from "next";
import { PageIntro } from "@/components/page-intro";
import { PreviewForm } from "@/components/preview-form";

export const metadata: Metadata = { title: "Contact" };

export default function ContactPage() {
  return (
    <>
      <PageIntro
        index="04"
        title="Start a useful conversation."
        description="For partnerships, volunteering, media or general questions, write to the Sustainers NEST team in Dhaka."
      />
      <section className="form-section">
        <div className="site-container form-layout">
          <div className="contact-details">
            <p>Direct contact</p>
            <a href="mailto:info@sustainersnest.org">info@sustainersnest.org</a>
            <p>Dhaka, Bangladesh</p>
            <span>We have omitted social buttons until the organization’s official profile URLs are verified.</span>
          </div>
          <PreviewForm kind="contact" />
        </div>
      </section>
    </>
  );
}
