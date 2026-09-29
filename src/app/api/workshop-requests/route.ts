import { createAdminSupabaseClient } from "@/lib/supabase/admin";
import { workshopSchema } from "@/lib/validation";

export async function POST(request: Request) {
  const parsed = workshopSchema.safeParse(await request.json().catch(() => null));
  if (!parsed.success) return Response.json({ error: "Please check the form fields." }, { status: 400 });
  const supabase = createAdminSupabaseClient();
  if (!supabase) return Response.json({ error: "Online requests are being configured. Please email us instead." }, { status: 503 });
  const { school, name, email, phone, students, date, message } = parsed.data;
  const { error } = await supabase.from("workshop_requests").insert({
    school_name: school,
    authority_name: name,
    email,
    phone,
    estimated_students: students || null,
    preferred_dates: date ? [date] : [],
    goals: message,
  });
  if (error) return Response.json({ error: "We could not save your request. Please email us instead." }, { status: 500 });
  return Response.json({ ok: true }, { status: 201 });
}
