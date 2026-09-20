# Existing-project upgrade intake

## Entry gate

Use this intake only after the coordinator announces `existing_project_upgrade`: the user named an existing product, repository, application, migration, modernization, refactor, feature extension, or current-behavior improvement. Identify the project or product first. The classification grants neither access nor write authority.

## Approved source map

Before deep inspection, ask the user to approve a source map:

- **Priority:** directories, source areas, requirements, design documents, and decisions to read.
- **Optional:** tests, logs, task records, and selected prior conversations that may help.
- **Excluded:** obsolete plans, experiments, generated output, unrelated products, confidential areas, and any material that must not influence analysis.
- **Unresolved:** candidate material whose relevance requires confirmation.

Do not deep-read any source before approval. Newly discovered material is `Unresolved` until approved; do not pull `Excluded` material in through a broad search. Re-show the reusable map at each upgrade phase so the user can add or remove sources.

## Shallow reconnaissance

If the user cannot identify useful paths, perform one read-only shallow scan of the named root: read applicable project instructions and list root files plus first-level directories. Propose a reading list and wait for approval before opening deeper content.

## Prior conversations and memory

Prior conversations and model memory are user-selected evidence, not ambient authority. Where conversation listing and readback are available, show candidate titles and summaries before the user selects full content. Otherwise ask for an export, pasted summary, or handoff. Record stable identifiers only when observed; otherwise record the supplied artifact path or description. Treat memory as `historical clues` until current evidence or the user confirms it.

## Adaptive inspection by product type

Inspect only approved material and adapt depth to the product and upgrade:

- All projects: instructions, overview, relevant structure, validation entry points, and recent changes.
- Code products: relevant entry points, data flow, configuration, dependencies, tests, and the smallest affected call chain.
- UI products: actual screens, screenshots, or a runnable key workflow as well as source. If runtime evidence is unavailable, label the result `static_understanding` and state the missing evidence.
- APIs, services, and libraries: interfaces, call paths, examples, schemas, and tests; no artificial UI requirement applies.
- Unavailable local access: use user uploads, a connected folder, repository export, screenshots, recordings, logs, or a structured handoff.

## Evidence classes and conflicts

Classify evidence as verified current runtime behavior, source/configuration/data structures, user-confirmed facts in this run, formal documents and decisions, selected historical conversations, or model-memory impressions. The order helps expose conflicts; it never resolves them automatically. Pause the affected branch for a user decision when material evidence conflicts.

## Project baseline

Report a confirmable baseline with current product, architecture, workflows, constraints, and upgrade-relevant evidence. Separate verified facts, user-confirmed facts, `historical clues`, inferences, unknowns, `unchecked scope`, and conflicts. A source-only UI assessment must remain `static_understanding`, not a runtime claim.

## Baseline confirmation

Emit a `BASELINE_CONFIRMATION` receipt containing that baseline and ask the user to confirm or correct it before designing upgrade options. Confirmation authorizes neither code changes nor unapproved source reads.

If deep inspection is not yet approved, still emit a provisional `BASELINE_CONFIRMATION` in the current reply. Build it only from facts the user confirmed in this run and explicitly labelled unknowns, `unchecked scope`, inferences, and evidence gaps; do not represent uninspected material as fact. In the same user action, ask for confirmation or correction of both this provisional baseline and the proposed source map. After approved inspection, replace or update it with the evidence-based baseline and request confirmation again before offering upgrade options.

## Persistence and stale-baseline handling

When a governance pack is authorized, record approved paths, artifacts, exclusions, evidence classes, and verification times in `REGISTRY.yaml`; record the confirmed baseline in `PROJECT-COMPASS.md`; record receipts in `PROGRESS.md`. Without observed write capability, label the copy-ready record `not_persisted`. If material source, runtime behavior, selected documents, or user-confirmed facts change, re-check only the affected slice; return to brainstorming if product value, user, placement, or shape changes.

## Capability fallbacks

If the host cannot list conversations, request an export, paste, or handoff. If it cannot inspect a live interface, request a screenshot, recording, or guided observation. If it cannot access the product locally, use approved supplied artifacts. State the evidence gap rather than inferring unavailable capability or runtime results.

## Common mistakes

- Treating a mode choice as permission to crawl a repository.
- Reading `Optional` or `Unresolved` sources before approval.
- Letting historical conversations override current evidence or user confirmation.
- Calling a source-only UI reading a runtime observation.
- Promising a baseline later instead of presenting one for user confirmation now.
