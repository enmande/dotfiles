---
name: authoring-implementation-plans
description: >
  Author three vault-native implementation artifacts for a work item/issue — design.md (scope and
  decisions), plan.md (commit-level execution detail), and manifest.md (per-commit orientation
  table with live status). Researches the issue and codebase, resolves open design decisions
  with the user, gates on user approval of design.md before commit decomposition, then produces
  a Conventional-Commit-decomposed plan with exemplar grounding and per-commit AC mapping.
  Use when the user asks to "write an implementation plan", "plan this out commit by commit",
  "create a plan for [issue]" or says they're ready to
  plan execution after scoping a ticket. Also use when a prior inline plan needs to be
  formalized into the memory vault, or when a locked decision changes mid-implementation and
  the plan needs to be amended.
argument-hint: "[<issue-key>]"
arguments: issue
allowed-tools: >
  Skill(memory-archivist), Skill(researching-jira-issues), Agent(Explore),
  AskUserQuestion, Read, Edit, Write, Glob, Grep,
  Bash(git log:*), Bash(git show:*), Bash(grep:*), Bash(find:*),
  mcp__plugin_bitwarden-atlassian-tools_bitwarden-atlassian__get_issue,
  mcp__plugin_bitwarden-atlassian-tools_bitwarden-atlassian__get_issue_comments,
  mcp__plugin_bitwarden-atlassian-tools_bitwarden-atlassian__get_issue_remote_links,
  mcp__plugin_bitwarden-atlassian-tools_bitwarden-atlassian__search_issues,
  mcp__plugin_bitwarden-atlassian-tools_bitwarden-atlassian__get_confluence_page,
  mcp__plugin_bitwarden-atlassian-tools_bitwarden-atlassian__search_confluence
---

# Authoring Implementation Plans

## Overview

Help an engineer produce **three vault-native implementation artifacts** for a specific work item/issue:

| Document | Audience | Density | Updated |
|---|---|---|---|
| `design.md` | User + reviewers | Medium | Written once |
| `plan.md` | Claude (implementer) | Dense | Written once; amended on replans |
| `manifest.md` | User + Claude | Sparse | **Live** — status updated during implementation |

The **manifest** is the orientation artifact. On every session start during implementation, read `manifest.md` first to determine where things stand, which commit is active, and what comes next. It is the answer to "where are we?" without reading 500 lines of plan detail.

The **plan** is Claude's working document during implementation — dense enough that the implementation decisions are already made; pick up a commit, read the plan entry, and build.

The **design** is the decision record — scope, constraints, invariants, and resolved questions that reviewers and future-you need without digging through commits.

Work through five phases before writing any vault documents. A stage-gate at the end of Phase 3 confirms scope and decisions with the user before commit decomposition begins — this is where expensive misalignments get caught.

---

## Phase 1 — Research

The goal is to arrive at a precise scope statement before looking at any code.

1. **Check the memory vault first.** Invoke `memory-archivist` to surface any prior investigation
   notes, open questions, or decisions already captured for this issue. This avoids re-deriving
   work that's already been done.

2. **Understand the ticket.** If `$issue` was provided, use available tools to research. 
   Aggregate the requirements, acceptance criteria, linked parent/sibling/child tickets, 
   and any referenced design material. If an issue identifier is not provided, use 
   `AskUserQuestion` to understand the scope of work.

3. **Scope the boundaries.** Identify explicitly:
   - What is in scope for this ticket (vs. deferred to sibling tickets)
   - Which sibling or downstream tickets depend on artifacts this ticket produces
   - Any cross-team API/naming contracts that must be byte-for-byte consistent
   - Whether any decisions are already locked (by the assignee, by the ticket, by a prior session)
     vs. still open

Surface ambiguities using `AskUserQuestion` — do not silently pick the path of least resistance. COMPLETE THE CHAIN with an eye for existing contradictions within and across artifacts.

---

## Phase 2 — Exemplar Grounding

The goal is to find the specific files to mirror, not just the patterns to follow.

For each distinct technical concern in the plan (a new entity type, a DI registration, a mail
template, a controller action, a test pattern — whatever the ticket requires), use `Agent(Explore)`
to locate the best existing exemplar in the codebase:

- "What's the closest existing implementation of this shape?"
- Prefer exemplars that are complete, recent, and in the same subsystem
- ALWAYS use `AskUserQuestion` as a stage-gate: is this the _correct_ exemplar to anchor on, or just the current signal? Objectively explain why it is the signal. Be prepared to chat about reasoning: the initial anchor may be incorrect, or existing exemplars may miss the mark slightly; user will help refine.

Build an **exemplars table** as you go (this lands in `plan.md`):

| Concern | Exemplar class / function | Path:line | Reasoning (one sentence) |
|---------|---------------------------|-----------|--------------------------|

Also surface any cross-team naming contracts (shared query params, DTO field names, event names,
API paths) that sibling tickets' authors need to match. These are coordination risk — a
byte-for-byte mismatch is a silent failure.

---

## Phase 3 — Decision Resolution → `design.md`

