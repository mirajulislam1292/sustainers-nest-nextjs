"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

type PreviewFormProps = { kind: "contact" | "workshop" };

export function PreviewForm({ kind }: PreviewFormProps) {
  const [submitted, setSubmitted] = useState(false);
  const isWorkshop = kind === "workshop";

  if (submitted) {
    return (
      <div className="form-success" role="status">
        <p>Thank you. Your form is complete in this preview.</p>
        <span>
          Database delivery will be connected in the backend phase. For an immediate response,
          email <a href="mailto:info@sustainersnest.org">info@sustainersnest.org</a>.
        </span>
      </div>
    );
  }

  return (
    <form
      className="public-form"
      onSubmit={(event) => {
        event.preventDefault();
        setSubmitted(true);
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
      <Button className="primary-button form-submit" size="lg" type="submit">
        {isWorkshop ? "Send workshop request" : "Send message"}
      </Button>
      <p className="form-disclosure">This local preview does not transmit or store personal data.</p>
    </form>
  );
}
