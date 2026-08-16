---
name: improve-codebase-architecture
description: 扫描既有代码库找架构深化机会（shallow→deep module），产出 HTML 报告，用户圈定要落地的候选并创建 N 个 story 起点。不做实施——深化在 story 流程内完成。独立触发，不绑定 story。
sources:
  - reference/mattpocock/skills/engineering/improve-codebase-architecture/SKILL.md
  - reference/mattpocock/skills/engineering/codebase-design/SKILL.md
  - architecture-vocabulary.md
---

# improve-codebase-architecture

## 何时调用

用户想系统性地改善**既有代码库**的架构、可测试性或 AI 可导航性，而非设计新功能时：

- "我们的代码库哪里最该重构？""哪个模块最难测 / 最难让 AI 读懂？"
- 想给一段历史代码找深化方向（把浅层模块合并成 deep module）。
- 想先看清架构摩擦点，再决定要不要立项去做。

**不调用的情况**：

- 新功能的模块边界 / 数据流 / 接口契约设计 → 走 `/tech-design`（`complex` story）。
- 审查已提交的改动或文档 → 走 `/review`。
- 单 bug 定位与修复 → 走 `/bug`。
- 想建立领域词汇 / 更新 `CONTEXT.md` → 走 `/domain-model`。

## 输入

- `--scope`（可选）：明确的关注方向（一个模块、一个子系统、一个痛点）。给了就直接用它，跳过下面的热点推断。
- 无 `--scope` 时：从 `git log` 回看近期热点，把最近反复出现的路径作为优先扫描区。

## 输出

1. **HTML 报告**：写入系统临时目录 `$TMPDIR`（fallback `/tmp` 或 `%TEMP%`），文件名 `architecture-review-<timestamp>.html`。**不落地 repo**。写完自动打开（`open` / `xdg-open` / `start`）并告知绝对路径。
2. **N 个 story 起点**：用户从报告圈定的每个候选 → 创建 `.aiassist/stories/<id>/workflow-state.yaml`（初衷 = 该深化机会），供用户逐个走 `/story` 在流程内实施深化。

## 架构词汇

本 skill 用 **deep-module 词汇**做语言基础——完整定义见 [architecture-vocabulary.md](../architecture-vocabulary.md)（共享公共词汇文件，供本 skill 与未来架构类 skill 复用；`/tech-design` 也引用它）。执行时用它命名与评估，禁止漂移。

**用词纪律**：只使用 module / interface / implementation / depth / deep / shallow / seam / adapter / leverage / locality；禁止替换为 component/service/unit、API/signature、boundary、layer/wrapper。Wins bullets 用词汇表术语命名收益，不写 "easier to maintain" 或 "cleaner code"。

## 执行步骤

### 1. 扫描（Explore）

**先定范围再扫——YAGNI。** 深化一个模块的价值在于让未来改动更容易，所以给近期频繁变动的部分加权。定了范围再动手：

- 用户给了方向 → 直接用它，跳过推断。
- 否则 `git log --oneline` 回看一段，找代码库热点（反复出现的文件/区域），让这些路径先吸引注意。改动分散无热点就放宽网。
- 先读领域词汇（`CONTEXT.md`）与相关区域的 ADR——命名好 seam，且不重提已被 ADR 否决的方案。

派一个 sub-agent 走查代码库。不要套僵硬启发式——有机地探索，记录你感到摩擦的地方：

- 理解一个概念要跨多少个小模块跳转？
- 哪里是 **shallow**——interface 复杂度和 implementation 几乎一样？
- 哪里为了可测性抽了纯函数，但真正的 bug 藏在调用方式里（没有 locality）？
- 哪里紧耦合的模块在 seam 处泄漏？
- 哪些部分没测、或无法透过当前 interface 测？

对任何怀疑是 shallow 的东西应用 **deletion test**：删掉它复杂度会集中，还是只是搬家？"会集中"正是你要的信号。

### 2. 产出候选（HTML 报告）

