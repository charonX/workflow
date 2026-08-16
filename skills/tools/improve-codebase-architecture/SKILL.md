---
name: improve-codebase-architecture
description: 扫描代码库找"深化机会"（shallow→deep module），产出自包含 HTML 报告，再轮询 grilling 用户选中的候选。用 module/interface/seam/depth 词汇做测试性与 AI 可导航性视角的架构评审。不绑定 story，独立触发。
sources:
  - reference/mattpocock/skills/engineering/improve-codebase-architecture/SKILL.md
  - reference/mattpocock/skills/engineering/codebase-design/SKILL.md
  - reference/mattpocock/skills/engineering/codebase-design/DEEPENING.md
  - reference/mattpocock/skills/productivity/grilling/SKILL.md
---

# improve-codebase-architecture

## 何时调用

用户想系统性地改善**既有代码库**的架构、可测试性或 AI 可导航性，而非设计新功能时：

- "我们的代码库哪里最该重构？""哪个模块最难测 / 最难让 AI 读懂？"
- 想给一段历史代码找一个深化方向（把浅层模块合并成 deep module）。
- 想用报告 + 访谈的方式把架构摩擦点摆到桌面上再逐个决定。

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
2. **副作用**（grilling 决策落地时）：
   - 为深化模块命名了新领域概念 → 更新 `CONTEXT.md`（不存在则 lazy 创建）。
   - 用户以承重理由拒绝候选 → 询问是否记为 ADR，避免未来评审重复建议同一方案。

## 架构词汇表

整个 skill 的语言基础。**用这些术语，禁止漂移**到 component/service/API/boundary。

| 术语 | 定义 | 避免 |
|---|---|---|
| **Module** | 任何有 interface + implementation 的东西，刻意 scale-agnostic（函数/类/包/跨层切片） | unit, component, service |
| **Interface** | 调用者正确使用所需知道的一切：签名 + 不变量、顺序约束、错误模式、配置、性能特征 | API, signature（太窄） |
| **Implementation** | 模块内部。与 Adapter 区分：adapter 描述"角色"，implementation 描述"内容" | — |
| **Depth** | interface 处的 leverage：每单位需要学习的 interface 能驱动多少行为。deep = 大行为藏在小 interface 后；shallow = interface 复杂度≈implementation | 行数比（Ousterhout，奖励 padding） |
| **Seam** | 不改代码就能改变行为的位置；interface 所在之处 | boundary（与 DDD bounded context 冲突） |
| **Adapter** | 在 seam 处满足 interface 的具体物，描述角色而非内容 | — |
| **Leverage** | 调用者收益：一个 implementation 回报 N 个调用点 + M 个测试 | "easier to maintain" |
| **Locality** | 维护者收益：变更/bug/知识/验证集中一处，fix once, fixed everywhere | "cleaner code" |

**四条原则**：

1. **Depth 是 interface 的属性，不是 implementation 的**。模块可以有内部 seam（私有、供自身测试）与外部 seam（interface 处）。
2. **Deletion test**：假想删掉模块——复杂度消失说明是 pass-through；复杂度在 N 个调用者处重现说明它物有所值。
3. **The interface is the test surface**：调用者和测试过同一个 seam；想"绕过 interface 测内部"说明模块形状错了。
4. **One adapter = hypothetical seam, two = real**：没有真实变化就不要引入 seam。

**依赖四分类**（评估候选时给依赖归类，决定深化后的模块怎么跨 seam 测试）：

| 类别 | 判定 | 测试策略 |
|---|---|---|
| in-process | 纯计算/内存态，无 I/O | 直接合并，透过新 interface 测，无需 adapter |
| local-substitutable | 有本地替身（PGLite、内存文件系统） | 用替身跑测试；seam 内部化，模块外部无 port |
| remote-but-owned（ports & adapters） | 自己的跨网络服务 | 在 seam 定义 port；逻辑在 deep module，transport 注入为 adapter；测试用 in-memory adapter |
| true-external（mock） | 第三方服务（Stripe/Twilio） | 注入为 port；测试用 mock adapter |

