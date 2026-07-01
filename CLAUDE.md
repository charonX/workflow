# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Workspace purpose

This is a personal workflow sandbox for a one-person creator/operator. The `reference/` directory holds three popular open-source agent-skill projects for study and adaptation. The root workspace is where I curate and evolve my own Claude Code workflow.

From an OPC (one-person company) perspective, the high-leverage steps are:

1. **Demand insight** — make sure we're solving a real problem someone will pay for.
2. **UI/UX design** — make the thing feel right before building it.
3. **Development plan** — decide what to build and in what order.
4. **End-to-end validation** — prove the shipped thing works for the user, not just that the code compiles.

The actual typing of code is low-leverage. Let the agent handle implementation; my job is to hold the vision, validate the demand, approve the design, and verify the outcome.

## Our workflow: test-as-contract

This workspace now contains our own Claude Code workflow: **test-as-contract** (`skills/`). It combines the best of the reference projects:

- **mattpocock skills** — traditional software-engineering discipline (TDD, adversarial docs review, diagnosis).
- **gstack** — CEO/founder-level demand insight, design decisions, shipping and QA gates.
- **soflow** — process-driven artifact chain (PRD → REQ → tests → code → reflect).
- **superpowers** — rigorous plans, subagent-driven batch execution, and review packages.

Core idea:

> **Human holds the oracle (assertions); AI implements inside a test contract. The human does not edit implementation code directly — they edit requirements and assertions, and errors flow back up to the highest layer.**

Key mechanics:

- **Two gears**: Gear 1 (exploration — PRD, HTML UX, no tests, free to overturn) → crossing line → Gear 2 (test-locked — REQ-ID → tests → code).
- **Two hard signoffs**: `/assertion-signoff` = human signs assertions before implementation; `/feel-signoff` = human verifies feel against HTML reference.
- **Three roles**: human (REQ/assertions/HTML), test-author agent (writes test scaffold), implementer agent (writes code, read-only on tests).
- **REQ-ID traceability**: every test file must declare `// REQ-TRACE` and `// REQ-VERSION`.

Do not modify the reference repos unless explicitly asked. Treat them as read-only inspiration and copy/adapt individual skill patterns into `skills/`.

| Path | Project | What to steal from it |
|------|---------|----------------------|
| `reference/gstack/` | Garry's gstack | CEO insight, shipping + validation: `/office-hours`, `/design-shotgun`, `/qa`, `/benchmark`, `/canary`, `/ship`, browser automation |
| `reference/mattpocock/` | Matt Pocock's skills | Lightweight daily engineering skills: `/grill-me`, `/grill-with-docs`, `/tdd`, `/diagnose`, domain modeling |
| `reference/superpowers/` | Jesse's Superpowers | Rigorous planning and execution: `writing-plans`, `subagent-driven-development`, `executing-plans` |
| `reference/soflow/` | soflow | Process-driven artifact chain: `.aiassist/stories/<id>/`, PRD → REQ → stories, HTML UX prototypes |
| `reference/baoyu-design/` | baoyu-design (Jim Liu) | Claude Design portable skill: HTML prototypes, design systems, Figma import, PPTX export, starter components |

## Our test-as-contract workflow

When working on a real feature, use the skills in `skills/` rather than the reference skills directly. The reference projects are for inspiration; `skills/` is the operational workflow.

### Phase overview

| # | Phase | Skill | Who triggers | Purpose |
|---|---|---|---|---|
| 1 | THINK — demand insight | `/demand-insight` | user | Adversarial interview; surface hidden needs, boundaries, contradictions |
| 2 | PRD synthesis | `/to-prd` | user | Turn interview notes into a structured PRD |
|   | Design system prerequisite | `/design-system` | user | Build or verify project-level design system + `tokens.css` before high-fidelity UX |
|   | Design import (optional) | `/design-import` | user | Import design sources: Figma .fig, GitHub repos, existing HTML/CSS |
| 3 | DESIGN — UX exploration | `/ux-explore` | user | Iterate high-fidelity HTML UX prototypes with React; behavioral decisions → REQ, visual decisions → HTML |
| 4 | Crystallize | `/crystallize` | model | Convert stable PRD blocks into REQ-IDs with acceptance criteria |
| 5 | TEST — write target | `/test-author` | model | Generate test scaffold from REQ; placeholder assertions for human |
| 6 | assertion-signoff | `/assertion-signoff` | user | Human signs all assertions before implementation begins |
| 7 | BUILD | `/implementer` | model | Implement code against tests; read-only on tests; full suite every iteration |
| 8 | REVIEW/QA | `/qa-runner` | model | E2E, regression, evidence collection |
| 9 | feel-signoff | `/feel-signoff` | user | Human verifies feel against HTML reference; deviations flow back to REQ |
|   | Developer handoff (optional) | `/design-handoff` | user | Generate structured dev handoff package from approved UX prototypes |
| 10 | REFLECT | `/reflect` | user | Capture lessons, update `.aiassist/global/` knowledge |

