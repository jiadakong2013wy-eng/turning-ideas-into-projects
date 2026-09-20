# Install in Claude Desktop

1. Open the [GitHub v0.4.0 Release](https://github.com/jiadakong2013wy-eng/turning-ideas-into-projects/releases/tag/v0.4.0).
2. Download both ZIP files:
   - `turning-ideas-into-projects-claude-desktop-0.4.0.zip`
   - `orchestrating-multi-model-work-claude-desktop-0.4.0.zip`
3. In Claude, open **Customize > Skills** and upload the two ZIP files separately. Do not wrap either ZIP in another folder or archive.
4. Confirm that `turning-ideas-into-projects` and `orchestrating-multi-model-work` are both available. Each upload archive has exactly one top-level folder named for that Skill, with `SKILL.md` inside the folder.

The lifecycle Skill uses bundled workflow resources from its own archive. The orchestration Skill is a separate upload for an already approved, frozen phase.

## Capability boundaries

- Code execution and file creation must be available before claiming implementation or validation evidence.
- Local project access is not assumed. Provide project material through uploads or connected folders and keep unprovided evidence explicit.
- Chat and Cowork can differ in file, task-status, and artifact access. When a capability is unavailable, use uploaded files or connected folders where available; otherwise use the Skill's `proposed_not_started`, `unknown`, or `external_handoff_required` fallback instead of implying access.

## Update

Download the matching newer pair of Claude Desktop ZIPs from GitHub Releases and upload each one separately through **Customize > Skills**. Start a fresh Chat or Cowork context after updating.
