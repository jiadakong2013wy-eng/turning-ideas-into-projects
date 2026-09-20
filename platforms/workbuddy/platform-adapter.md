# Tencent WorkBuddy platform mapping

Read this before dependency, goal, child-task, model, or review checks.

| Workflow concept | WorkBuddy mapping |
|---|---|
| Skill invocation | Use the installed flat Skill name or its Skill tag. |
| Live phase execution | Use a WorkBuddy task, workflow, or multi-Agent item only when its identity and status can be read back. Otherwise keep the phase `proposed_not_started`. |
| Independent review | Use a demonstrably fresh task/Agent. Product marketing for multi-Agent support is not proof that the current reviewer is independent. |
| Model route | Default to domestic models visible in the current picker: Kimi-K3 (or DeepSeek-V4-Pro) for mainline/research/fresh review, GLM-5.3 for planning and long context, Kimi-K2.7-Code (or MiniMax-M3) for implementation, and DeepSeek-V4-Flash for simple or fast work. Respect observed fast/balanced/extreme mode and Token Plan limits. A model picker records intent only; populate `model_actual` from an observable run or task value, otherwise use `unknown`. |
| Deep Research | Accept WorkBuddy research only when the run has traceable sources and a readable receipt. Otherwise use `external_handoff_required`. |

Do not infer runtime capabilities from a Skill tag, model selector, or product feature name.
