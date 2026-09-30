---
name: recommending-tests
description: >
  Investigate a class, file, or in-progress diff, and produce a structured, numbered list of
  recommended tests — both unit tests and integration tests. Does not write the tests itself.
  Use whenever the user asks "lock in current behavior with tests", "recommend tests for this",
  "review test coverage for X", "what should we test here", or wants a testing checklist before
  or after writing code, even if they do not name a specific class. Also use when a user finishes
  an in-progress change and asks what to cover before opening a PR. At the end, offers to hand
  the recommendation to a coding-capable agent that writes, runs, and verifies the tests.
user-invocable: true
disable-model-invocation: false
allowed-tools:
  - Read
  - Grep
  - Glob
  - Agent
  - AskUserQuestion
  - Bash(git status:*)
  - Bash(git diff:*)
---

# Recommending Tests

Investigate a target, then produce a numbered list of recommended tests, covering both the unit
level and the integration level. Do not write the tests yourself in this skill — only recommend
them. Offer, at the end, to hand the list to a coding agent for implementation.

A unit test isolates one method or one class, with its dependencies faked or mocked. An
integration test exercises the target through its real collaborators — a real database, a real
HTTP pipeline, a real cryptographic library, or another component the target wires into. Some
logic only fails at the integration level (wiring, configuration, a real library's actual
behavior); some logic is too slow or too indirect to verify well except in isolation. Recommend
both levels, and say which level each case belongs to and why.

## Step 1: Identify the target

- If the user names a file or class, locate it directly with Glob/Grep.
- If the user refers to "this change" or "what I just wrote," run `git status` and `git diff` to
  find the modified files.
- If neither is clear, ask the user which file or change to target. Do not guess.

## Step 2: Investigate before you recommend

Dispatch a fast, read-only search agent to gather the facts a test list depends on. Choose
whichever available agent type is built for targeted code search over a codebase — a description
that mentions search, exploration, or locating code is the marker — rather than a general-purpose
or code-writing agent. Investigation here needs speed and read-only access, not implementation.

Ask that agent to report back:

1. The exact file path, and the target's full source.
2. Constructor dependencies or injected interfaces. These are what a unit test must mock, and
   what an integration test exercises for real.
3. Every public method's signature, and every branching condition that drives a distinct test
   case: if/else, ternaries, guard clauses, loops, try/catch, null-conditional chains,
   short-circuit boolean logic.
4. How the target is wired into the rest of the system — its real caller(s), and any real
   infrastructure it touches directly or through a caller (a database, an HTTP context, a
   third-party library, another service). This is what determines which cases belong at the
   integration level.
5. Any existing test file, at either level, that already covers the target or its caller. Report
   a one-line summary of what each existing test covers, and whether it is a unit test or an
   integration test.

Do not skip item 5. A recommendation that duplicates existing coverage wastes the implementer's
time. State the gap instead of the case that is already covered.

## Step 3: Write the recommendation

Follow the format in `references/output-template.md` exactly — it is a real worked example, not
a generic shape. Read that file before you write the recommendation. Match it section for
section:

- One opening line that states, in a Verified/Sourced/Unverified style, whether dedicated unit
  and integration test files already exist for the target, and what coverage exists today at
  each level. Indirect coverage (through a caller's tests) still counts as coverage — state that
  it is indirect.
- `## Recommendation` — one short paragraph per level: where the new unit test file goes (or
  which file to extend), where the new or updated integration test file goes, and why, in one
  sentence each. Skip a level entirely, with a one-sentence reason, when the target has no
  meaningful case at that level (for example, a pure function with no real collaborator has
  nothing left for an integration test to add).
- `## Unit test cases by method` — one `###` heading per public method. Each test case is one
  numbered sentence, phrased as a requirement ("The method must ..." or "The method must not
  ...").
- `## Integration test cases by scenario` — one `###` heading per real scenario or code path
  through the wired-up system (not per method — integration tests verify behavior across
  components, so group by scenario: an end-to-end flow, a configuration setting, a real
  dependency's failure mode). Each case is one numbered sentence, phrased the same way.
- Number every case sequentially across both the unit and integration sections combined. Do not
  restart the count between sections or between headings.
- An optional closing section marked with ⚠️, for anything you could not verify cleanly — a
  dependency on a third-party library's internals, missing test infrastructure, or a fixture
  that needs real cryptographic material or a real database. Omit this section when nothing
  needs a flag.

Every test case must trace to a real branch, condition, or wiring point found in step 2. Do not
pad the list with generic cases ("test null input," "test the happy path") unless the code
actually branches on that condition. A generic case that does not trace to a line of code costs
the implementer more time to verify than it saves.

## Step 4: Offer to hand off implementation

After you show the list, ask the user whether to send it to an agent for implementation. This
step needs a live choice from the user, so run it yourself in the current conversation. Do not
delegate this step to a background agent — `AskUserQuestion` only works in the foreground.

1. Read the list of agent types available in the current session.
2. Filter the list to agents whose descriptions show they write or implement code, not a
   read-only search agent, a review-only agent, or a planning-only agent. Judge this from each
   agent's own description at runtime. Do not hardcode a specific agent name in this skill — the
   available agents differ by project and by session.
3. Present the filtered agents through `AskUserQuestion`, alongside an option for the user to
   implement the tests themselves.
4. If the user picks an agent, dispatch it with full context: the target file path, the complete
   recommended test list exactly as you wrote it (unit and integration cases both), pointers to
   existing test files or fixture patterns to reuse at each level, and an instruction to write
   the tests, run them, verify they pass, and report back concisely.

## What this skill must not do

- Do not write test code directly, even if the user asks you to skip the hand-off step and write
  the tests yourself. This skill's job ends at the recommendation and the hand-off; an
  implementation-capable agent, or the user, writes the code — not the session running this
  skill. If no implementation-capable agent exists in the session, say so plainly and let the
  user decide, rather than falling back to writing the tests yourself.
- Do not recommend a test case that does not trace to a branch, a condition, or a wiring point
  found in step 2.
- Do not recommend only unit tests, or only integration tests, without first checking whether the
  other level applies. State a one-sentence reason whenever you skip a level.
