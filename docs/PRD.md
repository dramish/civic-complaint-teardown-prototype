# PRD: Complaint Verification Integrity
**Product:** Swachhata-MoHUA
**Author:** Ishita Bansal
**Status:** Draft v3 — pure product PRD (engineering implementation details moved to a separate appendix doc)
**Companion doc:** Product Teardown (CIRCLES Method)

---

## 1. Executive Summary

Swachhata-MoHUA's "Resolved" status can be set by the same actor who most wants the ticket closed, with no independent check. This PRD proposes **Citizen Verification Window (CVW)** — a citizen confirm/reject step before a ticket is truly closed — paired with **Mandatory Re-routing** to stop jurisdiction mismatches from being misclassified as accountability failures.

This is a **hypothesis-driven proposal**, not a validated fix: we do not yet know the true false-closure rate. Phase 1 instruments and measures it. Phase 2 pilots the fix, staged to allow causal attribution. Every numeric threshold below is a **pilot starting point**, not a committed requirement.

---

## 2. Evidence & Hypotheses

| Status | Claim |
|---|---|
| **Known** | Citizens can and do report unresolved issues after a complaint shows "Resolved." A reopen mechanism exists but is timed from filing, not resolution. Jurisdiction mismatches exist and are currently handled by a generic "Rejected" status. |
| **Observed, not quantified** | Multiple app-store reviews (2018–2025) describe the same issue marked "Resolved" repeatedly; one 2025 review names a supervisor closing a ticket with a blank/unrelated photo. Google Play currently shows ~2.1★ across ~66K ratings, 5M+ listed installs. This is directional evidence of dissatisfaction, not a measured false-closure rate. |

**The hypothesis is deliberately split into four testable parts** rather than one broad claim:

| ID | Hypothesis | How it's measured |
|---|---|---|
| H1 | False closures occur at a material rate | Sampled Confirmed False Closure Rate (§7). **Decision criterion:** a specific "material" threshold must be pre-registered during Phase 1, before seeing the data — otherwise materiality can be interpreted after the fact. |
| H2 | False closures are associated with higher rates of repeat complaints | Association (not claimed causation) between false-closure sample and same-location repeat filings — repeat complaints can also stem from density, recurring physical issues, or complaint propensity, not just false closure |
| H3 | Citizen verification reduces false closures | Treatment (CVW) vs. control, staged pilot (§8) |
| H4 | Citizen verification does not push resolution time beyond an acceptable threshold | Median time-to-resolution guardrail, treatment vs. control |

Complaint-resolution integrity's effect on Swachh Survekshan scoring is **not established here** and should be confirmed against actual MoHUA/QCI methodology before being asserted as fact anywhere downstream of this doc.

---

## 3. Problem Definition

The municipal actor responsible for closing the complaint (referred to here as "inspector" for readability, pending confirmation of the actual role — sanitary inspector, supervisor, or contractor — that controls resolution evidence in practice) also controls the only evidence used to close it. This is a structural authority gap, not a UI defect — and it doesn't self-correct the way gig-platform ratings do, because sanitation workers are salaried, not revenue-dependent on ratings. Government-specific mechanisms are required.

**Non-goal:** forcing faster municipal execution (budget, staffing, physical cleanup speed) — outside what any app can affect.

---

## 4. Users + Jobs

- **Citizen** — needs a "Resolved" status they can trust, without high ongoing burden.
- **Inspector** — needs a closing workflow that doesn't penalize legitimate "wrong department" cases as failures.
- **MoHUA / municipal corporation** — needs complaint data whose integrity can be defended if it feeds program-level rankings.

---

## 5. Current State & Failure Point

Login → category + photo capture → submit → routed to inspector → inspector uploads proof photo → **status flips directly to Resolved** → 24h reopen window (timed from filing, not resolution).

Failure point: the proof photo is timestamp-verified only — never checked against complaint location or content — and the reopen window can close before a citizen sees a bad resolution.

---

## 6. Proposed Experience

### 6.1 Citizen Verification Window (CVW)

Inspector's proof photo moves the ticket to **Pending Verification**, not Resolved. Citizen is notified (SMS/WhatsApp, with IVR fallback — §6.5) and has a window to confirm or reject; no response auto-closes.

- Not a truth guarantee — meaningfully harder to game, not impossible. A system requiring explicit confirmation on millions of tickets doesn't scale, so silence-defaults-to-closed is a deliberate, disclosed trade-off.
- Window length (48h) is a **pilot hypothesis**, to be calibrated against real citizen response-time data.

### 6.2 Rejection Taxonomy

"Citizen rejects" currently conflates several different situations. Rejections should be categorized:

