---
name: orchestrating-multi-model-work
description: Use when an already-approved phase has a frozen contract and needs coordinated external research, model-specialized work, long-running child tasks, or independent technical review. Do not use to discover a product, change a phase, or execute a simple bounded task.
---

# Orchestrating Multi-model Work

Use this as a conditional child of `turning-ideas-into-projects`, never as a second project controller.

## Entry gate

Before any dispatch, require all of:

- an approved phase owned by the parent mainline;
- a frozen contract with an exact version, allowed writes, evidence commands, stop rules, and acceptance owner;
- observed host capability for each requested model/tool.
- a user-visible adoption notice that names this Skill, the reason and contract version, the proposed default model route, observed capability gaps, and the user's option to specify, replace, or disable a model.

If the notice is the only missing condition, send it before dispatch; it informs the user without asking them to re-approve an unchanged contract. If any other condition is absent, provide routing advice only. Do not create a project, native goal, governance file, external task, or acceptance conclusion. This Skill must not change product direction, placement, phase scope, contract, release permission, or user acceptance. It must not write central governance files; return a receipt to the parent instead.

## Mainline and model record

Register one mainline for the approved phase. Request Terra by default. If Terra is unavailable, select a host-available coordination model only within the contract and record the reason. Never report a requested model as actually running.

The role table contains defaults, not mandatory user choices. Before dispatch, apply an explicit user request to specify, replace, or disable a model when the requested capability is observed and the frozen contract's evidence and independence gates remain valid. If the request conflicts with either condition, report the exact conflict and return it to the parent for re-contracting; do not silently ignore the request, substitute another model, weaken a required independent review, or continue the affected dispatch.

For every child and mainline receipt, record both `model_requested` and `model_actual`. Use the observed host identifier for `model_actual`; when it cannot be observed, write `unknown`. `unknown` is not proof of the requested model and cannot satisfy a model-specific gate.

Read [references/handoff-contract.md](references/handoff-contract.md) before dispatching or accepting a child result.

## Route only the bounded work

| Need | Default owner | Required boundary |
|---|---|---|
| Multi-source external evidence | ChatGPT Deep Research | It reports sources and uncertainty only; it does not choose local adoption. |
| Research contradiction, local fit, architecture | Sol | It separates paper/code/license/download/PoC evidence and returns HOLD when proof is insufficient. |
| Approved-phase plan, contract input, coordination | Terra mainline | It may coordinate but cannot replace the parent lifecycle owner. |
| Frozen, isolated coding and focused tests | Luna | It may change only its contract whitelist and cannot relax tests or accept itself. |
| Technical acceptance | fresh Sol context | It must not be the implementation context and returns only `verified_pass`, `verified_fail`, or `blocked`. |

These are defaults, not a claim that those capabilities exist. A requested model that is unavailable must have a recorded alternative or a fail-closed status.

## Research deliverable gate

Classify the frozen contract's research deliverable before any research dispatch. One research scope has one collector.

| Contract deliverable | This Skill's route | Required result |
|---|---|---|
| `evidence_pack`: cited sources, conflicts, and uncertainty for a downstream decision or implementation | ChatGPT Deep Research is the sole external collector. | Return cited evidence only; Sol reviews credibility and local fit. |
| `horizontal_vertical_report` or another end-to-end report that includes its own collection, analysis, narrative, and formatting | Dispatch no research child. | Return `blocked` to the parent; it may route a separately approved workflow outside this Plugin. Deep Research is not a substitute for the finished report. |
| Mixed, missing, or ambiguous research deliverable | Dispatch no research child. | Return `blocked` to the parent to correct the contract before research starts. |

A readable package-external Skill is not a bundled Plugin capability and must not be invoked by this child. Never run Deep Research beside an end-to-end research workflow such as `hv-analysis` over the same source scope. Calling the overlap "independent cross-checking," "orthogonal work," or separate file ownership does not make it non-duplicative; use fresh Sol to review the evidence instead.

## Deep Research boundary

When Deep Research can be created and read, register its visible ID and accept only cited research output. When creation or readback is unavailable, set status to `external_handoff_required`, provide a copy-ready research prompt, and state that the parent is waiting for a user-supplied report or share link. Return two receipts: a mainline receipt with the coordinator's requested and observed model, and an uncreated Deep Research child receipt with `task_id: <mainline-task-id>:deep-research:uncreated`, `model_requested: deep-research`, and `model_actual: unknown`. The child ID is a local placeholder, not an external task claim, and must differ from the mainline ID. Before returning, verify `receipt_count: 2` and that both receipts contain every handoff-contract field; a single or combined receipt is invalid. Do not combine them, omit either one, claim Deep Research is running, monitor it, infer its result, or reuse the coordinator's identity as the child identity. A source-free report returns to research rather than entering implementation.

## Dispatch and receipt rules

- Give each child the phase objective, exact contract version, allowed reads/writes, evidence output, stop rule, and one return owner.
- Give each writable artifact one owner. Children never write `PROJECT-COMPASS.md`, `PRODUCT-ROADMAP.md`, `PLAN.md`, `REGISTRY.yaml`, `DECISIONS.md`, or `PROGRESS.md`.
- Accept only receipts whose `contract_version` matches the active contract. Keep mismatched work as historical evidence; do not merge it into the phase.
- On repeated validation failure, a scope breach, changed risk, missing raw evidence, or implementation self-review, stop the child and escalate a concise receipt to the parent.
- Do not ask the user to settle ordinary technical choices. Escalate only scope/value/placement changes, irreconcilable cost-time-quality choices, external accounts/costs/production/real hardware, major privacy/security/license risk, required business truth, or final acceptance. Include a recommendation and exact reply format.

## Notify and recover

Tell the parent on phase start, changed status, completion, `needs_user`, failed review, or final human-acceptance handoff. Remain quiet for unchanged running work and contract-permitted retries. If the mainline stops, a replacement reads the parent governance files, frozen contract, and prior receipts; it does not restart verified work.

The parent re-runs visible acceptance commands and writes governance receipts. A technical `verified_pass` is not user acceptance.
