---
name: turning-ideas-into-projects
description: Use when a vague product idea must be clarified and governed across multiple phases before development, especially when necessity, project placement, long-running execution, or goal drift is uncertain. Do not use for one-step tasks or an already-approved narrow implementation.
---

# Turning Ideas into Products

## Core contract

This is the user's personal orchestration Skill. It is not part of any product and must not assume a domain, repository, taskboard, role system, or directory from a prior example. Project facts from memory or another conversation are unverified hypotheses unless the user names that project in this run and the facts are re-checked within the authorized scope.

Use this spine in order:

1. **REQUIRED SUB-SKILL:** complete `superpowers:brainstorming` to clarify the problem, user, value, alternatives, necessity, product shape, and placement. For its Architectural path, obey `superpowers:writing-plans` as the immediate post-brainstorming handoff; treat that plan and its execution-choice response as inputs to governance, not as authority to execute immediately.
2. **REQUIRED SUB-SKILL:** in Plugin mode use exactly `mingkon-idea-to-project:leader`; in standalone authoring mode use the separately installed `leader` resolved by the dependency gate. Freeze only the approved next phase as one Agent contract.
3. Start one native `/goal` from that contract and let it run to a verifiable stop.
4. Return to `leader` in a fresh reviewer context to re-run acceptance and decide pass, fail, or blocked.

Do not substitute an improvised workflow for these handoffs. Planning with files supports the spine; it does not replace it.

## Dependency gate

Before substantive work, verify that `superpowers:brainstorming`, its required `superpowers:writing-plans` handoff, a valid leader, and the host's native goal creation/status-readback mechanism (`/goal` or equivalent tools) are available.

- When this Skill is loaded from the `mingkon-idea-to-project` plugin or invoked with its plugin-qualified name, require `mingkon-idea-to-project:leader`; it must not use a generic `leader` installation to satisfy the bundled dependency gate.
- In plugin-qualified execution, it must not invoke package-external optional skills. This includes `elements-of-style:writing-clearly-and-concisely`, which upstream brainstorming marks as optional; perform the same clarity review directly so the qualified workflow remains self-contained.
- In standalone authoring mode only, a separately installed `leader` may be used. In the rest of this Skill, `leader` means the form resolved by this rule.

- If `leader` is unavailable, report the missing dependency and stop before contract authoring.
- If goal execution is unavailable, finish a copy-ready contract and label it `proposed_not_started`; never imply that a goal is running.
- A proposed task, Markdown plan, or chat message is not a live goal. Record a goal identifier and status only after creation and readback.

## Lifecycle

### 1. Discover and approve

Run `superpowers:brainstorming` fully. Separate facts, inferences, risks, and unknowns. Test whether the idea is necessary and preserve `GO`, `PIVOT`, `HOLD`, and `STOP` as valid outcomes. Do read-only research before asking discoverable questions.

For an Architectural outcome, complete brainstorming's required design document, user review, and `superpowers:writing-plans` handoff before leaving this stage. Save that plan in the approved initiative workspace. At writing-plans' Execution Handoff, offer its required two execution choices. After the user responds, record the selected option as contract input and state that the matching bundled execution Skill may run only later, inside the native goal and within the leader contract. Then return to this orchestration Skill; `leader` contracts only the approved current phase before anything executes. Planning with files supports the four-stage spine; it does not replace `leader`, start a goal, or authorize implementation.

For `STOP` or `HOLD`, record the evidence and reopening condition; create no development goal. For `GO` or an approved `PIVOT`, obtain explicit approval of the product direction, non-goals, and next evidence gate.

### 2. Persist the approved product plan

After approval, read [references/project-pack.md](references/project-pack.md) and establish the smallest governance pack in an explicitly approved initiative workspace. The Skill installation folder is never that workspace.

Create a conditional near/mid/long roadmap. Near term is the next evidence-producing outcome; mid term depends on near-term proof; long term remains an option until its gate is met. Materialize only the approved next phase into active tasks.

Decide product/repository placement separately. Candidate projects must come from the current request or an explicitly approved search root; do not search unrelated drives or inject remembered products. Inspect candidates read-only and recommend `research_only`, `existing_product`, `neutral_incubation`, or `new_project`. Do not modify a target repository or board before that placement is approved.

### 3. Freeze one contract with `leader`

Load `leader` and supply the approved compass, roadmap phase, verified environment facts, target placement, allowed files, and acceptance owner. Ask it for one bounded contract for the current phase—not the whole roadmap. Save the accepted contract under `contracts/` and record its version in the registry.

If the contract changes product value, target user, placement, scope, or acceptance, route back through brainstorming approval. Implementation-detail corrections within the approved boundary may be re-contracted by `leader` without reopening product strategy.

### 4. Start and govern `/goal`

Start the native `/goal` only when the contract names one objective, one stopping condition, validation evidence, allowed scope, and stop/escalation rules. Point the goal to the governance files and contract instead of restating the entire roadmap.

For a phase that needs external research, more than one model/role, long-running child work, or implementation-independent review, conditionally load `mingkon-idea-to-project:orchestrating-multi-model-work` after this leader contract is approved. It coordinates only versioned child receipts for the frozen phase. This Skill remains the unique lifecycle owner: it alone decides discovery, GO/PIVOT/HOLD/STOP, placement, contract changes, native goal creation, central governance writes, acceptance routing, and user-facing escalation.

Immediately before loading that child, send the user one adoption notice containing the reason, active contract version, proposed default role-to-model route, observed capability gaps, and this explicit choice: the user may specify, replace, or disable a model. This is a notice and choice point, not a repeated permission gate; if the user does not request a change, continue with the valid defaults. A user selection overrides a default only when the capability is observed and the frozen contract still preserves its evidence and independence gates. Otherwise explain the conflict and return to `leader` to re-freeze the affected contract boundary. Never silently substitute an unavailable model or remove a model-specific independent review.

During execution, the coordinator owns central governance files. Child tasks may write only their assigned artifacts and handoffs. Before dispatch, resume, scope change, taskboard write, or completion claim, compare the action to the current compass and contract. If it cannot cite the current goal and approved phase, pause it as drift.

### 5. Return to `leader` for re-verification

When the goal stops, do not accept its self-report. Start a fresh reviewer task that did not implement the work, load `leader`, the frozen contract, diff/artifacts, progress log, and raw validation evidence. Re-run visible checks and `leader`'s independent spot checks. Record `verified_pass`, `verified_fail`, or `blocked`; keep user acceptance separate.

- On `verified_fail`, use `leader` to contract only the failed scope and run a new bounded goal.
- If evidence invalidates the product premise or roadmap gate, return to brainstorming.
- Update the roadmap from verified results, not from activity or code presence.

## Handoff receipt

At every stage boundary, the coordinator writes the receipt to `PROGRESS.md` and reports: current stage and decision; files changed; live goal/task IDs if any; verification evidence; next owner and action; unresolved risks. Never claim the full product complete unless independent verification passed and the user explicitly accepted it.

## Common mistakes

| Mistake | Correct response |
|---|---|
| Naming or placing the product from a familiar example | Keep placement unassigned until candidate inspection and approval |
| Treating remembered project facts as current evidence | Mark them unverified; use them only after current-run scoped verification |
| One `/goal` for research, roadmap, development, and scale | Contract only the approved current phase |
| Turning mid/long horizons into a backlog now | Keep them gated outcomes |
| Letting implementers update central decisions or accept themselves | Coordinator owns decisions; fresh reviewer verifies |
| Treating a plan as an active goal | Require live creation and status readback |