The goal is to enter Phase 4 with zero open design questions, and to produce a `design.md` the
user can approve before commit decomposition begins.

For each open question surfaced in Phases 1–2:

1. Check whether prior art in the codebase (or in the memory vault) already answers it
2. If not, or if codebase and memory vault conflict, surface it to the user via `AskUserQuestion` — one decision at a time, not a list dump
3. Record the resolution and the rationale, especially when the decision **knowingly deviates from
   prior art** (reviewers will otherwise "correct" it back)

Also capture **ticket reconciliations**: places where the ticket's stated file list, class names,
or patterns are stale or inconsistent with what the current codebase actually looks like.

When all decisions are resolved, **draft `design.md`** and present it to the user as a file they can open and read/respond to inline. NEVER proceed to Phase 4 until the user approves.

### design.md — include whichever sections the ticket warrants

| Section | When to include |
|---|---|
| Context & scope | Always — scope statement, epic/parent, what is NOT touched, gating/rollout mechanism |
| Visual representation | When the work has a shape a diagram makes obvious — see below |
| Critical invariants | When there are non-obvious constraints that must survive future refactors. Flag prominently — never buried in body text. |
| Locked decisions | When design questions were resolved — include rationale, especially deviations from prior art. When a previously locked decision is later revised, update this entry in place with the new rationale — don't layer a history of the change. |
| Ticket reconciliations | When the ticket's stated files/patterns differ from the current codebase |
| Additive-modify surface | The explicit list of existing files this plan touches (helps reviewers assess blast radius) |
| Deferred / handoffs / open items | When things are explicitly out of scope with a disposition |

#### Visual representation

Some work has a shape that's faster to check by eye than by reading prose — a feature that moves
through distinct states, a bugfix with several interacting pieces, an interaction across
components where order matters. When that shape exists, include a Mermaid diagram: it lets the
user confirm the shape in your head matches the shape in the ticket before committing to it.

- **Flowchart** (`flowchart`) — branching logic, a state machine, a decision process
- **Sequence diagram** (`sequenceDiagram`) — an interaction across multiple components/services
  where order and directionality matter
- **Entity-relationship diagram** (`erDiagram`) — a feature or bugfix touching several related
  entities/tables where the relationships are the source of confusion

This section is optional, not a checklist item to force. Skip it when the work is a single
straight-through path or one entity — a diagram that just redraws a linear list in boxes adds a
layer to decode instead of grounding the reader. Include it only when it would save the user a
sentence of "wait, how do these pieces connect?"

---

## Phase 4 — Commit Decomposition → `plan.md` + `manifest.md`

The goal is a sequence of commits that each compile on top of the previous, decomposed to the
atomic unit of "one logical change, one commit."

**Ordering heuristic:** primitives first, consuming code in the middle, UI/integration
last. Within that, dependency order — if Commit B needs a type declared in Commit A, A comes
first.

### plan.md contents

**Grounded exemplars** — the exemplars table from Phase 2, at the top for fast lookup.

**Commit sequence** — for each commit:

- **Conventional Commit title:** `type(scope): subject` — subject ≤ 72 chars.
  `type` from the standard set (`feat`, `fix`, `refactor`, `test`, `chore`, etc.) per the
  `labeling-changes` skill; `scope` is the primary area touched.
- **Depends on:** list prior commits this one requires to compile (or "none")
- **Modify / New:** file-level manifest — list each file with specific changes described.
  "Modify `Foo.cs` — add method `Bar()`" is useful; "update the service" is not.
- **Why isolated:** one sentence on why this is its own commit rather than part of the previous
  or next one
- **AC covered:** which acceptance criteria from the ticket this commit satisfies

**Verification** — at the end of `plan.md`, three named sub-sections:

- **Build + test commands:** exact commands to run locally (build, lint, unit/integration tests).
- **Keystone tests:** specific named tests that cover the critical path — name them explicitly, not "run tests."
- **Manual testing plan:** the local test cases to exercise before opening the PR. Write these
  during planning, not after implementation.

  **Posture:** mostly happy path. QA owns rigorous testing. The goal is to prove the work — not to
  reproduce the test plan QA will run. Cover the primary user-facing or API-facing outcomes; add
  edge cases for seams and identified catch-outs; articulated sharp edges MUST be verified.

  For each test case, capture:
  - **Precondition** — feature flag state, test account, required data setup
  - **Steps** — what to do
  - **Expected outcome** — what success looks like

  **Screen recording:** capture a screen recording during manual verification and attach it to the
  PR before requesting review. This is the default. Omit only when there is genuinely nothing
  interactive or visual to exercise (e.g., a pure data-layer change with no observable UI or API
  side effect) — and state that reason explicitly in the plan. Cases where a recording is not
  applicable are the exception, not the rule.

### manifest.md contents

A lightweight orientation table — one row per commit, derived from the commit sequence.

```markdown
# <issue identifier> — <short description>

| Step | Commit | Why | Status |
|------|--------|-----|--------|
| 01 | `feat(auth): add device-trust claim to access token` | Establishes the token field all downstream consumers depend on | `pending` |
| 02 | ... | ... | `pending` |
| 03 | *(no commit) — manual verification + screen recording* | Prove the work locally and capture evidence before requesting review | `pending` |
```