### Getting started in a target project

1. Make sure the target project has the workflow skills installed:
   ```bash
   mkdir -p .claude/skills
   cp -R /path/to/workflow/skills/productivity/* .claude/skills/
   cp -R /path/to/workflow/skills/engineering/* .claude/skills/
   cp -R /path/to/workflow/skills/maintenance/* .claude/skills/
   ```
2. Run `/bootstrap-workflow` in the target project to create `.aiassist/` project infrastructure.
3. Run `/test-as-contract` to start the first story.

### Installing skills

`README.md` has the full installation and update instructions.

### Reference workflow (legacy)

The detailed 5-step reference workflow below is still useful for understanding the high-leverage activities, but the operational path is now the test-as-contract skill set above.

### 1. Demand insight — are we building the right thing?

Before design or code, validate that the problem is real and the solution is wanted.

- Use `reference/superpowers/skills/brainstorming/SKILL.md` or `reference/gstack/office-hours/SKILL.md` to interrogate the idea.
- Use `reference/skills/skills/productivity/grill-me/SKILL.md` or `reference/skills/skills/engineering/grill-with-docs/SKILL.md` to walk down every branch of the decision tree.
- Questions to answer before moving on:
  - Who exactly feels this pain?
  - What are they doing today instead?
  - Why will they switch to this?
  - What's the narrowest wedge we can ship first?
- Output: a short validated spec. If the answer is "I'm not sure," stop here and go talk to users or do research.

### 2. UI/UX design — what should it feel like?

Design the user experience before writing implementation plans.

- Use `reference/gstack/design-shotgun/SKILL.md` to generate multiple visual variants and compare them.
- Use `reference/gstack/design-consultation/SKILL.md` if there's no existing design system.
- Use `reference/gstack/plan-design-review/SKILL.md` to critique a plan's design dimensions before building.
- For live sites, use `reference/gstack/design-review/SKILL.md` to find and fix visual/hierarchy issues.
- Output: approved mockups or design direction, plus any design system decisions captured in the project docs.

### 3. Development plan — what do we build, in what order?

Once demand and design are clear, write the implementation plan. Do not skip this.

- Use `reference/superpowers/skills/writing-plans/SKILL.md` as the template.
- Use `reference/gstack/plan-eng-review/SKILL.md` to lock in architecture, data flow, edge cases, and test coverage.
- Save plan to `docs/plans/YYYY-MM-DD-<feature-name>.md`.
- Each task should be a vertical slice that produces working, testable behavior.
- Output: a plan the user approves, with exact file paths and verification steps.

### 4. Implement — let the agent handle the code

With a validated plan, execute. The goal is not perfect code; it's working, testable software that matches the design.

- Use `reference/superpowers/skills/subagent-driven-development/SKILL.md` or `reference/superpowers/skills/executing-plans/SKILL.md` to work through the plan task-by-task.
- The agent handles coding. I review at checkpoints and approve direction changes.
- If a task involves UI, the agent should produce a runnable state I can look at, not just code.
- Do not get stuck in refactoring loops. YAGNI. Ship the smallest version that validates the demand.

### 5. End-to-end validation — does it actually work?

This is the highest-leverage step. Validate the real user experience, not just unit tests.

- **Functional validation**: run the app/CLI/site and walk through the user flow. If it doesn't work for a real user, it doesn't ship.
- **Automated testing**: run the project's test/lint/typecheck commands. Fix regressions before shipping.
- **QA / dogfooding**: use `reference/gstack/qa/SKILL.md` or `reference/gstack/qa-only/SKILL.md` to systematically test flows and capture screenshots/evidence.
- **Browser/site validation**: use `reference/gstack/browse/` to interact with the deployed or local site end-to-end.
- **Performance**: use `reference/gstack/benchmark/SKILL.md` if load time or bundle size matters.
- **Post-deploy**: use `reference/gstack/canary/SKILL.md` to watch production after shipping.
- Output: a shipped thing with evidence that it works for the user.

## Skill quick-reference

### Our skills (`skills/`)

| I need to... | Reach for |
|--------------|-----------|
| Start a new feature with test-as-contract | `/test-as-contract` |
| Initialize the workflow in a target project | `/bootstrap-workflow` |
| Run an adversarial demand interview | `/demand-insight` |
| Turn discussion into a PRD | `/to-prd` |
| Explore UX with HTML prototypes | `/ux-explore` |
| Build or update a design system | `/design-system` |
| Import design sources (Figma/GitHub/HTML) | `/design-import` |
| Convert PRD into REQ-IDs | `/crystallize` |
| Generate test scaffold from REQ | `/test-author` |
| Sign off assertions before implementation | `/assertion-signoff` |
| Implement code against signed tests | `/implementer` |
| Run QA / E2E / regression | `/qa-runner` |
| Verify feel against HTML reference | `/feel-signoff` |
| Generate developer handoff from UX | `/design-handoff` |
| Capture lessons and update knowledge | `/reflect` |
| Sync reference projects and absorb upstream changes | `/sync-refs` |

