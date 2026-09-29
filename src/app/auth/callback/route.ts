import { NextResponse } from "next/server";
import { createServerSupabaseClient } from "@/lib/supabase/server";

export async function GET(request: Request) {
  const url = new URL(request.url);
  const code = url.searchParams.get("code");
  const supabase = await createServerSupabaseClient();
  if (!code || !supabase) return NextResponse.redirect(new URL("/sign-in?error=configuration", url));

  const { error } = await supabase.auth.exchangeCodeForSession(code);
  if (error) return NextResponse.redirect(new URL("/sign-in?error=oauth", url));
  const { data: { user } } = await supabase.auth.getUser();
  const domain = user?.email?.split("@").at(-1)?.toLowerCase();
  if (!user || domain !== "sustainersnest.org" || user.app_metadata.provider !== "google") {
    await supabase.auth.signOut();
    return NextResponse.redirect(new URL("/sign-in?error=workspace", url));
  }
  return NextResponse.redirect(new URL("/dashboard", url));
}