- **Step** — sequential number, zero-padded (`01`, `02`, ...)
- **Commit** — the full Conventional Commit title from `plan.md`; for the final verification row,
  use `*(no commit) — manual verification + screen recording*`
- **Why** — one sentence: why this step exists, why it's isolated at this boundary.
  Structural, not historical — if the reason changes, rewrite the cell; never append a
  change history.
- **Status** — `pending` / `active` / `done`

All steps start `pending`. During implementation, the active step is `active`; completed steps are
`done`. **The manifest is a live document** — update it as commits land and as the verification step completes.

**Always add a final manual verification row** when building the manifest in Phase 4. It is the
last step before the PR opens. Do not omit it even when the screen recording will be waived — the
step still exists; only the recording artifact changes.

**Stop and ask** before writing if you discover mid-decomposition that a design question remains
unresolved or a contradiction has surfaced. A plan with a TBD is worse than a paused plan — it gives false confidence.

---

## Phase 5 — Write to Vault

Hand off all vault mechanics to `memory-archivist`. Provide it with:
- The issue key and a short description (for naming, if a new folder is needed)
- All three documents: `design.md`, `plan.md`, `manifest.md`
- The intent: write these as vault-native documents for this issue

Memory-archivist owns folder lookup, lifecycle awareness, naming convention, frontmatter schema,
and the duplicate check. If it reports existing plan documents, do not create duplicates —
surface what exists to the user and ask whether to update or leave them.

**Write order:** Memory-archivist writes`design.md` first, then `plan.md`, then `manifest.md`. If the write is interrupted, the most durable artifacts land first. Verify its work.

---

## Using the Manifest During Implementation

The manifest is the session orientation artifact. At the start of every implementation session:

1. Read `manifest.md` — find the `active` commit, or the first `pending` if none is active
2. Verify against log/code state that manifest is accurate -- surface to user if drift is identified.
3. Read the corresponding entry in `plan.md` for execution detail
4. After the commit lands, update `manifest.md`: set that commit to `done`, set the next to `active`

This keeps both you and the user oriented without re-reading the full plan.

---

## Replanning Mid-Implementation

Triggered when a locked decision changes or the commit sequence needs restructuring —
not by a routine status tick (those stay direct, per "Using the Manifest" above).

1. Resolve the new decision with the same `AskUserQuestion` discipline as Phase 3
2. Update the affected `design.md` Locked Decisions entry in place with the new rationale
   — don't add a second entry layering old-then-new
3. Rewrite the affected `plan.md` commit entries to the new state only
4. Hand the revised `design.md` and `plan.md` to `memory-archivist` to write the amendment
   in place — it applies the current-state-only discipline and validates frontmatter/
   wikilinks on the way in
5. Regenerate the affected `manifest.md` rows to match — this also goes through
   `memory-archivist` as part of the same amendment, even though routine status ticks
   don't

---

## Distinguishing these artifacts from other planning documents

| Artifact | Lives in | Answers |
|---|---|---|
| **design.md** (this skill) | Memory vault | Scope, decisions, invariants for one ticket |
| **plan.md** (this skill) | Memory vault | How to build one ticket, in what order, verified how |
| **manifest.md** (this skill) | Memory vault | Where we are right now — live orientation table |
| Inline plan | Conversation window (ephemeral) | Nothing — use this skill to persist it |

---

## Guardrails

- **Never write to the vault until Phases 1–3 are complete.** A plan authored before decisions
  are resolved contains stale assumptions that look like decisions.
- **Never proceed to Phase 4 without user approval of design.md.** The stage-gate catches scope
  and decision misalignments before commit decomposition begins — fixing them after is expensive.
- **Never leave a TBD in the plan.** Surface the open question, resolve it, then write.
- **Never assume a specific tech stack.** The issue determines the relevant languages, frameworks,
  and layers. Read the ticket and explore the codebase; don't assume.
- **Never treat file names in the ticket as authoritative.** Tickets drift. Verify every
  referenced file exists and the stated pattern is still how the codebase does things.
- **Never let the manifest go stale during implementation.** If a commit lands without a status
  update, the manifest loses its value as an orientation artifact.
- **Never open a PR without completing the manual test plan.** Execute every test case in
  `plan.md`'s manual testing plan, capture a screen recording, and attach it to the PR before
  requesting review. Waive the recording only when there is genuinely nothing interactive or
  visual to exercise — state that reason explicitly in the plan. Silent omission is not acceptable.
- **Never narrate a replan inside `plan.md` or `manifest.md`.** When a commit sequence or
  step changes, rewrite the affected entries to describe the new state only. If the
  change is worth recording (per CLAUDE.md's rationale test), put it in `design.md` —
  Locked Decisions for a changed decision, Ticket Reconciliations for a corrected ticket
  claim — never in `plan.md` or `manifest.md`; otherwise omit it. `plan.md`'s "Why
  isolated" and `manifest.md`'s "Why" column stay structural (why the boundary exists
  now), never a record of how it got there.
