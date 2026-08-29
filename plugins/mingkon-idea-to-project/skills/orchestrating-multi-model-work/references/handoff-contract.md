# Versioned child-task receipt

Use this receipt after the parent has approved a phase and frozen its contract. Return it to the parent; do not update central governance files directly.

```yaml
task_id: stable-visible-or-local-id
role: research | reviewer | planner | implementer
model_requested: terra | sol | luna | deep-research | other
model_actual: observed-host-model-or-unknown
contract_version: exact-active-contract-version
status: queued | running | external_handoff_required | needs_user | verified_pass | verified_fail | blocked
result: concise-outcome-without-process-noise
evidence:
  - source-or-raw-command-output-path
files_changed:
  - workspace-relative-path-or-none
risks:
  - remaining-risk-or-none
next_action: one-owner-and-one-action
```

Rules:

- `model_actual: unknown` means the requested model was not verified; it cannot be reported as a successful requested-model run.
- An uncreated external child uses the local placeholder `task_id: <mainline-task-id>:<role>:uncreated`. It must differ from the mainline ID and must not be presented as a visible external task ID.
- `external_handoff_required` means Deep Research could not be programmatically created or read. Include the copy-ready prompt and wait for a user-provided report or link.
- `verified_pass` and `verified_fail` are reviewer outputs only; an implementer returns raw evidence and `blocked` or `needs_user` when appropriate.
- A receipt with a different `contract_version` is historical evidence only. The parent decides whether to re-contract.
