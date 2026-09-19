---
name: memory-archivist
description: >
  Claude's interface to the memory vault — the shared knowledge base between user and Claude.
  Invoke when the user explicitly asks to check, search, or recall something from the vault
  (e.g. "check the vault", "what do we know about X", "have we looked at this before"), or when
  producing a vault-native artifact that must be written there: implementation plans (including
  those from Skill(authoring-implementation-plans)), investigation notes, triage, or health checks.
  Do not invoke this proactively at the start of a task, on every conclusion, or just because a
  ticket was mentioned — searching the vault "just in case" is a context-cleanliness cost paid
  whether or not it was needed. Default to invoking as a subagent to keep main context clean.
user-invocable: true
disable-model-invocation: false
allowed-tools:
  - Read
  - Edit
  - Write
  - Glob
  - Grep
  - Bash
---

# Memory Archivist

The memory vault is a shared workspace between the user and Claude. Memory-archivist is the
bridge — it reads the vault to ground Claude's reasoning, and writes to the vault to persist
plans, findings, and commentary for the user.

Research first. Write aggressively. The vault is the global knowledge base that crosses project
boundaries — auto-memory is project-local, the vault is universal.

## Bootstrap

On every invocation:
1. Resolve the vault path from `$MEMORY_VAULT_PATH`

As needed (wayfinding):
1. Read `$MEMORY_VAULT_PATH/VAULT.md` for vault structure, conventions, and operation rules

The vault owns its schema, its directory layout, and its operation implementations. This skill
defines operation contracts and behavioral constraints only. 
**Do not assume vault structure — read VAULT.md and follow what it says.**

If `$MEMORY_VAULT_PATH` is unset, surface this to the user immediately — the vault cannot be
reached without it.

If VAULT.md is not found, surface this to the user immediately — the vault cannot be
reliably navigated without it. Include a pointer: "VAULT.md is the self-describing
meta-document that defines your vault's structure, write scopes, and conventions. See an
existing vault's VAULT.md for the expected format, or create one with sections: Vault Root,
Write Scope, Frontmatter Schemas, and Health Check Invariants."

## When This Skill Runs

Two triggers, and only two:

- **The user asks.** They want something recalled, checked, or cross-referenced against the
  vault — "what does the vault say about X", "have we run into this before", etc.
- **A vault-native artifact is being produced.** Plans (including ones from
  `Skill(authoring-implementation-plans)`), investigation notes, triage batches, and health-check
  reports belong in the vault, not a local file or scratch context. Writing them is a property
  of the artifact, not something gated on being asked.

Do not invoke this skill preemptively "just in case" — at the start of a task, on every
conclusion, or because a ticket was mentioned in passing. Eager vault probing pays a context
cost on every invocation regardless of whether that task ever needed vault content. If a
conclusion needs verification against vault context, that happens when the user points at the
vault as relevant, not automatically.

## Constraints

**ALWAYS:**
- Start research with frontmatter grep (cheap) before reading full files (expensive)
- Use the tag taxonomy for wayfinding — intersect domain + platform + sprint for precise matches
- Follow wikilinks one level deep from matched notes
- Validate that wikilinks resolve to real files before writing them
- Propose triage after writing to inbox — state where it should land and why
- Enforce vault frontmatter schema on vault-native documents (per VAULT.md)
- Prompt user to triage inbox items older than 7 days — on every invocation
- Write aggressively — plans, investigation notes, commentary, analysis all belong in the vault
- Derive all paths, directory names, and conventions from VAULT.md — never from the skill

**NEVER:**
- Hardcode vault structure or paths — always derive from VAULT.md
- Modify files outside write-scoped directories (defined in VAULT.md)
- Exceed the operation a directory's write-scope tier permits (per VAULT.md's Write Scope
  table) — full control permits create/read/update/move, limited write permits only
  create/move/frontmatter, read-only permits none of those
- Narrate an edit inside an amended document — rewrite affected sections to current
  state; rationale for a changed decision goes in `design.md` (Locked Decisions or Ticket
  Reconciliations, as fitting), never layered into the section being amended
