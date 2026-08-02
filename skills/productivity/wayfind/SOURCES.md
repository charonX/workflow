# Sources

## Primary

- `reference/mattpocock/skills/engineering/wayfinder/SKILL.md` — wayfinder 的核心概念：map、ticket type、fog of war、frontier、HITL/AFK 模式
- `reference/mattpocock/skills/engineering/setup-matt-pocock-skills/issue-tracker-local.md` — local-markdown issue tracker 的 wayfinding 操作约定

## Methodology references (引用但不调用)

- `skills/productivity/demand-insight/SKILL.md` — grilling 票的访谈技巧来源
- `skills/productivity/research/SKILL.md` — research 票的 primary-source 纪律来源
- `skills/productivity/design/SKILL.md` — prototype 票的 HTML 原型方法来源

## Differences from reference

1. **存储层**：mattpocock wayfinder 依赖 issue tracker（GitHub/GitLab/local-markdown），我们使用 `.aiassist/wayfind/<name>/` 目录 + markdown 文件。原因是单人创作场景不需要 tracker 的重量，且 markdown 文件天然可被 git 追踪。

2. **转 story 而非转 spec**：mattpocock 的 wayfinder 输出转 `to-spec`/`to-tickets`，我们的输出转 `/story`。这是工作流差异——我们有完整的循环工作流，wayfind 是它的上游。

3. **ADR 集成**：mattpocock 没有"明确不做写 ADR"的概念。我们加上，因为我们的工作流已有 ADR 基础设施（`/tech-design` 写入 `.aiassist/global/adr/`），wayfind 自然地复用这个决策记录机制。

4. **方法论引用模式**：mattpocock wayfinder 直接调用 grilling/research/prototype skill；我们不直接调用（因为输出路径冲突），改为读方法论 + 覆盖输出路径。