| Category | Meaning | Counts toward false-closure measurement? |
|---|---|---|
| Not resolved | Issue clearly still present | Yes |
| Location/photo mismatch | Proof doesn't match the complaint's location or content | Yes |
| Partially resolved | Some action taken, issue not fully addressed | Reviewed case-by-case, not auto-counted |
| Recurred | Was fixed, has since come back | No — separate signal, tracked but not counted as false closure |
| Other | Doesn't fit above | Reviewed manually |

This distinction matters because "still dirty" can mean the inspector didn't do the work, or that the citizen wanted a broader scope of cleanup than the complaint covered — these are different failure modes and shouldn't be measured identically.

### 6.3 State Model (product-level, not implementation)

```
Submitted -> Assigned -> In Progress
                            |
                  [Out of jurisdiction?] -> Escalated (6.4)
                            |
                  Pending Verification (inspector uploads proof)
                    - Citizen confirms -> Resolved
                    - Citizen rejects (see taxonomy 6.2) -> Reopened -> Review/Reassignment
                    - No response (window elapses) -> Auto-Resolved (flagged for sampling, 7)
                    - Tele-verification sampled (9) -> overrides to Resolved or Reopened
```

**Conflict rule:** tele-verification, when triggered, is authoritative over citizen non-response but not over an explicit citizen rejection — a citizen's active "not fixed" cannot be silently overridden by a sampled call.

**Reopened path:** not every rejection means the same inspector automatically gets the ticket back — routing to review vs. reassignment depends on the rejection reason (§6.2). A "partially resolved" rejection may warrant review before reassignment; "not resolved" or "photo mismatch" more directly implies reassignment.

**Design principle:** citizen participation is a verification signal, not a prerequisite for municipal closure — the system still closes on silence. CVW's role is to give citizens standing to contest a closure, not to require their active sign-off on every ticket.

### 6.4 Mandatory Re-routing (replaces generic "Rejected")

Out-of-scope tickets (e.g., sewage needing PWD budget, not ward cleanup) must transfer to the correct department with status `Escalated → [Department]` and a visible tracking ID, instead of a dead-end "Rejected."

**On enforcement:** the product's job is routing, acknowledgment, and escalation — not departmental scoring, which is outside product control. An agency that doesn't digitally acknowledge a transfer within 72h (pilot hypothesis) triggers an operational escalation and is logged as a flagged exception for the relevant reporting cycle. Whether that exception should affect a department's formal performance score is a **policy decision outside this product's scope** — Swachh Survekshan evaluation runs through periodic third-party audit (QCI), not a live, product-controlled score. This PRD owns measurement and escalation; any scoring linkage is a separate policy proposal (§10).

### 6.5 Duplicate / Clustered Complaints

A single incident (burst pipe, large dump) can generate many individual complaints. Without clustering, one resolution triggers many redundant CVW prompts with no conflict-resolution rule.

**Approach:** complaints within a small radius and shared category are grouped as a cluster under one resolution event, broadcasting verification to all reporters. Closure requires majority confirmation.

**Minority-rejection handling (corrected from earlier draft):** a single rejection should **not** automatically reopen a cluster confirmed by a large majority — that's a griefing vector where one actor can override many. Instead: reopen automatically only if the rejection rate exceeds a pilot-determined threshold; a low-rate minority rejection routes to sampled review rather than an automatic reopen. Exact radius and thresholds are pilot outputs, not fixed in this doc.

**Scope note:** clustering solves a real notification-burden problem but adds meaningful design surface of its own (geospatial/temporal grouping, cluster splitting/merging, ownership). **Deferred from the P0 CVW pilot** unless clustered complaints prove to be a major share of volume — in that case, Phase 2 initially handles duplicate complaints independently, and cluster-level verification ships as a follow-on optimization once notification burden is shown to be material.

### 6.6 Feature-Phone / Low-Connectivity Accessibility

WhatsApp/SMS with an image link excludes citizens on basic feature phones or with poor connectivity — including municipalities with lower connectivity, where the proposed verification channel must still work.

**Approach:** IVR fallback via the existing 1969 helpline (automated call: "Press 1 if [issue] was cleared, Press 2 if not"), with two-way SMS as a lighter-weight alternative where IVR infra isn't available.

### 6.7 Explicitly rejected: passive photo verification (EXIF/ML)
Inspectors control the camera in the field and can trivially defeat a passive check (photograph a clean patch 5m away, or a printed photo). The fix has to change *who holds closing authority*, not what the system inspects.

---

## 7. Metrics