**测试策略：replace, don't layer** —— 深化模块的 interface 测试就位后，删掉浅层模块的旧单测（变废了）；新测试断言 interface 可观察结果，不测内部状态；测试应能存活于内部重构（若实现变了测试就要变，说明在测 interface 之外）。

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

**这一步不要提 interface 方案。** 写完后问用户："你想深挖哪个？"

### 3. 轮询 grilling

用户选中候选后，用 **round-based frontier** 模式推进（与 `/demand-insight` 的轮询澄清同构，这里用于架构决策树）：

- 把对话建模为 **design tree**——每个决策分叉出悬挂决策。
- **frontier** = 前置已全部 settled、现在就能问的问题。**一轮问完整条 frontier**，每题编号 + 给出推荐答案。
- 用户回答后重算 frontier 进下一轮；依赖本轮未决答案的问题留到更晚的轮次。
- 事实自己查（派 sub-agent 找环境事实，不阻塞；运行中的探索算"未决前置"，只有下游问题等它）。
- 结束条件 = frontier 为空且用户确认达成共识，**在此之前不得行动**。

决策落地时的副作用（内联规则）：

- 给深化模块命名了新概念且不在 `CONTEXT.md` → 更新 `CONTEXT.md`（lazy 创建）。
- 谈话中澄清了模糊术语 → 就地更新 `CONTEXT.md`。
- 用户以承重理由拒绝候选 → 问："要记为 ADR 吗？免得未来评审再提同案。"只在该理由对未来探索者确实必要才 offer（跳过"现在不值得"这类短暂理由与自明的理由）。
- 想探索替代 interface → 并行 sub-agent 各出激进不同的 interface 方案，按 depth / locality / seam placement 对比再给意见。

## 输出格式

HTML 报告的完整规范见 [HTML-REPORT.md](HTML-REPORT.md)。要点：

- 单文件自包含；Tailwind + Mermaid 走 CDN；其余静态无脚本。
- 五种 diagram pattern（Mermaid graph / 手绘盒箭 / cross-section / mass diagram / call-graph collapse），混用以避免千篇一律。
- 铁律：**"If the diagram needs a paragraph to be understood, redraw the diagram."**
- Wins bullets ≤6 词，必须用词汇表术语（"locality: bugs concentrate in one module"）。

## 纪律

1. **术语纪律**：只用 module/interface/implementation/depth/deep/shallow/seam/adapter/leverage/locality；禁止替换为 component/service/unit、API/signature、boundary、layer/wrapper。Concision 不是漂移的借口。
2. **YAGNI 扫描**：范围前置，热点优先；不扫全库。
3. **不重开 ADR**：除非摩擦真实到值得重开，否则不浮出被 ADR 否决的方案。
4. **不落地 repo**：HTML 报告只写临时目录；不留架构评审工件在项目里。
5. **决策是用户的**：只提候选与推荐答案，不下 interface 方案；达成共识前不行动。
6. **不重复已否决方案**：用户以承重理由拒绝的候选，经 ADR 固化后不再重复建议。

## 与相邻 skill 的边界

| Skill | 负责 | 不负责 |
|---|---|---|
| `/improve-codebase-architecture` | 扫描既有代码库、产出深化机会报告、轮询收敛架构决策 | 新功能设计、PRD、story 产物 |
| `/tech-design` | 复杂 story 的技术方案深潜（模块边界/数据流/接口契约），写入 `prd.md` §10 | 既有代码库的主动扫描 |
| `/review` | 审查已提交的改动 / PRD / 技术方案 | 主动找摩擦点 |
| `/domain-model` | 维护 `CONTEXT.md` 领域词汇 | 架构深化决策 |
| `/demand-insight` | 用户痛点 / 需求边界的轮询访谈 | 架构访谈 |

## 示例

```bash
/improve-codebase-architecture
# 无 --scope：git log 热点优先，报告多个候选，用户挑一个轮询收敛
```

```bash
/improve-codebase-architecture --scope="payment intake pipeline"
# 定点一个子系统，跳过热点推断
```
