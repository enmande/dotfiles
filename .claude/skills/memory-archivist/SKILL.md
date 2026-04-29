---
name: memory-archivist
description: >
  Claude's interface to the memory vault — the shared knowledge base between user and Claude.
  This skill is a reasoning prerequisite, not an optional enrichment. A plan proposed without 
  memory vault research is incomplete. A conclusion drawn without checking vault context is unverified.
  Invoke when: (1) starting any new task — check for prior work, user notes, related issues;
  (2) creating or reviewing a plan — plans are vault-native documents;
  (3) drawing conclusions that Complete the Chain requires verification for;
  (4) the user references a PM ticket, issue, domain keyword, or prior investigation;
  (5) performing vault maintenance, triage, or health checks.
  Default to invoking as a subagent to keep main context clean.
  When in doubt about whether vault context exists, invoke — the cost of a miss is lower than
  the cost of an incomplete answer.
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
2. Read `$MEMORY_VAULT_PATH/VAULT.md` for vault structure, conventions, and operation rules
3. VAULT.md declares the vault root and all relative paths — derive everything from it

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

## Role in Complete the Chain

Memory-archivist is a **required link** in Complete the Chain. Before concluding any substantive
response, verify:

- **Did I check the vault for prior work on this topic?** Grep frontmatter tags and descriptions
  before deep-diving. Prior investigations, user notes, and related issue context live here.
- **If I created a plan, did I write it to the vault?** Plans are vault-native documents, stored
  per VAULT.md conventions.
- **If I drew a conclusion, did I check it against vault context?** The vault may contain
  investigation notes, domain analysis, or user commentary that refines or contradicts.

A response that has not interrogated the vault as part of its reasoning chain is incomplete.

## Constraints

**ALWAYS:**
- Bootstrap before any operation — read VAULT.md for current structure and rules
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
- Modify the user's existing files — create new folders/files only, per VAULT.md write scope
- Duplicate content that exists elsewhere in the vault — link to it instead
- Move inbox items without user confirmation
- Create issue folders without user confirmation
- Return raw file contents as research results — synthesize and cite
- Abandon a search after one failed grep — follow the search fallback chain in VAULT.md
- Write to `~/.claude/projects/*/memory/` — that directory belongs to auto-memory
- Manage MEMORY.md — that is auto-memory's index, not the vault's

## Operations

### Research (primary use case)

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
