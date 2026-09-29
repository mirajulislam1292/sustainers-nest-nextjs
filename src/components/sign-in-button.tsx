"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { createBrowserSupabaseClient } from "@/lib/supabase/browser";

export function SignInButton() {
  const [message, setMessage] = useState("");
  async function signIn() {
    const supabase = createBrowserSupabaseClient();
    if (!supabase) return setMessage("Supabase credentials have not been added yet.");
    const { error } = await supabase.auth.signInWithOAuth({
      provider: "google",
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
        queryParams: { hd: "sustainersnest.org", prompt: "select_account" },
      },
    });
    if (error) setMessage(error.message);
  }
  return (
    <div>
      <Button className="primary-button" size="lg" onClick={signIn}>Continue with Google Workspace</Button>
      {message ? <p className="auth-message" role="status">{message}</p> : null}
    </div>
  );
}
