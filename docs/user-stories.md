# User Stories and Acceptance Criteria

**Status:** draft, derived from `PRD.md`. Windows, thresholds and radii are pilot starting points, not commitments (see PRD sections 6 and 7). Section references point to the PRD.

Priority: **P0** = in the first pilot, **P1** = follow-on.

---

## US-1: Verify a resolution before it closes (P0, PRD 6.1)

**As a** citizen who filed a complaint, **I want** to see the proof photo and confirm or contest it before the ticket is marked Resolved, **so that** I am not told a problem is fixed when it is not.

Acceptance criteria:
- Given an inspector uploads proof, when the upload completes, then the ticket status becomes **Pending Verification**, not Resolved.
- Given a ticket is Pending Verification, then the citizen is notified by SMS or WhatsApp with a link to the proof photo.
- Given the citizen confirms, then the status becomes **Resolved**.
- Given the citizen rejects, then the status becomes **Reopened** (see US-2).
- Given the window elapses with no response, then the status becomes **Auto-Resolved** and the ticket is flagged for sampling (PRD 7).
- The window length is configurable per ward. The pilot default is 48 hours.

## US-2: Say why a resolution is wrong (P0, PRD 6.2, 6.3)

**As a** citizen, **I want** to give a reason when I reject a resolution, **so that** the right follow-up happens.

Acceptance criteria:
- Rejecting requires choosing one reason: Not resolved, Location/photo mismatch, Partially resolved, Recurred, or Other.
- Not resolved and Location/photo mismatch count toward the false-closure measurement. Partially resolved and Other are reviewed manually. Recurred is tracked separately and is not counted.
- Not resolved and Location/photo mismatch route to reassignment. Partially resolved routes to review first.
- A sampled tele-verification result cannot override an explicit citizen rejection. It can override non-response.

## US-3: Transfer a complaint that belongs to another department (P0, PRD 6.4)

**As an** inspector, **I want** to transfer an out-of-jurisdiction ticket to the right department, **so that** it is not recorded as a failure on my side or lost in a dead end.

Acceptance criteria:
- The generic **Rejected** action is removed.
- Transferring requires selecting a receiving department.
- The ticket status shows **Escalated to [Department]** and a visible tracking ID.
- If the receiving department does not acknowledge within the pilot window (72 hours), an operational escalation is triggered and logged as an exception.
- The product records and escalates. It does not score departments (PRD 6.4, 11).

## US-4: Verify without a smartphone (P0, PRD 6.6)

**As a** citizen with a feature phone or poor connectivity, **I want** to confirm or reject by call or SMS reply, **so that** I am not excluded from verification.

Acceptance criteria:
- Citizens without a data connection can respond through an automated call ("Press 1 if cleared, Press 2 if not") or a two-way SMS reply.
- A response by any channel produces the same ticket outcome as an in-app response.
- Where IVR infrastructure is unavailable, two-way SMS is used.

## US-5: Respond while offline (P0, PRD 9)

**As a** citizen with an unreliable connection, **I want** my confirm or reject decision saved when I tap it, **so that** a dropped connection does not lose it.

Acceptance criteria:
- The decision is stored locally immediately and shown as "Saved, will send".
- The decision is retried with backoff and sent when connectivity returns.
- Repeated sends of the same decision do not create duplicate outcomes.
- **Open question:** whether a decision made inside the window but delivered after it elapses should count. To be settled during the pilot (PRD 12).

## US-6: Keep a complainant's identity protected (P0, PRD 9)

**As a** citizen, **I want** field staff not to see my phone number, **so that** I am not exposed to the party I complained about.

Acceptance criteria:
- Field staff see only the location and the complaint, not the citizen's phone number.
- A separate audit-only log is kept for genuine investigations.
- Known gap: context can still reveal identity in low-density areas. This is documented as unresolved in PRD 9.

## US-7: Measure whether false closures are happening (P0, PRD 7, 8)

**As a** program owner, **I want** a measured false-closure rate and the guardrails around it, **so that** I can tell whether the change works.

Acceptance criteria:
- A sample of closures is drawn by stratified random sampling across ward, department, resolution type, citizen response vs non-response, inspector and complaint category.
- **Confirmed False Closure Rate** = sampled closures confirmed false / sampled closures successfully verified.
- Guardrails are reported per ward: median time-to-resolution, silent auto-close rate, and re-routing acknowledgment rate within SLA.
- Phase 1 ships tracking only, to establish the baseline before any pilot change (PRD 8).

## US-8: Group duplicate complaints into one verification (P1, PRD 6.5)

**As a** citizen who reported the same incident as others, **I want** one verification for the whole cluster, **so that** I am not spammed with prompts.

Acceptance criteria:
- Deferred from the first pilot. Duplicates are handled independently until clustered complaints are shown to be a material share of volume.
- When built: closure requires majority confirmation, and a single rejection does not automatically reopen a cluster confirmed by a large majority.