### Reference skills (for inspiration only)

| I need to... | Reach for |
|--------------|-----------|
| Validate an idea or find the wedge | `reference/superpowers/skills/brainstorming/` or `reference/gstack/office-hours/` |
| Grill me on a plan until it's sharp | `reference/mattpocock/skills/productivity/grill-me/` or `reference/mattpocock/skills/engineering/grill-with-docs/` |
| Explore UI variants | `reference/gstack/design-shotgun/` |
| Build a design system from scratch | `reference/gstack/design-consultation/` |
| Review a plan's design before coding | `reference/gstack/plan-design-review/` |
| Audit a live site's visual design | `reference/gstack/design-review/` |
| Write a structured implementation plan | `reference/superpowers/skills/writing-plans/` |
| Review architecture / edge cases | `reference/gstack/plan-eng-review/` |
| Execute a plan with agent support | `reference/superpowers/skills/subagent-driven-development/` |
| Debug a bug | `reference/skills/skills/engineering/diagnose/` or `reference/gstack/investigate/` |
| Systematically QA a site | `reference/gstack/qa/` or `reference/gstack/qa-only/` |
| Check performance | `reference/gstack/benchmark/` |
| Monitor after deploy | `reference/gstack/canary/` |
| Ship / open a PR | `reference/gstack/ship/` + `reference/gstack/review/` |

## Reference project commands

Run these from inside the relevant `reference/` subdirectory, not from the workspace root.

### gstack (`reference/gstack/`)
- `bun install` — install deps
- `bun test` — free tests
- `bun run test:evals` — paid evals, diff-based
- `bun run build` — gen docs + compile binaries
- `bun run gen:skill-docs` — regenerate SKILL.md files from templates
- `bun run slop` / `bun run slop:diff` — AI code-quality scan

### superpowers (`reference/superpowers/`)
- No root build. Read `skills/writing-skills/SKILL.md` before creating or editing skills.

### mattpocock skills (`reference/mattpocock/`)
- `npx skills@latest add mattpocock/skills` — consumer install
- Skills live at `skills/<bucket>/<skill-name>/SKILL.md`.

## Creating and updating our skills

`skills/` contains the canonical test-as-contract skill set, organized as a Claude Code plugin:

- `skills/productivity/` — user-invoked workflow skills
- `skills/engineering/` — model-invoked implementation skills
- `skills/maintenance/` — workflow maintenance skills (sync refs, update config, ...)

When adapting a reference skill pattern into our workflow:

1. Copy only the pattern you need into a new folder under `skills/<bucket>/<skill-name>/SKILL.md`.
2. Add the skill path to `.claude-plugin/plugin.json`.
3. Record reference sources in the skill's frontmatter `sources:` and in `skills/<bucket>/<skill-name>/SOURCES.md`.
4. Strip out anything that does not fit our workflow.
5. Edit the voice and examples to match our projects.
6. Test the skill in a real Claude Code session before finalizing.

Good skills are small and composable. One skill = one clear job.

When a reference project updates, use the recorded `sources` to diff and update our skill locally, then reinstall it in target projects.

## Keeping skills in sync with reference projects

Our skills adapt patterns from reference projects (`reference/`). When those projects
update, we need a structured way to decide what to absorb.

### Quick sync

Run `/sync-refs` (or `./scripts/sync-refs.sh`). It:

1. `git pull` all reference repos
2. Parse each skill's `SOURCES.md` to find which reference files it depends on
3. `git log --since=<last sync>` for each dependency
4. Generate `docs/sync-reports/YYYY-MM-DD.md` with changes grouped by skill
5. Guide you through judging each change: absorb / skip / later

### Manual sync

```bash
# 1. Pull all refs
./scripts/sync-refs.sh --pull-only

# 2. Check what changed in a specific reference file
git -C reference/baoyu-design log --since="2026-06-01" -- skills/baoyu-design/system-prompt.md

# 3. Diff the changes
git -C reference/baoyu-design diff <old-commit>..HEAD -- skills/baoyu-design/system-prompt.md

# 4. If absorbing, update the skill and its SOURCES.md
```

### Update cadence

- **Monthly** (default): run `/sync-refs`, most reports will be clean
- **On major releases**: when gstack/superpowers/baoyu-design ship a major version
- **Before a big workflow change**: check if upstream has solved the same problem already

### Decision framework

| Reference change type | Action |
|----------------------|--------|
| New feature/skill we don't use | Skip |
| Methodology improvement in something we adapted | Evaluate carefully, often worth absorbing |
| Bug fix or format improvement | Absorb (low risk) |
| Internal refactor | Skip (doesn't affect methodology) |
| File moved/deleted upstream | Flag — check if our reference is broken |
| Change conflicts with our adaptation | Analyze — keep our design decision unless upstream found a better way |
