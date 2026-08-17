# ADR 0010: bootstrap 升级模式——更新已生成 `.aiassist/` 的模板派生基础设施

## Status

Accepted（2026-08-17）。

## Context

skill 更新走插件机制（Marketplace / Kimi / npx）；但已初始化项目的 `.aiassist/` 模板派生内容（全局文档、CLAUDE.md 附录、hooks、CI）停留在旧版本。原 `/bootstrap-workflow` 只做新项目初始化（步骤 7 "如果文件不存在，创建"、步骤 8 "附录已存在则跳过"），对已有项目重跑基本无操作。

难点：`.aiassist/global/` 是"模板派生基础设施"与"项目积累状态"的混合（checklists 从模板初始化后被 `/reflect` 定制；CONTEXT/business-capabilities 成为纯项目状态）。盲目覆盖丢项目状态，不覆盖则模板更新不传播。

## Decision

1. **双模式**：`/bootstrap-workflow` 检测 `.aiassist/` 存在与否——不存在 → 全新初始化；存在 → **升级模式**。

2. **`.bootstrap-state.json`（升级检测基座）**：全新初始化时记录 workflow 版本 + 每个模板派生目标文件的 sha256（bootstrap 完成时的基线）。升级时比较当前 hash vs 记录 hash：**pristine**（匹配）→ 从新模板刷新；**customized**（不匹配）→ 保留并报告。

3. **CLAUDE.md 附录替换**：模板加 `<!-- loop-workflow:begin/end -->` 哨兵；升级时有哨兵替换 begin~end，无哨兵（旧项目）用启发式（`## 循环工作流` + 独特 blockquote 锚定，替换到 EOF 或下一个顶级标题；附录后有用户内容则警告停止，不截断）。

4. **CI 已知修复**：`assertion-signoff.md` → `signoff.md`；pristine 刷新自动修复，customized 报告建议手动改。

5. **交互 = 自动应用 + 汇总报告**：pristine 刷新 + 附录替换 + CI 修复自动执行；customized 文件列出待手动合并。旧项目（无 state）保守——不自动覆盖全局文件，仅替换附录 + 报告模板变更。

6. **保留**：`stories/`、CONTEXT、business-capabilities、ADR 决策、engineering-lessons、DESIGN、tokens.css、customized 的 CI/checklists。

## Consequences

### 正面

- **已有项目升级可自动化**：重跑 `/bootstrap-workflow` 即完成 `.aiassist/` 的模板派生更新，无需手动逐个文件。
- **不丢项目状态**：customized 文件永不覆盖，由哈希检测保证。
- **附录替换鲁棒**：哨兵 + 启发式双路径。

### 代价

- **新增 state 文件**：`.bootstrap-state.json` 需维护（哈希由 agent 在 bootstrap 时计算）。
- **旧项目升级保守**：无 state 的旧项目只能替换附录 + 报告，其余需手动合并。
- **customized 文件需人工跟进**：模板变更无法自动合并进 customized 文件。

## 替代方案

- **手动升级清单（无 bootstrap 支持）**：当前做法，容易漏步、与插件升级脱节。取代。
- **无条件覆盖全局文件**：丢 `/reflect`/`/domain-model` 定制内容，否决。
- **仅文档指导、无机制**：升级仍靠手动，否决。

## 相关文件

- `skills/productivity/bootstrap-workflow/SKILL.md`（升级模式）
- `templates/claude/project-claude-appendix.md.template`（哨兵 + 升级说明）
- `docs/install.md`（项目级升级说明）
- `README.md`（升级清单）
