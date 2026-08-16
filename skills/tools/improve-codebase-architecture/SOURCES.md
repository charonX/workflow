# 参考来源：improve-codebase-architecture

## 理念

循环工作流擅长"从需求到实现"的新功能路径，但没有一个 skill 主动审视**既有代码库的架构摩擦点**。`/improve-codebase-architecture` 补这个缺口：以 module/interface/seam/depth 词汇（而非模糊的 component/service）扫描代码库，把"深化机会"以可交互 HTML 报告呈现，再用 round-based frontier 轮询收敛。视角独特：测试性与 **AI 可导航性**（locality 让 AI 与人都能在一个模块内理解变更）。

## 借鉴的 reference 文件

- `reference/mattpocock/skills/engineering/improve-codebase-architecture/SKILL.md`：主体流程（Explore → HTML 报告 → grilling loop）。
- `reference/mattpocock/skills/engineering/improve-codebase-architecture/HTML-REPORT.md`：HTML 报告规范（scaffold、五种 diagram pattern、tone 纪律）。
- `reference/mattpocock/skills/engineering/codebase-design/SKILL.md`：架构词汇表（8 术语 + 四原则 + 可测性三条），内联进本 skill 的[架构词汇表](#架构词汇表)。
- `reference/mattpocock/skills/engineering/codebase-design/DEEPENING.md`：依赖四分类与 replace-don't-layer 测试策略，内联进[依赖四分类](#依赖四分类)。
- `reference/mattpocock/skills/productivity/grilling/SKILL.md`：round-by-round frontier 模式，内联进[轮询 grilling](#3-轮询-grilling)，与我们 `/demand-insight` 已有的轮询澄清同构。

## 主要改动

- **自包含化**：mattpocock 版通过 Skill tool 调用 `codebase-design`/`grilling`/`domain-modeling` 三个依赖 skill。我们将其**内联**为一个词汇表 + 四原则 + 依赖四分类 + 轮询流程，单个 SKILL.md 自成一体，不依赖跨 skill 调用。
- **对齐我们的轮询惯例**：grilling loop 采用 round-based frontier 表述，与 `/demand-insight` 的轮询澄清保持一致；不再依赖 mattpocock 的 grilling skill。
- **frontmatter 惯例**：按本仓库去掉 `disable-model-invocation`，补 `sources:`。
- **边界显性化**：新增"与相邻 skill 的边界"表，明确与 `/tech-design`、`/review`、`/domain-model` 的职责切分（本 skill 不绑定 story、不产生 `.aiassist/` 产物）。

## 未来局部更新建议

- mattpocock 的 `improve-codebase-architecture` 或 `codebase-design` 上游更新时，重点看：词汇表是否新增术语、依赖四分类是否有新类别、HTML 报告 pattern 是否有新图式。
- 若我们 `/tech-design` 未来统一采用 deep-module 词汇，考虑抽公共词汇文件避免两份维护。

## 改动记录

- 2026-08-16：新增 `/improve-codebase-architecture`，收 mattpocock 第一梯队独立工具。新增 `skills/tools/` bucket。
