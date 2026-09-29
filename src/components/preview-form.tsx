"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

type PreviewFormProps = { kind: "contact" | "workshop" };

export function PreviewForm({ kind }: PreviewFormProps) {
  const [submitted, setSubmitted] = useState(false);
  const [pending, setPending] = useState(false);
  const [error, setError] = useState("");
  const isWorkshop = kind === "workshop";

  if (submitted) {
    return (
      <div className="form-success" role="status">
        <p>Thank you. Your message is with the team.</p>
        <span>
          We will reply using the contact details you provided. For an urgent response, email <a href="mailto:info@sustainersnest.org">info@sustainersnest.org</a>.
        </span>
      </div>
    );
  }

  return (
    <form
      className="public-form"
      onSubmit={async (event) => {
        event.preventDefault();
        setPending(true);
        setError("");
        const data = Object.fromEntries(new FormData(event.currentTarget));
        const response = await fetch(isWorkshop ? "/api/workshop-requests" : "/api/contact", {
          method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify(data),
        });
        const result = await response.json().catch(() => ({}));
        setPending(false);
        if (response.ok) setSubmitted(true);
        else setError(result.error || "We could not send this form. Please email us instead.");
      }}
    >
      <div className="form-row">
        <div className="field-group">
          <Label htmlFor={`${kind}-name`}>{isWorkshop ? "Contact person" : "Your name"}</Label>
          <Input id={`${kind}-name`} name="name" autoComplete="name" required />
        </div>
        <div className="field-group">
          <Label htmlFor={`${kind}-email`}>Email address</Label>
          <Input id={`${kind}-email`} name="email" type="email" autoComplete="email" required />
        </div>
      </div>
      {isWorkshop ? (
        <>
          <div className="form-row">
            <div className="field-group">
              <Label htmlFor="school">School name</Label>
              <Input id="school" name="school" required />
            </div>
            <div className="field-group">
              <Label htmlFor="phone">Phone number</Label>
              <Input id="phone" name="phone" type="tel" autoComplete="tel" required />
            </div>
          </div>
          <div className="form-row">
            <div className="field-group">
              <Label htmlFor="students">Estimated student count</Label>
              <Input id="students" name="students" type="number" min="1" />
            </div>
            <div className="field-group">
              <Label htmlFor="date">Preferred date</Label>
              <Input id="date" name="date" type="date" />
            </div>
          </div>
        </>
      ) : null}
      <div className="field-group">
        <Label htmlFor={`${kind}-message`}>
          {isWorkshop ? "What should the session help students explore?" : "How can we help?"}
        </Label>
        <Textarea id={`${kind}-message`} name="message" rows={6} required />
      </div>
      <div className="field-group form-honeypot" aria-hidden="true">
        <Label htmlFor={`${kind}-website`}>Website</Label>
        <Input id={`${kind}-website`} name="website" tabIndex={-1} autoComplete="off" />
      </div>
      <Button className="primary-button form-submit" size="lg" type="submit" disabled={pending}>
        {pending ? "Sending…" : isWorkshop ? "Send workshop request" : "Send message"}
      </Button>
      {error ? <p className="form-error" role="alert">{error}</p> : null}
      <p className="form-disclosure">Your details are used only to respond to this request.</p>
    </form>
  );
}
