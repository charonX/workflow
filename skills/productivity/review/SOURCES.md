# 参考来源：review

## 理念

外层设计循环中的手动检查点。人在关键转换点需要一双"新眼睛"，避免当前会话的上下文偏见。本 skill 是建议性而非强制性的审查门：输出 review 报告，但不自动修改产物；是否回流由人拍板。

## 借鉴的 reference 文件

- `reference/gstack/review/SKILL.md`
- `reference/gstack/plan-eng-review/SKILL.md`
- `reference/mattpocock/skills/engineering/code-review/SKILL.md`：v1.1.0 在 Standards 轴内置的 Fowler 代码异味基线（12 个 high-signal smells + 两条绑定规则：仓库标准优先、永远只是判断）。
- `reference/agent-skills/agents/code-reviewer.md`：五轴代码审查、变更尺寸、severity labels。
- `reference/agent-skills/agents/security-auditor.md`：OWASP、输入验证、鉴权、依赖审计。
- `reference/agent-skills/agents/test-engineer.md`：测试策略、覆盖分析、Prove-It 模式。
- `reference/agent-skills/agents/web-performance-auditor.md`：Core Web Vitals、性能审查（我们泛化为后端+前端性能审计员）。

## 主要改动

- 设计为手动触发，支持 `prd` / `tech` / `code` 三个阶段。
- 强调在新 Claude Code 会话中调用，避免上下文偏见。
- 输出结构化 review 报告，但不自动修改产物。
- 建议性而非强制性；回流决策由人做。
- 新增 `--mode=panel`（仅 `stage=code`），并行派发 code-reviewer / security-auditor / performance-auditor / test-engineer 四个 specialist 子代理。
- `stage=code` 增加 Fowler 代码异味基线（12 个坏味道），默认模式与 panel 模式的 code-reviewer 均应用；repository 标准优先、异味永远只是判断。

## 未来局部更新建议

- gstack review 更新时，检查代码审查维度和报告格式。
- gstack plan-eng-review 更新时，检查计划/架构审查清单。
- mattpocock code-review 更新时，检查代码异味基线清单与判定规则（增删 smell、绑定规则变化）。
- agent-skills 任一 agent persona 更新时，检查 specialist 维度、输出格式、安全/性能/测试审查清单。

## 改动记录

- 2026-07-04：创建 skill，定义三阶段手动 review 流程与报告模板。
- 2026-07-09：新增 `--mode=panel` 与 4 个 specialist 子代理并行审查模式，报告模板新增 Panel Review 小节。
- 2026-08-06：吸收 mattpocock v1.1.0 code-review 的 Fowler 代码异味基线到 `stage=code`；panel 模式由 code-reviewer 承担，不做重复审查。