写一个自包含 HTML 文件到临时目录（见[输出](#输出)），打开并告知路径。结构见 [HTML-REPORT.md](HTML-REPORT.md)：每个候选一张卡片（Files / Problem / Solution / Wins / Before-After 图 / 推荐强度徽标 + 依赖类别 tag），末尾 Top recommendation。

**语言纪律**：用词汇表术语；`CONTEXT.md` 有领域概念就用它命名（"Order intake module"而非 "OrderService"）。

**ADR 冲突**：候选与既有 ADR 矛盾时，只在摩擦真实到值得重开 ADR 时才浮出，并在卡片里明确标注（"contradicts ADR-0007 — but worth reopening because…"）。不把 ADR 禁止的每个理论重构都列出来。

**这一步只呈现机会，不提 interface 方案。** 深化方案在 story 流程内定。

### 3. 落地：圈定候选，创建 story

用户在报告上圈定要落地的候选——**可多选，N 个**（一个深化机会 = 一个 story）。对每个选中的候选：

1. **生成 story-id**：`日期-短描述`（如 `2026-08-16-deepen-order-intake`）。短描述用深化动作命名，不用候选序号。
2. **创建 story 骨架**：`.aiassist/stories/<id>/workflow-state.yaml`，结构仿 `/story` 初始化（`templates/story/workflow-state.yaml.template`）：
   - `story_id`: `<id>`
   - `intention`: 该深化机会的**一句话痛点**，用词汇表术语，**非方案**（例："Order intake pipeline 是 6 个浅层模块，Pricing 逻辑在 seam 处泄漏，改动一次跨 N 处"）
   - `phase: THINK`（初衷已明确，进入需求/方案细化）
   - `created` + `history` 记录一条创建记录
3. **不要在 story 内预填方案**：深化方案、模块边界、接口契约、测试 seam 都留给该 story 的 `/to-prd`、`/tech-design`、`/crystallize` 流程。

全部创建后，向用户汇报：

- 报告路径（如需重看）
- 创建了 N 个 story：列出 story-id + 初衷一句话
- 下一步：逐个 `/story` 进入，从 PRD 开始推进深化；用户可自行决定每个 story 的优先级与先后

**本 skill 到此为止**——不做 grilling 收敛方案、不更新 CONTEXT.md、不写 interface、不写测试。发现与落地交给用户，实施归 story 流程。

## 输出格式

HTML 报告的完整规范见 [HTML-REPORT.md](HTML-REPORT.md)。要点：

- 单文件自包含；Tailwind + Mermaid 走 CDN；其余静态无脚本。
- 五种 diagram pattern（Mermaid graph / 手绘盒箭 / cross-section / mass diagram / call-graph collapse），混用以避免千篇一律。
- 铁律：**"If the diagram needs a paragraph to be understood, redraw the diagram."**
- Wins bullets ≤6 词，必须用词汇表术语（"locality: bugs concentrate in one module"）。

## 纪律

1. **只发现不实施**：本 skill 止步于"报告 + 圈定 + 建 story 起点"。不 grilling 方案、不更新 CONTEXT.md/ADR、不写 interface/测试——这些都归 story 流程。
2. **词汇纪律**：只用词汇表术语（见[架构词汇](#架构词汇)）；禁止漂移。Concision 不是漂移的借口。
3. **YAGNI 扫描**：范围前置，热点优先；不扫全库。
4. **不重开 ADR**：除非摩擦真实到值得重开，否则不浮出被 ADR 否决的方案。
5. **不落地 repo**：HTML 报告只写临时目录；不留架构评审工件在项目里（story 起点除外）。
6. **决策是用户的**：圈定哪些候选、是否建 story、建几个，都由用户定；只提供信息与推荐强度。

## 与相邻 skill 的边界

| Skill | 负责 | 不负责 |
|---|---|---|
| `/improve-codebase-architecture` | 扫描既有代码库、产出深化机会报告、建 story 起点 | 深化实施、story 内容 |
| `/story` | story 流程总入口；对每个已建 story 起点做 PRD→测试→实现→验收 | 架构扫描 |
| `/tech-design` | 复杂 story 内的技术方案深潜（模块边界/数据流/接口契约） | 既有代码库的主动扫描 |
| `/review` | 审查已提交的改动 / PRD / 技术方案 | 主动找摩擦点 |
| `/domain-model` | 维护 `CONTEXT.md` 领域词汇 | 架构深化决策 |

## 示例

```bash
/improve-codebase-architecture
# 无 --scope：git log 热点优先，报告多个候选，用户圈定 2 个 → 创建 2 个 story 起点
```

```bash
/improve-codebase-architecture --scope="payment intake pipeline"
# 定点一个子系统，跳过热点推断，报告该子系统内候选
```
