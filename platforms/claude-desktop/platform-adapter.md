# Claude Desktop platform mapping

Read this before dependency, goal, child-task, model, Deep Research, or review checks.

| Workflow concept | Claude Desktop mapping |
|---|---|
| Skill invocation | Upload each custom Skill archive separately through Claude's Skills interface. Each ZIP contains exactly one top-level folder named for its flat Skill name, then invoke that Skill name. |
| Bundled workflow dependency | From the lifecycle archive, resolve a required dependency at `references/bundled-skills/<skill-name>/SKILL.md`; these are supporting resources, not separately uploaded sibling Skills. |
| Project and evidence files | Local project access is not assumed. Use connected folders when available, or upload the approved files and state which evidence is absent. |
| Live phase execution | In Chat or Cowork, treat a phase as live only when the host exposes a stable identity and readable status. Otherwise preserve `proposed_not_started`. |
| Conversation artifacts | Use selected conversation artifacts only when they can be exported, uploaded, or read back in the current context; unselected conversation memory is an unverified hypothesis. |
| Independent review | Use a separately identifiable fresh Chat or Cowork context. A second answer in the implementation conversation is self-review. |
| Model route | A requested or selected model is `model_requested`; record `model_actual` only when the run exposes it, otherwise record `unknown`. |
| Deep Research | Treat research as evidence only when cited output and readable artifacts are available; otherwise use `external_handoff_required`. |

When code execution or file creation is unavailable, keep the affected work proposed and provide a copy-ready contract or receipt rather than claiming execution. When a required value is not observable, preserve `unknown`, `external_handoff_required`, or `proposed_not_started` and stop the affected branch.
