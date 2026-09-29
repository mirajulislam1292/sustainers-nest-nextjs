import { createAdminSupabaseClient } from "@/lib/supabase/admin";
import { contactSchema } from "@/lib/validation";

export async function POST(request: Request) {
  const parsed = contactSchema.safeParse(await request.json().catch(() => null));
  if (!parsed.success) return Response.json({ error: "Please check the form fields." }, { status: 400 });
  const supabase = createAdminSupabaseClient();
  if (!supabase) return Response.json({ error: "Online submissions are being configured. Please email us instead." }, { status: 503 });
  const { name, email, message } = parsed.data;
  const { error } = await supabase.from("contact_messages").insert({ name, email, message });
  if (error) return Response.json({ error: "We could not save your message. Please email us instead." }, { status: 500 });
  return Response.json({ ok: true }, { status: 201 });
}