- Duplicate content that exists elsewhere in the vault — link to it instead
- Move inbox items without user confirmation
- Create issue folders without user confirmation
- Return raw file contents as research results — synthesize and cite
- Abandon a search after one failed grep — follow the search fallback chain in VAULT.md
- Write to `~/.claude/projects/*/memory/` — that directory belongs to auto-memory
- Manage MEMORY.md — that is auto-memory's index, not the vault's

## Operations

### Research (on explicit request)

Search, synthesize, return a concise, chain-complete answer — not raw files. Follow VAULT.md > Search Procedure.
Stop when results are sufficient. If exhausted, report what was searched and ask user for direction.

**Return format:** Lead with a direct answer. Cite as `file:line` or wikilinks. Summarize —
don't quote blocks. Under 40 lines. If the topic is large, list relevant files with one-line
summaries.

### Writing Plans

Plans are vault-native documents. One plan, one canonical location.

1. Determine the target location per VAULT.md > Saving Plans
2. If the target folder doesn't exist, propose creation (user confirms)
3. Write the plan with vault frontmatter (per VAULT.md schemas)
4. Include: commit structure, key files, architectural decisions, stakeholder constraints
5. Validate wikilinks resolve to real files

Plans MUST be written to the vault immediately after creation and confirmation with the user. Do not defer.

### Amending Vault Documents

For deliberate revisions to an existing vault-native document — a replan restructuring
`plan.md`, a locked decision changing in `design.md` — not routine status ticks (those
stay direct, per `authoring-implementation-plans`'s "Using the Manifest During
Implementation").

1. Locate the existing document via the issue folder — never create a duplicate
2. Rewrite the affected sections to describe the current state only — no layered change
   history
3. If the revision is worth recording (per CLAUDE.md's rationale test), record it in
   `design.md` — Locked Decisions for a changed decision, Ticket Reconciliations for a
   corrected ticket claim. Otherwise omit it rather than inlining it elsewhere.
4. Validate wikilinks and frontmatter remain intact after the edit
5. Confirm with the user before writing if the amendment changes previously-approved scope

### Writing Investigation Notes

Findings, analysis, commentary, domain breakdowns — anything that future conversations should
be able to find. Write to the vault's staging area (per VAULT.md) with proper frontmatter,
then propose triage destination.

### Inbox Triage (`/memory-archivist triage`)

Review all staged documents. Classify each per VAULT.md > Triage Dispositions. Present a table
of all items with proposed destinations. User reviews and approves each disposition before any
files are moved.

### Issue Lifecycle

Manage issue folder transitions through the vault's lifecycle directories (per VAULT.md).
When moving an issue folder, check for any vault-native documents that reference it and update
links if needed.

### Health Check (`/memory-archivist check`)

Two-tier validation, run in order:

**Tier 0 — VAULT.md structural validation.** Validate that VAULT.md itself is well-formed and
that the vault it describes actually exists on disk. Checks: required sections present, declared
directories exist, write-scoped directories exist, frontmatter schemas parse. Details and
specific checks are defined in VAULT.md > Health Check Invariants.

When a Tier 0 check fails, offer to fix it (user confirms before any action):
- Missing write-scoped directory → offer to `mkdir`
- Missing non-write-scoped directory → flag only (outside write scope, don't create)
- Missing VAULT.md section → show a template snippet the user can paste

Tier 0 failures don't block Tier 1, but resolve them first — structural issues cause false
positives in content checks.

**Tier 1 — vault content validation.** Validate vault contents per the remaining invariants in
VAULT.md > Health Check Invariants (frontmatter, wikilinks, inbox health, issue lifecycle).

Report results with specific findings and suggested fixes.

## Output

| Operation | Format |
|-----------|--------|
| Research | Concise answer (<40 lines) with `file:line` citations |
| Plan/note creation | Confirmation with file path and triage proposal |
| Triage | Table of all items with proposed dispositions |
| Health check | Validation results with specific findings and suggested fixes |
