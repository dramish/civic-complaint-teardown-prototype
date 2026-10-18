# Product Teardown: Swachhata-MoHUA

**Author:** Ishita Bansal
**Framework:** CIRCLES Method
**Category:** GovTech / Civic Complaint Management

---

## Repo map

| What | Where |
|---|---|
| Teardown (CIRCLES) | this README |
| Product requirements, hypotheses, metrics, experiment design | [`docs/PRD.md`](docs/PRD.md) |
| User stories and acceptance criteria | [`docs/user-stories.md`](docs/user-stories.md) |
| Research method, survey and coding template (planned, not yet run) | [`docs/research/`](docs/research/) |
| SwiftUI prototype of the verification flow | [`SwiftUI-Prototype/`](SwiftUI-Prototype/) |

Everything beyond the teardown is a proposal. Metrics, thresholds and the pilot are plans, not results.

---

## Why This App

Most product teardowns pick Slack, Notion, Duolingo, or Airbnb. This one picks a government sanitation-complaint app because it surfaces a problem more interesting than a UI critique: a product whose core trust mechanism is actively being gamed, at scale, with no automated way to catch it.

---

## 1. Comprehend the Context

**What it is:** Swachhata-MoHUA is the official civic-complaint app of India's Ministry of Housing and Urban Affairs, built by Janaagraha. A citizen photographs a civic issue — garbage dump, blocked toilet, sewage overflow — the app auto-captures location, and the complaint routes to a ward-level sanitary inspector.

**Scale:**

| Metric | Android (Play Store) | iOS (App Store) |
|---|---|---|
| Rating | 2.13 / 5 | 3.3 / 5 |
| Ratings count | ~62,000 | ~7,800 |
| Total downloads | 8.4 million | — |

The platform gap is worth noting, but the complaint pattern underneath both is nearly identical — this is systemic, not a platform bug.

**Constraint:** The app can only route information and display status — it cannot force ground-level action. Its job is to make the complaint-to-resolution loop legible and trustworthy.

**The core insight:** the system asks the least-informed actor — the app itself, via a photo — to judge whether a problem is fixed, while handing control over the evidence to the actor who most wants the ticket closed. Everything below follows from fixing that single misplaced authority.

---

## 2. Identify the Users

- **Primary: The complaining citizen** — reports an issue, expects real resolution.
- **Secondary: The sanitary inspector** — receives the complaint, uploads proof of resolution.
- **Tertiary: The municipal corporation / MoHUA** — monitors aggregate resolution rates, feeding the national Swachh Survekshan ranking.

---

## 3. The Actual Complaint Journey

1. **Login** — phone + OTP (reviewers report intermittent failures, numbers appearing silently blocked).
2. **Select category and capture photo** — camera opens in-app; location auto-captured at the moment of capture.
3. **Submit** — routed to a ward-level sanitary inspector.
4. **Status tracking** — push notifications as status changes (Assigned → Resolved / Rejected).
5. **Resolution** — inspector uploads a proof photo, now timestamped as of a 2025 update. Status flips to "Resolved."
6. **Reopen (if unsatisfied)** — available for 24 hours, calculated from *filing* time, not resolution time.

**Where trust breaks:** step 5. The app verifies *when* a resolution photo was taken, not *what* it shows or *where*. A narrow, identifiable gap — not "the app is bad."

**Evidence → Inference:**

| Observed evidence | Inferred problem | Confidence |
|---|---|---|
| Multiple reviewers describe the same complaint marked "resolved" repeatedly with no visible fix | Resolution photos aren't checked against the original location/content | High — corroborated across platforms, years |
| A 2025 review names a supervisor closing complaints with a blank/unrelated photo | Verification is absent or trivially bypassable | High — specific, recent |
| A reviewer describes the reopen window closing before a bad resolution could be contested | Reopen timer starts at filing, not resolution | Medium — single detailed account |
| A citizen's details were allegedly passed to the person they complained about | No access-control separation between complaint data and the party being complained about | Medium — single account, flagged as hypothesis |

