import { z } from "zod";

const safeText = z.string().trim().min(2).max(5000);

export const contactSchema = z.object({
  name: z.string().trim().min(2).max(120),
  email: z.email().max(254),
  message: safeText,
  website: z.string().max(0).optional(),
});

export const workshopSchema = contactSchema.extend({
  school: z.string().trim().min(2).max(180),
  phone: z.string().trim().min(6).max(40),
  students: z.preprocess((value) => value === "" ? undefined : value, z.coerce.number().int().positive().max(100000).optional()),
  date: z.iso.date().optional().or(z.literal("")),
});
