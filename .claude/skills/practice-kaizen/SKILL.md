---
name: practice-kaizen
description: >
  Disposition an improvement opportunity noticed mid-task — run the two-condition test (is the
  triad complete, does it change how the current task executes), then either execute it inline or
  stage it as a `type: feedback` note in the memory vault inbox for later triage. Includes the
  "belling the cat" classification: would an engineer pick this up and drive it on their own
  initiative? Invoke the moment an opportunity surfaces — a skill gap, missing agent type,
  workflow opportunity, tooling friction, or process observation — not batched at session end.
  This is the disposition procedure Claude's "Practice kaizen" standing rule points to; the
  noticing itself stays a continuous background instinct that this skill cannot trigger on its
  own.
user-invocable: true
disable-model-invocation: false
allowed-tools:
  - Read
  - Grep
  - Glob
  - AskUserQuestion
  - Skill(memory-archivist)
---

# Practice Kaizen

## Overview

Kaizen means small, continuous improvement surfaced *during* work, not batched at the end of a
session. This skill is the disposition procedure for an opportunity once noticed — it does not
replace the noticing itself, which stays a standing instinct applied across every task (see
CLAUDE.md's "Practice kaizen" rule). Invoke this the moment something worth logging surfaces: a
skill gap, a missing agent type, a workflow opportunity, recurring tooling friction, or any process
observation that would help future work — including observations about the delegation layer
itself, not just implementation-level findings.

## Step 1 — Run the two-condition test

1. **Is the full triad present?** Opportunity + concrete improvement + a viable implementation
   path. A vague "this could be better" is not yet a kaizen item — if the triad isn't complete,
   don't force a half-formed observation into a note; revisit later if it resolves into one.
2. **Would acting on it change how the *current* task executes?** Not "is this a good idea in
   general" — specifically, does fixing it now unblock or improve the task in front of you?

## Step 2 — Branch on the result

| Triad complete? | Changes current task? | Disposition |
|---|---|---|
| Yes | Yes | Pause, evaluate, and either execute inline or stage to the memory vault inbox — notify the user either way, and say which you chose and why. |
| Yes | No | Stage to the memory vault inbox. A fully-specified improvement still does not interrupt execution just because it's ready — only relevance to the current task earns an inline pause. |
| No | — | Don't log it yet. An incomplete triad isn't an actionable kaizen item. |

## Step 3 — Write the note

Hand off the actual vault write to `memory-archivist` — this skill owns the decision logic, not
the vault mechanics. Frontmatter schema, inbox location, and naming convention are
`memory-archivist`'s to derive from VAULT.md, not this skill's to hardcode.

Every kaizen note MUST include:

- **Type:** `feedback` (per the vault's frontmatter schema) — never auto-memory, which is opaque
  to the user.
- **Belling-the-cat assessment:** would an engineer pick this up and drive it on their own
  initiative — not waiting to be assigned, willing to own whatever it takes, including navigating
  any external gates or requirements? This is a **classification**, not a gate — it describes what
  *kind* of kaizen item this is. It never determines whether to log it. Every item that passes
  Step 1 gets logged regardless of its belling-the-cat answer.

## Guardrails

- **Never batch kaizen for end-of-session.** The trigger is "on sight" — evaluate as soon as the
  opportunity surfaces, not as a retrospective pass.
- **Never let a fully-specified, task-relevant improvement sit unactioned without telling the
  user.** Silence is not a valid disposition — execute, stage, or ask; always notify.
- **Never use belling-the-cat status to suppress a note.** Low-initiative items still get logged;
  the field describes ownership shape, not priority or validity.
- **Never duplicate `memory-archivist`'s job.** This skill decides *whether* and *what*;
  `memory-archivist` decides *where* and *how* it's written.
- **Triage cadence is not this skill's job.** Once 3+ notes accumulate in the inbox, that's
  `memory-archivist`'s trigger to run triage (see CLAUDE.md > Feedback disposition) — this skill
  only handles the moment a single opportunity is noticed and staged.