---

## 4. Report User Needs

- A citizen reported filing five complaints over 20 days about the same sewage overflow; each auto-marked resolved within 2–3 days while the issue remained.
- A 2025 review names a ward supervisor allegedly closing complaints with a blank photo as "proof," no worker ever sent.
- A reviewer flagged "Rejected" being applied with weak justification, and the reopen window often closing before a bad resolution can be contested.
- One account describes personal details being passed to the local corporator after a public complaint, who then asked them to stop posting publicly.

> Counterpoint, for credibility: a 2018 review describes a fast, well-handled resolution — official called within the hour, fixed within a day, satisfaction follow-up call the next day. The system works when the incentive is present — pointing root cause at inconsistent accountability, not a broken app.

---

## 5. Root Cause — Product Problem or Authority Problem?

Mostly authority/incentive — but the product has a specific, fixable complicity.

Garbage not collected, sewage not fixed — that's municipal execution, outside what any app can force. But the app makes false resolution easy and free:

- Verification is trivially gameable — a photo is required, but nothing checks it matches the complaint.
- No cost to a false "resolved" — fake and genuine closures look identical.
- The reopen window works against the citizen (filing time, not resolution time).
- No accountability trail — a citizen's details reportedly reached the person they complained about.

**Why this doesn't self-correct like a gig-platform rating:** Uber/Swiggy ratings trigger automated deactivation because revenue depends on it. Swachhata has an aggregate mechanism too — Swachh Survekshan, which ranks cities and pays real incentives (Haryana pays ₹12,000/year to workers in top-25%-ranked municipalities) — but it's scored at the city level, annually, disconnected from whether any single complaint was honestly resolved.

**Precedent that a tighter loop works:** a 2012 Delhi pilot (SocialCops) publicly recognized "Best Karamcharis of the Month" at the individual level — worker attendance and morale rose, and workers preferred trophies/certificates over the cash reward originally planned. Recognition, not just punishment, moved behavior.

---

## 6. Cut / Prioritize

**Primary pain point:** Citizens have no reliable way to verify a complaint was genuinely resolved, and whoever closes it falsely faces no consequence — eroding trust in the platform, not just individual complaints.

---

## 7. List Solutions

> **Note on iteration:** an earlier pass proposed passive EXIF/ML photo verification. Discarded — inspectors control the camera in the field and can trivially bypass a passive check (photograph a clean patch 5m away, or a printed photo). The fix has to change *who has authority to close the ticket*, not what the system inspects.

### Primary Interventions

| Type | Solution | Description |
|---|---|---|
| Safe | **Citizen-Gated Two-Factor Closing (2FC)** | Inspector's proof photo moves the ticket to "Pending Verification," not "Resolved." Citizen gets a WhatsApp/SMS with the photo, confirms or rejects within 48 hours; no response defaults to closed. Moves judgment to the actor with the most direct knowledge of whether the issue is still present — not a guarantee of truth, but a large improvement in who holds the evidence. |
| Structural | **Mandatory Re-routing** (replaces "Rejected") | Many rejections are jurisdiction mismatches, not accountability failures (e.g. sewage repair needs PWD budget, not ward cleanup). Remove the generic Rejected button; an out-of-scope ticket must be transferred, with status "In Progress – Escalated to [Department]" and a visible tracking ID. Separates "can't fix, wrong team" from "won't fix, no consequence." |

Honestly: the 48-hour default is a citizen veto window, not active verification — silence eventually permits closure. Kept anyway because a system requiring explicit confirmation on every ticket doesn't scale to millions of complaints; the honest claim is "meaningfully harder to game," not "impossible to game."

**Why not expose the individual worker to the user?** Safety (harassment risk, no due process) and legality (individual government employee performance records are generally exempt from RTI disclosure under Section 8(1)(j), per the Girish Deshpande judgment). 2FC sidesteps this — it routes authority to the citizen, not a worker scorecard.