**Primary metric (corrected):**
- **Confirmed False Closure Rate** = (sampled closures independently confirmed as false) / (sampled closures successfully verified). Sample is drawn via stratified random sampling — across ward, department, resolution type, citizen response/non-response, inspector, and complaint category — not citizen self-report, and not purely random or purely targeted (either misses prevalence or misses where the problem concentrates).

**Outcome metrics (secondary):**
- Verified Resolution Rate — % of complaints confirmed-resolved after the window closes. Kept as a useful operational signal, but not the North Star, since it can look healthy even while some auto-closed-on-silence tickets remain unresolved.
- **Citizen Verification Response Rate** — % of Pending Verification complaints receiving an explicit citizen confirm/reject action within the window. CVW's actual efficacy depends on participation, not just its existence — if most citizens don't respond, CVW converges toward the current system's behavior (silence → closed), so this rate is what determines whether CVW is doing anything beyond adding a notification step.
- Repeat-complaint rate on the same cluster/location within a set window
- Citizen rejection rate, broken out by taxonomy category (§6.2)

**Guardrails:**
- Median time-to-resolution (H4: should not exceed current by more than a pilot-defined margin)
- Silent auto-close rate per ward
- Escalation/re-routing acknowledgment rate within SLA

---

## 8. Experiment Design

To attribute impact correctly, **CVW and Mandatory Re-routing should not launch simultaneously in the same wards** without a way to separate their effects.

- **Phase 1 — Instrument only (Weeks 1–2):** ship tracking for current reopen/reject/repeat-complaint rates. Establish the real baseline — currently unmeasured.
- **Phase 2 — Staged pilot (Weeks 3–10):**
  - Group A (2–3 wards): CVW only
  - Group B (2–3 wards): Mandatory Re-routing only
  - Group C (control): current flow unchanged
  - Measured against §7 metrics, mapped to H1–H4.
- **Phase 3 — Combined rollout:** once individual effects are understood, combine both in an expanded pilot before going national.

---

## 9. Risks & Abuse Cases

| Risk | Mitigation | Residual cost |
|---|---|---|
| Engineered silent-closure (inspector times submission for low-response hours) | If a ward's silent-closure rate exceeds a pilot-calibrated threshold, extend that ward's window and route a sample to tele-verification | Delays confirmation even for genuinely resolved tickets in that ward — self-corrects as rate drops |
| Minority-veto on clustered complaints | Rejection-rate threshold + sampled review instead of any-single-rejection reopen (§6.5) | Some false negatives may still slip through sampling |
| Escalation becomes inter-agency dumping ground | Acknowledgment SLA + logged exceptions (§6.4); product owns measurement, not scoring | Cross-agency process overhead; actual consequence depends on policy adoption |
| Citizen burden / non-engagement (no WhatsApp, doesn't read SMS, elderly, files many complaints, fears retaliation) | IVR/SMS fallback (§6.6); silence still defaults to closed rather than blocking on engagement | Doesn't fully solve low-engagement citizens; auto-close risk remains for that group specifically |
| Technical vs. practical anonymity — masking hides the phone number, but the complained-about party may still infer identity from context (e.g., "only one complaint on this lane this week") | Flagged as an unresolved threat-model gap, not solvable by masking alone | Open problem, not claiming full resolution here |
| Offline citizens can't respond within window | Confirm/reject recorded locally and synced once connectivity returns rather than requiring a live round-trip | Doesn't fix genuinely no-signal areas |

---

## 10. Rollout

1. Instrument & baseline (Weeks 1–2)
2. Staged pilot, isolated interventions (Weeks 3–10, §8)
3. Combined pilot expansion once causal effects are understood
4. National rollout, phased by state

**The product rollout above is complete and self-contained — it does not depend on any policy change to work.**

---

## 11. Future Policy Considerations (non-blocking, outside product scope)

Escalation-exception data (§6.4) could inform Swachh Survekshan's scoring methodology, and/or a Reopen Penalty Index could be proposed to MoHUA/QCI so false closures carry a cost at the same level fast-closure rewards already exist. This is a recommendation to MoHUA/QCI, not a product deliverable — noted here for completeness, not assumed to be adopted, and not required for any stage of the rollout above.

---

## 12. Open Questions

- What is the actual baseline false-closure rate? (Phase 1 exists specifically to answer this.)
- What is the real mechanism, if any, linking complaint-level data to Swachh Survekshan scoring?
- Can practical (not just technical) anonymity be achieved for complainants in low-density areas?
- What window length, cluster radius, and rejection-rate threshold actually hold up against real citizen response behavior? (All current numbers are pilot starting points.)

---

*Engineering-level detail (API contracts, state persistence, retry/idempotency handling) is intentionally out of scope for this PRD and covered in a separate engineering design doc.*
