# 参考来源：improve-codebase-architecture

## 理念

循环工作流擅长"从需求到实现"的新功能路径，但没有一个 skill 主动审视**既有代码库的架构摩擦点**。`/improve-codebase-architecture` 补这个缺口：以 deep-module 词汇（module/interface/seam/depth）扫描代码库，把"深化机会"以可交互 HTML 报告呈现，然后让用户圈定要落地的候选、**为每个候选创建一个 story 起点**。它只做上游发现与落地转交，不做实施——深化本身在 story 流程内完成（PRD → 结晶 → 测试 → 实现）。

## 借鉴的 reference 文件

- `reference/mattpocock/skills/engineering/improve-codebase-architecture/SKILL.md`：主体流程（Explore → HTML 报告），保留前半段；mattpocock 的 grilling loop 后续**不采纳**（见主要改动）。
- `reference/mattpocock/skills/engineering/improve-codebase-architecture/HTML-REPORT.md`：HTML 报告规范（scaffold、五种 diagram pattern、tone 纪律），整体搬移。
- `reference/mattpocock/skills/engineering/codebase-design/SKILL.md` + `DEEPENING.md`：架构词汇（8 术语 + 四原则 + 依赖四分类），**抽到共享文件** `architecture-vocabulary.md`，本 skill 与 `/tech-design` 共同引用。

## 主要改动

- **去掉 grilling 后续**：mattpocock 版在报告后调用 `grilling`/`domain-modeling` 收敛方案。我们**不内联也不保留**——深化实施走我们自己的 `/story` 流程（`/to-prd`、`/tech-design`、`/crystallize` 已在流程里）。本 skill 止步于"报告 + 圈定候选 + 建 story 起点"。
- **落地 = 创建 N 个 story**：用户可多选候选，每个创建一个 `.aiassist/stories/<id>/workflow-state.yaml`（初衷 = 深化机会），随后逐个 `/story` 推进。
- **词汇抽公共**：完整词汇表移出 SKILL.md，放在 `skills/tools/architecture-vocabulary.md`（共享文件，非 skill），本 skill 与 `/tech-design` 引用，避免两份维护。
- **frontmatter 惯例**：按本仓库去掉 `disable-model-invocation`，补 `sources:`。
- **边界显性化**："与相邻 skill 的边界"表明确本 skill 不负责实施。

## 未来局部更新建议

- mattpocock 的 `improve-codebase-architecture` 或 `codebase-design` 上游更新时，重点看：词汇表是否新增术语、HTML 报告 pattern 是否有新图式、报告流程是否有改进。grilling 相关更新与我们无关。
- `architecture-vocabulary.md` 更新时，同步检查 `/tech-design` 是否需要跟进。

## 改动记录

- 2026-08-16：新增 `/improve-codebase-architecture`，收 mattpocock 第一梯队独立工具；新增 `skills/tools/` bucket。
- 2026-08-16：重构——去掉内联 grilling/domain-modeling，落地改为创建 N 个 story 起点；词汇抽到 `architecture-vocabulary.md` 公共文件；`/tech-design` 一并引用。
