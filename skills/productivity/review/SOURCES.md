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

- 无 stage：接口为 `--cover=prd,tech,req,test,code` / `--mode=panel|single` / `--story`；`--cover` 缺省自动审所有输入存在的层。
- 默认 panel 并行：每层一个 specialist 子代理（prd-reviewer / tech-reviewer / req-reviewer / test-engineer / code-reviewer；安全/性能条件派发），父代理汇总到 `review.md`。
- 末端统一审查：默认建议 QA 全绿后、REFLECT 前一次审全链五层；不设中途建议检查点。
- `--mode=single`：不派子代理，单会话按各层维度逐项过（小改动/token 敏感场景）。
- test-engineer 承担 `EXPECTED-TRACE` 诚实性检查（防 AI 自证）。
- `cover=code` 应用 Fowler 代码异味基线（12 个坏味道），repository 标准优先、异味永远只是判断。
- 强调在新 Claude Code 会话中调用，避免上下文偏见；输出结构化 review 报告，但不自动修改产物；建议性而非强制性，回流决策由人做。

## 未来局部更新建议

- gstack review 更新时，检查代码审查维度和报告格式。
- gstack plan-eng-review 更新时，检查计划/架构审查清单。
- mattpocock code-review 更新时，检查代码异味基线清单与判定规则（增删 smell、绑定规则变化）。
- agent-skills 任一 agent persona 更新时，检查 specialist 维度、输出格式、安全/性能/测试审查清单。

## 改动记录

- 2026-08-17：重构为无 stage 的 cover 自适应并行审查（`design/adr/0008`）：去掉 `--stage=prd|code`，改 `--cover` 按层派发 specialist；panel 为默认模式；输出改 `review.md`；默认流改末端统一审查（QA 后 REFLECT 前一次审全链）。新增 prd-reviewer / tech-reviewer / req-reviewer 维度，test-engineer 增加 EXPECTED-TRACE 诚实性检查。
- 2026-07-04：创建 skill，定义三阶段手动 review 流程与报告模板。
- 2026-07-09：新增 `--mode=panel` 与 4 个 specialist 子代理并行审查模式，报告模板新增 Panel Review 小节。
- 2026-08-06：吸收 mattpocock v1.1.0 code-review 的 Fowler 代码异味基线到 `stage=code`；panel 模式由 code-reviewer 承担，不做重复审查。
- 2026-08-06：PRD 与 tech-design 合并（`design/adr/0004`）：`--stage=tech` 并入 `--stage=prd`，PRD 审查现含技术方案维度；specialist 输入改读 `prd.md`（含技术方案）。
- 2026-08-06：快速收敛哲学（`design/adr/0005`）：stage=prd 明确为补缺口第二场所——发现 PRD 缺口就地补或按四分法归类。
