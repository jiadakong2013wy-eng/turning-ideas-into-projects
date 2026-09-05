# China Unicom UniClaw platform mapping

Read this before dependency, goal, child-task, model, or review checks.

| Workflow concept | UniClaw mapping |
|---|---|
| Skill invocation | Use the imported Skill name or the matching Skill tag. |
| Bundled workflow dependency | From the lifecycle archive, resolve a referenced dependency name under `references/bundled-skills/<skill-name>/SKILL.md`; these are supporting resources, not separately imported sibling Skills. |
| Live phase execution | Use the current or a new UniClaw task only when a stable identity and readable status are exposed. Otherwise keep the phase `proposed_not_started`. |
| Independent review | Use a separately identifiable fresh task. A second answer in the implementation task is self-review. |
| Model route | A configured or selected model is `model_requested`; it becomes `model_actual` only when the running task exposes that value. |
| Deep Research | UniClaw's built-in research may satisfy the evidence collector only when its cited output, task identity, and readback are observable. Its label alone is not ChatGPT Deep Research proof. |

When a required value is not observable, preserve `unknown`, `external_handoff_required`, or `proposed_not_started` and stop the affected branch.
