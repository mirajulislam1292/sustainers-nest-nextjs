"use client";

import Image from "next/image";
import Link from "next/link";
import { Menu } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Sheet, SheetClose, SheetContent, SheetTitle, SheetTrigger } from "@/components/ui/sheet";
import { navigation } from "@/data/site";

export function SiteHeader() {
  return (
    <header className="site-header">
      <div className="site-container header-inner">
        <Link className="brand" href="/" aria-label="Sustainers NEST home">
          <Image src="/logo.jpg" alt="" width={44} height={44} priority />
          <span>Sustainers NEST</span>
        </Link>
        <nav className="desktop-nav" aria-label="Primary navigation">
          {navigation.map((item) => <Link key={item.href} href={item.href}>{item.label}</Link>)}
          <Button asChild className="nav-action"><Link href="/request-workshop">Request a workshop</Link></Button>
        </nav>
        <Sheet>
          <SheetTrigger asChild>
            <Button className="menu-button" variant="ghost" size="icon" aria-label="Open navigation">
              <Menu aria-hidden="true" />
            </Button>
          </SheetTrigger>
          <SheetContent className="mobile-sheet" side="right">
            <SheetTitle className="mobile-sheet-title">Sustainers NEST</SheetTitle>
            <nav className="mobile-nav" aria-label="Mobile navigation">
              {navigation.map((item) => (
                <SheetClose asChild key={item.href}><Link href={item.href}>{item.label}</Link></SheetClose>
              ))}
              <SheetClose asChild><Link href="/request-workshop">Request a workshop</Link></SheetClose>
            </nav>
          </SheetContent>
        </Sheet>
      </div>
    </header>
  );
}
