# authoring-implementation-plans

A user skill that authors three vault-native implementation artifacts for a Jira issue — each serving a distinct audience.

## What it produces

| Document | Audience | Density | Updated |
|---|---|---|---|
| `design.md` | User + reviewers | Medium | Written once |
| `plan.md` | Claude (implementer) | Dense | Written once; amended on replans |
| `manifest.md` | User + Claude | Sparse | **Live** — status updated during implementation |

The **manifest** is the orientation artifact — a per-commit table (step / commit / why / status) that answers "where are we?" at a glance without reading the full plan. Both you and Claude read it first at the start of every implementation session.

The **plan** is Claude's working document — dense enough that implementation decisions are already made; pick up a commit, read the entry, build.

The **design** is the decision record — scope, constraints, invariants, and resolved questions that reviewers and future-you need without digging through commits.

## What it does

Takes a Jira issue from "understood" to "ready to build" through five phases:

1. **Research** — vault check via `memory-archivist`, Jira pull via `researching-jira-issues`, scope boundaries (what's in/out, sibling tickets, cross-team naming contracts, locked vs. open decisions)
2. **Exemplar grounding** — for each technical concern, finds the specific existing file to mirror, builds an exemplars table with `path:line` references
3. **Decision resolution → design.md** — resolves open design questions one at a time; captures deviations from prior art with rationale; documents ticket reconciliations; includes a Mermaid diagram when the work has a shape worth showing (flowchart, sequence, or ER diagram — skipped when it wouldn't add anything over prose); drafts `design.md`; **stage-gates on user approval** before proceeding to commit decomposition
4. **Commit decomposition → plan.md + manifest.md** — primitives-first ordering; each commit gets a Conventional Commit title, depends-on, file-level manifest, isolation rationale, and AC coverage; manifest gets step / commit / why / status with all statuses starting `pending`
5. **Vault write** — delegates all placement and frontmatter mechanics to `memory-archivist`; writes all three documents to the issue folder

## When to use it

- "Write an implementation plan for [issue]" 
- "Plan this out commit by commit"
- "Draft a commit plan for [issue]"
- "I'm ready to plan the implementation" (after a ticket has been researched and scoped)
- "Formalize the inline plan we did into the vault"

## Using the manifest during implementation

At the start of every implementation session:

1. Read `manifest.md` — find the `active` commit, or the first `pending` if none is active
2. Read the corresponding entry in `plan.md` for execution detail
3. After the commit lands, update `manifest.md`: set that commit to `done`, set the next to `active`

## How it relates to other planning artifacts

| Artifact | Lives in | Answers |
|---|---|---|
| **design.md** (this skill) | Memory vault | Scope, decisions, invariants for one ticket |
| **plan.md** (this skill) | Memory vault | How to build one ticket, in what order, verified how |
| **manifest.md** (this skill) | Memory vault | Where we are right now — live orientation table |

## Dependencies

- `memory-archivist` — vault research and write
- `researching-jira-issues` — Jira issue research
- `Explore` agent — codebase exemplar grounding