### Risk & Edge-Case Mitigation (secondary — not the headline pitch)

- **2FC gamed by silence:** if a ward's silent-closure rate exceeds 20% over 30 days, its auto-close window extends to 7 days and a sample routes to tele-verification (existing 1969 helpline) — a real cost, since it also delays confirmation for genuinely resolved tickets in that ward, but one that self-corrects as the rate drops.
- **Escalation becoming a new dumping ground:** require the receiving agency to digitally acknowledge a transfer within 72 hours or it bounces back with an SLA penalty; after 2 bounces, auto-escalate to a joint authority for binding assignment.
- **Citizen data exposure:** mask phone numbers at the routing layer (the Ola/Uber pattern) so field staff see only geo-coordinates and the complaint, with an audit-only log retained for genuine investigations.

**Policy appendix (not a shippable feature):** a Reopen Penalty Index tied into Swachh Survekshan's ranking would attach a real cost to fake closures at the same national level the reward for fast closure already exists — but Swachh Survekshan's methodology is run by a third-party assessor (QCI) under MoHUA, so this is a recommendation to policymakers, not something a product team ships.

---

## 8. Prioritization & Trade-offs

*(Qualitative — directional judgments, not calculated RICE scores.)*

| Solution | Reach | Impact | Confidence | Effort | Priority |
|---|---|---|---|---|---|
| Citizen-Gated 2FC | High | High | High (behavior-based, not media-analysis) | Medium (WhatsApp/SMS + new state) | Ship first |
| Mandatory Re-routing | High | High | High (workflow change, not new tech) | Medium (cross-agency buy-in) | Ship first, alongside 2FC |
| Reopen Penalty Index → Swachh Survekshan | High (national) | Very high (closes the macro loop) | Low-medium (needs MoHUA/QCI adoption) | High (methodology-level) | Propose in parallel; don't block roadmap |

---

## 9. Recommendation Summary

Swachhata-MoHUA's core flow is sound, and works when local accountability exists. Its actual failure is narrower than "the app is broken": it grants trust (a "Resolved" status) without verifying it's earned, and its one appeal mechanism is timed against the wrong event.

The fix isn't importing a gig-economy rating system wholesale — government sanitation workers are salaried, not gig workers, so the market pressure that makes Uber's loop self-enforcing doesn't exist here. The recommendation is to manufacture that consequence loop deliberately: move verification authority to the citizen via 2FC, pair it with Mandatory Re-routing so jurisdiction mismatches stop being misclassified as accountability failures, and propose a Reopen Penalty Index into Swachh Survekshan as a separate policy lever — product ships the first two, policy advocates for the third, and each fix's own gaming risk (silent non-response, agency ping-pong, data exposure) has a named mitigation rather than being left open.

---

## SwiftUI Prototype

The `SwiftUI-Prototype/` folder contains lightweight, drop-in-ready SwiftUI components for the 2FC (Citizen-Gated Two-Factor Closing) flow proposed above:

- **`ComplaintStatus.swift`** — the state model, including the new `pendingVerification` and `escalated` states that replace the old binary Resolved/Rejected.
- **`PendingVerificationView.swift`** — the citizen-facing confirm/reject screen with a live 48-hour countdown.
- **`PhoneMasking.swift`** — the Ola/Uber-style number-masking utility for the citizen-data-exposure mitigation.
- **`OfflineConfirmationHandler.swift`** + **`NetworkMonitor.swift`** — a Swift Concurrency queue that records a citizen's confirm/reject decision immediately and retries with backoff once connectivity returns.

---

## Methodology & Sources

Public data from Google Play Store and Apple App Store listings/reviews for Swachhata-MoHUA (Oct–Nov 2025), AppBrain aggregator data, Swachh Survekshan program documentation (MoHUA), a Haryana state incentive announcement (2023), and a published SocialCops case study on a 2012 Delhi ward pilot. Aggregator rating/download figures are approximate, not official platform-published numbers.
