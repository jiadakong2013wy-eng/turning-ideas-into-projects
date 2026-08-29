# Turning Ideas into Projects

Turn a vague idea into a scoped, testable project task before coding begins.

The workflow first checks whether the idea is worth doing, clarifies the user and value, plans only the approved phase, executes within a frozen scope, and finishes with independent technical review.

## Install

Requirements: Git, PowerShell, and a Codex version that supports Plugins and native goals.

```powershell
git clone https://github.com/jiadakong2013wy-eng/turning-ideas-into-projects.git
Set-Location .\turning-ideas-into-projects
pwsh -NoProfile -File .\scripts\install.ps1
```

After installation, restart Codex and create a new task.

## Use

Enter this in a new Codex task:

```text
/turning-ideas-into-projects your idea
```

Example:

```text
/turning-ideas-into-projects I want to build a tool that helps teachers prepare lessons faster. First decide whether it is worth building; do not start coding yet.
```

The workflow will:

1. Clarify the problem, user, value, and alternatives.
2. Recommend `GO`, `PIVOT`, `HOLD`, or `STOP`.
3. Plan near-, mid-, and long-term outcomes without starting all of them.
4. Freeze and execute only the approved current phase.
5. Recheck the result in a fresh reviewer context.
6. Report evidence, remaining risks, and the next action.

## Multi-model work

When a frozen phase needs external research, model-specialized work, long-running child tasks, or independent review, Codex will explain the proposed model routing before it starts. You can replace or disable a model when the required evidence and review independence remain valid.

Default routing:

| Work | Default |
|---|---|
| Multi-source external evidence | Deep Research |
| Research review, architecture, and independent technical review | Sol |
| Phase planning and coordination | Terra |
| Scoped coding and focused tests | Luna |

Deep Research starts only when the approved phase explicitly requires a cited external evidence package. It does not start for simple explanations, local-only checks, or a complete horizontal-vertical research report.

## Update

```powershell
git pull --ff-only
pwsh -NoProfile -File .\scripts\install.ps1
```

Restart Codex and use a new task after updating.

## License

This project is released under the MIT License. Bundled third-party notices and licenses are under `third_party/`.
