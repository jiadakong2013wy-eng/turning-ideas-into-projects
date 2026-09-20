# Capability-based model selector

Read this before proposing or dispatching a model route. Model names below are recommendations for observed host catalogs, not portable guarantees.

## Selector contract

Before dispatch, observe the platform, subscription or seat mode when visible, available model IDs, whether a choice adds extra cost, and which task/model values can be read back. Then show one concise selector:

1. **推荐适配** — balance quality, included allowance, task fit, and independence. Preselect this recommendation; a preselected option is not a submitted answer.
2. **质量优先** — use the strongest observed suitable model; identify any extra cost before use.
3. **省额度/速度优先** — prefer fast or included models while preserving evidence and independent-review gates.
4. **自定义每个角色** — let the user choose mainline, research review, planning, coding, and independent review separately.

Use the host's structured choice UI when available; otherwise show these four numbered Markdown choices. Also accept direct text such as `主线=Astra，编码=Luna，复审=Sol`. A valid direct override does not require the user to reopen the selector.

At the first selection, wait for the structured UI response; with a Markdown menu, end the reply and wait for the user's choice before dispatch. An explicit request to use the recommendation, a per-role override, or an already approved profile/fallback policy satisfies this choice point. Offer `以后默认采用推荐适配` as an optional project preference; record it only in the authorized project receipt, never in global settings. With that preference, later unchanged phases need only an adoption notice. Reopen the selector when the requested route is no longer available or its cost or required capability changes.

The notice must state: observed platform and subscription mode, recommended profile, role-to-model route, unavailable or unverified capabilities, cost effect, and how to override. Do not ask for renewed approval merely because the user accepts an included-cost recommendation. Obtain explicit user authorization before any route that creates extra cost; absence of a reply means `extra_cost_authorized: false`.

If cost is unknown, show routing advice but do not dispatch the affected model until included usage or a task-specific metered budget is confirmed. A model appearing in the picker does not prove included allowance. Use observed account information or the user's explicit current-plan confirmation; do not read billing credentials. Before every paid dispatch or retry, check the authorized allowance/budget. If the allowance is exhausted, a plan is depleted, or the model is rate limited, use only an approved, observed alternative within the same budget and contract. Otherwise return `needs_user`; do not automatically buy credits or retry indefinitely.

Separate preflight from execution: before launch, verify the selectable model ID, role capability, cost, and the host mechanism for returning task/model identity. Keep `model_actual: unknown` until after launch, when the running task exposes it. Missing an already-running task before launch is not itself a blocker; missing the required readback mechanism is. Never claim a picker selection switched the current conversation's model. If the host cannot switch or dispatch that model, provide the exact manual model-selection or fresh-task handoff and stop the affected branch. A mainline handoff transfers the frozen contract to one successor; it does not create a second lifecycle owner.

## Portable roles

Route capabilities, not brand names:

| Role | Required capability |
|---|---|
| lifecycle mainline | long-horizon coherence, boundary keeping, cross-domain arbitration |
| evidence/research review | scientific reasoning, source criticism, contradiction handling, local fit |
| phase planning | contract-aware decomposition and coordination |
| implementation | focused repository work and tests inside the write whitelist |
| independent technical review | the relevant technical capability in a fresh, non-implementing context |

Deep Research is an external evidence collector, not a mainline model. It still follows the research-deliverable gate in the parent Skill.

## Recommended platform routes

### Codex

When the identifiers are observed:

| Role | 推荐适配 | 质量优先 | 省额度/速度优先 |
|---|---|---|---|
| lifecycle mainline / hardest arbitration | GPT-6 Astra | GPT-6 Astra | Terra |
| evidence and scientific review | Sol | GPT-6 Astra or Sol, matched to the contract | Sol |
| phase planning | Terra | GPT-6 Astra or Terra | Terra |
| implementation | Luna | GPT-6 Astra or Luna, matched to the bounded task | Luna |
| independent technical review | fresh Sol context | fresh GPT-6 Astra or Sol context | fresh Sol context |

If GPT-6 Astra is unavailable, use the observed Terra/Sol/Luna split and record the fallback reason. A model name in documentation is not evidence that the current host offers it.

### Claude Code and Claude Desktop

Use only models visible in the current client and record the actual subscription or seat rule.

| Subscription mode | 推荐适配 route |
|---|---|
| Max, Team premium seat, or eligible Enterprise premium seat with Fable included | Fable 5 or Fable 5.1 for the hardest mainline/arbitration and optional fresh final review; Opus 5 for planning and evidence/research review; Sonnet 5 for implementation. |
| Claude Pro, Team standard seat, or equivalent standard seat | Opus 5 for mainline, planning, evidence/research review, and fresh independent review; Sonnet 5 for implementation. Fable 5/5.1 may be offered only as an extra-cost override using pay-as-you-go usage credits. |
| Free | Sonnet 5 for observed supported roles; use a fresh context for independent review. If the frozen contract requires a stronger unavailable capability, fail closed instead of claiming equivalence. |

On Claude Pro or a standard seat, never select Fable automatically when `extra_cost_authorized` is false. Do not describe Fable as unavailable if the picker exposes it; say that it is not included in normal subscription usage and requires credits.

### WorkBuddy

Default to domestic models and the client-visible catalog. Recommended examples, only when observed:

| Role | 推荐适配 | Alternatives |
|---|---|---|
| mainline, evidence/research review, independent review | Kimi-K3 | DeepSeek-V4-Pro |
| planning and long context | GLM-5.3 | Hy4 preview |
| implementation | Kimi-K2.7-Code | MiniMax-M3 |
| simple or fast work | DeepSeek-V4-Flash | an observed fast-mode domestic model |

Respect the observed fast, balanced, or extreme mode and any Token Plan boundary. Never invent a model that is absent from the current picker. A custom model remains a candidate until its role capability, cost, and the host's task-readback mechanism are verified.

### UniClaw

Use the same selector, but recommend only models and capability indicators observed in the current UniClaw client. Do not publish a fixed brand mapping without verified platform evidence. If the model list, subscription mode, capability, cost, or running-task identity cannot be read, mark the field `unknown` and fail closed for any model-specific gate.

## Future-model rule

A future model can enter the recommendation only after the current host exposes its identifier and there is verified evidence for the required role, availability, subscription/cost effect, and the runtime-readback mechanism. Use current official capability documentation and host capability indicators; do not demand a successful production run before its first bounded dispatch. Compare it by capability and contract fit; never treat a newer name or larger version number as proof of superiority. Until verified, list it as an unverified candidate or omit it from dispatch.

## Selection and fallback rules

- User choice overrides a recommendation when the model is observed, the role capability is supported, cost authorization is satisfied, and contract evidence/independence remain valid.
- If a selected model disappears, is rate limited, or exhausts its included allowance, first use the user-approved fallback policy for the active profile. Record the requested model, actual model, and reason.
- If no approved fallback exists, or the replacement would add cost, weaken evidence, or remove independent review, stop the affected branch and return `needs_user` or `blocked`.
- `model_requested` records intent. Only an observed running task value may populate `model_actual`; otherwise use `unknown`.
