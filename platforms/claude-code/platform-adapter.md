# Claude Code platform mapping

Read this before dependency, goal, child-task, model, or review checks.

| Workflow concept | Claude Code mapping |
|---|---|
| Skill invocation | Use the installed plugin Skill namespace. |
| Live phase execution | Use a visible Claude task, subagent, or agent-team item only when the host returns a stable identity and readable status. Otherwise keep the phase `proposed_not_started`. |
| Independent review | A fresh Claude context can prove context independence. It does not prove Sol unless the actual model identifier is observable. |
| Model route | Terra, Luna, and Sol remain requested defaults. Record the host-observed model in `model_actual`; a selected alias or prompt instruction is not observation. |
| Deep Research | Use only an integration that can create and read a cited result with a stable identity. Otherwise use `external_handoff_required`. |

Claude subagents are an execution mechanism, not automatic proof of a native goal, a requested model, or technical acceptance.
