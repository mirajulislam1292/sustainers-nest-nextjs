import Image from "next/image";
import Link from "next/link";
import { navigation } from "@/data/site";

export function SiteFooter() {
  return (
    <footer className="site-footer">
      <div className="site-container footer-grid">
        <div className="footer-brand">
          <Image src="/logo.jpg" alt="" width={64} height={64} />
          <p>Sustainers NEST</p>
          <span>Nature · Science · Technology</span>
        </div>
        <nav aria-label="Footer navigation">
          {navigation.map((item) => <Link key={item.href} href={item.href}>{item.label}</Link>)}
          <Link href="/request-workshop">Request a workshop</Link>
        </nav>
        <div className="footer-contact">
          <p>Dhaka, Bangladesh</p>
          <a href="mailto:info@sustainersnest.org">info@sustainersnest.org</a>
          <p className="footer-note">Verified social profiles will be added when available.</p>
        </div>
      </div>
      <div className="site-container footer-bottom">
        <p>© {new Date().getFullYear()} Sustainers NEST</p>
        <p>Built for the next generation of environmental leaders.</p>
      </div>
    </footer>
  );
}
