# Test-as-Contract Workflow

A Claude Code plugin for human-AI collaborative development where tests are the contract.

## Core idea

> Human holds the oracle (assertions); AI implements inside a test contract. The human does not edit implementation code directly — they edit requirements and assertions, and errors flow back up to the highest layer.

## Install

```bash
npx skills@latest add <your-github-username>/test-as-contract-workflow
```

Or copy/symlink the `skills/` directory into your target project's `.claude/skills/`:

```bash
# Copy
cp -R /path/to/workflow/skills/* .claude/skills/

# Or symlink (local dev only)
ln -s /path/to/workflow/skills/* .claude/skills/
```

## Usage

In a target project:

```
/bootstrap-workflow    # initialize project-level workflow infrastructure
/test-as-contract      # start or continue a story
```

## Skills

### User-invoked

| Skill | Phase | Purpose |
|---|---|---|
| `/test-as-contract` | Router | Start/continue a story; enforce signoffs |
| `/bootstrap-workflow` | Setup | Initialize `.aiassist/` project infrastructure |
| `/demand-insight` | THINK | Adversarial demand interview |
| `/to-prd` | PRD | Synthesize discussion into PRD |
| `/design-system` | DESIGN | Build project-level design system |
| `/ux-explore` | DESIGN | Iterate high-fidelity HTML UX prototypes |
| `/assertion-signoff` | Signoff | Sign assertions before implementation |
| `/feel-signoff` | Signoff | Verify feel against HTML reference |
| `/reflect` | REFLECT | Capture lessons |

### Model-invoked

| Skill | Phase | Purpose |
|---|---|---|
| `/crystallize` | Crystallize | Convert PRD to REQ-IDs |
| `/test-author` | TEST | Generate test scaffold |
| `/implementer` | BUILD | Implement code against tests |
| `/qa-runner` | QA | Run E2E/regression |

## Artifact layout

```
.aiassist/
├── stories/<story-id>/
│   ├── prd.md
│   ├── requirements.md
│   ├── requirements-v1.hash
│   ├── ux/
│   ├── test-plan.md
│   ├── assertion-signoff.md
│   ├── feel-signoff.md
│   └── workflow-state.yaml
└── global/
    ├── engineering-lessons.md
    ├── architecture.md
    └── STANDARDS.md
```

## Templates

Templates live in `templates/` and are copied by `/test-as-contract` when creating a new story.

## References

This workflow synthesizes ideas from:

- [mattpocock/skills](https://github.com/mattpocock/skills) — engineering discipline
- [gstack](https://github.com/gstackio/gstack) — CEO/founder insight and shipping
- [soflow](https://github.com/geekplus/soflow) — process and artifact chain
- [superpowers](https://github.com/prime-radiant-inc/superpowers) — planning and subagent execution

## License

MIT
