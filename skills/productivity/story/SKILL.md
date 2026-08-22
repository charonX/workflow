---
name: story
description: "循环工作流总入口。管理 story 生命周期:读取 workflow-state 路由到当前阶段(外层人控设计循环 / 内层 agent 实现循环),在签核门切换循环,并在发现根本问题时执行回流。"
sources:
  - workflow/design/workflow-framework.md
  - workflow/design/test-as-contract-workflow.md
  - reference/gstack/CLAUDE.md
  - reference/superpowers/skills/subagent-driven-development/SKILL.md
---

# story

本 skill 是工作流总入口,承担三件事:

1. **路由**:读 `workflow-state.yaml`,把用户送进当前 story 所处的阶段。
2. **循环切换**:在 assertion-signoff(门 1)把外层设计循环交给内层实现循环;在 reflect(门 2)把内层实现循环交回外层验收与知识沉淀。
3. **回流**:当用户发现"根本问题"时,执行归档重做或删 story。

## 核心概念:两个循环 + story = 初衷

- **外层循环 - 人控制的设计上下文**:THINK -> PRD -> DESIGN -> DOMAIN-MODEL -> TECH-DESIGN ->（自动链）CRYSTALLIZE -> TEST -> ASSERTION-SIGNOFF。前半段（需求/PRD/design/领域/技术）人做决定、改需求；REQ/test/断言签核由自动链 AI 完成，仅在升级点停下问人。
- **内层循环 - agent 控制的实现迭代**:BUILD -> QA -> BUG。AI 在测试契约内自主迭代，bug 处理后进入 REFLECT。
- **门 1(assertion-signoff)**:外层循环的终点,把完整上下文(REQ + 测试)交给 AI。签核默认 AI 全量自检完成,仅在升级点停下由人确认。
- **门 2(reflect)**:内层循环的终点,人做最终验收确认并沉淀知识。

一个 story 对应一个**初衷**--用户痛点,不是具体方案。

- 初衷在,story 就在。实现路径错了(无论一挡二挡),换实现,story 不换 -> **归档重做**。
- 初衷本身错了/痛点不成立,story 没存在意义 -> **删 story**,不归档。

初衷的锚点是 PRD 的"问题陈述"--`/to-prd` 强制把它写成痛点形态。

## 输入

- `.aiassist/stories/<id>/workflow-state.yaml`(已存在 story)
- 用户的当前意图(新建 / 继续 / 回流)

## 路由:开始或继续一个 story

### A. 新建 story

1. 与用户确认初衷(一句话痛点,不是方案)。
2. 生成 story-id(日期+短描述,如 `2026-07-02-mood-tracking`)。
3. 从模板创建:
   - `templates/story/workflow-state.yaml.template` -> `.aiassist/stories/<id>/workflow-state.yaml`
4. 把 phase 设为 `THINK`,attempt 记为 1。
5. 调用 `/demand-insight` 进入需求洞察。

> **引用规则（已完成 story）**：新 story 收集上下文时，逻辑真值看代码、意图真值看全局文档（`adr/`、`business-capabilities.md`、`CONTEXT.md`、`STANDARDS.md`）。已完成 story 的 spec **不保留**——`/reflect` 收尾时整个 story 目录提交删除（进 git 历史，`git show` 可回溯）；已完成 story 不回流，回流判断只发生在进行中 story。

### B. 继续 story

1. 读 `workflow-state.yaml`。
2. 按 `phase` 路由:

| 当前 phase | 所属循环 | 路由到 |
|---|---|---|
| THINK | 外层 | `/demand-insight` |
| PRD | 外层 | `/to-prd` |
| DESIGN | 外层 | `/design` |
| DOMAIN-MODEL | 外层 | `/domain-model` |
| TECH-DESIGN | 外层 | `/tech-design`（**仅 PRD §9=complex 时走**；simple 直接结晶，路由到此阶段时提示可跳过。若对技术/API/库不熟，可先 `/research`） |
| CRYSTALLIZE | 外层 | 自动链：`/crystallize` → `/test-author` → `/signoff`（见"自动链"） |
| TEST | 外层 | 同上（自动链续跑） |
| ASSERTION-SIGNOFF | **门 1** | 同上（自动链收尾；升级点停下问人） |
| BUILD | 内层 | `/implementer` |
| QA | 内层 | `/qa-runner` |
| BUG | 内层/外层交界 | `/bug` |
| REFLECT | **门 2** | `/reflect` |

3. 向后兼容：若读取到旧版 `phase: FEEL-SIGNOFF`，向用户说明 feel-signoff 已合并到 reflect，自动迁移到 `REFLECT` 阶段，追加历史记录 `{from: FEEL-SIGNOFF, to: REFLECT, note: "自动迁移：feel-signoff 已合并到 reflect"}`，然后路由到 `/reflect`。

4. 向后兼容：若读取到旧版 `phase: BUG_TRIAGE` 或 `BUG_FIX`，向用户说明 bug 循环已合并为单 skill `/bug`，自动迁移到 `BUG` 阶段，追加历史记录 `{from: BUG_TRIAGE|BUG_FIX, to: BUG, note: "自动迁移：file-bug+fix-bugs 已合并为 /bug"}`，然后路由到 `/bug`。

5. 若 `archive` 下已有历史 attempt,提示用户:"本 story 已尝试过 N 次,最新归档原因见 `archive/attempt-N/reason.md`,这次别踩同样的坑。"

### 自动链（CRYSTALLIZE → TEST → ASSERTION-SIGNOFF）

路由到 CRYSTALLIZE 时进入自动链：**一次会话**连续执行 `/crystallize` → `/test-author` → `/signoff --stage=assertion`，phase 由各 skill 显式推进（crystallize → `TEST`，test-author → `ASSERTION-SIGNOFF`，signoff → `BUILD`）。中间不打断用户，仅在升级点停下询问。

- **升级点**（停下问人，phase 停在对应阶段）：范围决策（新建 story / 范围外）、expected 值推导不出且无法就地补、跨模块契约歧义、安全边界、初衷漂移信号。
- **无升级** → 零打断跑完，输出摘要（REQ 数、测试数、signoff 结果、升级项日志），phase 置为 `BUILD`。用户审阅后重调 `/story` 进入实现。
- **续跑**：升级点回答后，重调 `/story` 会从当前 phase 继续自动链（如停在 TEST 则从 test-author 续到 signoff）。
- **单独调用**：想逐阶段确认时，可绕过 `/story` 直接调 `/crystallize`、`/test-author`、`/signoff`，各 skill 行为相同（默认自动 + 升级）。

### C. Story 内的 bug 处理（可选）

二挡（测试锁定）后发现 bug 时，不直接回流整个 story，而是用 `/bug` 单 bug 人机协同处理：

```
BUILD/QA 发现异常 -> BUG (/bug) -> QA
```

当 QA 全绿且当前 story 无 open bug 时，进入 `/reflect`（门 2：最终验收 + 知识沉淀）。

- `/bug` 一次处理一个 bug：诊断根因 -> 分类（人确认：code-defect / test-gap / req-gap / not-a-bug）-> 修 / 补测试 / 就地补全 / 关闭 -> 三道闸门（3-strike / blast-radius / req-gap）-> commit -> 停下，人决定下一个。
- 不落本地 bug 工件；追溯靠 `// REQ-TRACE` + commit `[bugfix] BUG-NNN`（见 `design/adr/0002-single-bug-fix-loop.md`）。
- `test-gap` 补测试；`req-gap` 就地补全 PRD/tech/REQ/HTML + 补测试；`not-a-bug` 关闭记录。
- 全量回归不在 `/bug` 内跑，由 `/qa-runner` 收尾时跑。

### D. 手动审查（可选但建议）

`/review` 是建议性门：一次调用按 cover 层并行派发 specialist 子代理，汇总一份 `review.md` 报告，由人决定是否继续、修复后重审，或回流。最好在新会话中执行。

**默认建议一处末端统一审查**：

| 审查时机 | 命令 | 审查内容 | 通过后可进入 |
|---|---|---|---|
| QA 全绿后、REFLECT 前 | `/review`（默认全层） | 全链五层：PRD（含 §10 技术方案、§11 测试决策）+ REQ + 测试 + 实现 diff | REFLECT |

高风险 story 可随时聚焦审查某层（如 `--cover=req,test` 只审自动链产物），但默认流不在中途设置建议检查点。

## 回流:发现根本问题时

### 第一步:根因诊断(必做,不跳过)

任何回流前,先和用户一起判定**错误假设活在哪一层**。模型提议,人拍板。

- 错误在用户需求/痛点本身 -> 走"删 story"。
- 错误在实现路径(方案/REQ/UX 方向) -> 走"归档重做"。
- 错误只是 REQ 漏了个 case / 断言自相矛盾 -> **不算回流**,走局部纠错(`/crystallize` 补验收标准,或重跑自动签核/升级给人,或逃生口)。见下文"不算回流的情况"。

判定标准:初衷(问题陈述里的痛点)还成立吗?
- 成立 -> 归档重做。
- 不成立 -> 删 story。

### 第二步:执行

#### 归档重做(初衷不变,实现路径错了)

1. **归档本次 attempt**:
   - 创建 `.aiassist/stories/<id>/archive/attempt-<N>/`。
   - 移入**承诺层产物**:`prd.md`（含 §10 技术方案）、`requirements.md`、`requirements-*.hash`、`signoff.md`、`qa-report.md`、相关代码。
   - **不归档**:`ux/`(一挡思考工具,直接改)、`interview-notes.md`(软的)、`workflow-state.yaml`(状态机本身,要更新不是归档)。
2. **写归档原因**:`archive/attempt-<N>/reason.md`,记录根因(错误假设活在哪一层)+ 推翻理由 + 下次该避开什么。这是下次 `/demand-insight` 的关键输入。
3. **更新 workflow-state**:
   - `attempt` +1。
   - `phase` 回到根因层对应阶段:根因在需求层 -> `THINK`;在方案层 -> `PRD`;在技术方案层 -> `TECH-DESIGN`(语义 = 重做 `prd.md` §10,仅 complex story);在 UX 暴露的约束层 -> `DESIGN`。
   - `history` 追加一条:`{from, to, reason, date}`。
4. **同 story 重做**:从回退后的 phase 起跑。UX 原型留在 `ux/` 直接改,不搬。

#### 删 story(初衷本身错了)

1. 与用户确认:痛点不成立,不是"换个实现能救"的。
2. 整个 `.aiassist/stories/<id>/` 删除,**不归档**--没有初衷可参考,留证据无意义。
3. 从 `.aiassist/stories/` 索引(如有)移除。

### 不算回流的情况(走局部纠错,不动 story 结构)

| 情况 | 机制 | 动作 |
|---|---|---|
| QA 验收发现意图缺口（req-gap：REQ/PRD 漏或错、缺测试 seam、HTML 参照小改）——**默认收敛路径** | bug 处理中就地补全 | `/bug` 就地补全 PRD（含 §10 技术方案）/REQ/测试（REQ 漏 case 走 `/crystallize`），继续修；缺口超出当前 story 范围 → 与用户显式归类：新建 story 或归入范围外 |
| 断言自相矛盾/不可满足 | 逃生口 | 重跑自动签核，重审受影响断言（可升级给人） |
| 实现者烧完轮数不绿 | 逃生口 | 上报，换模型或重审契约（升级给人） |
| 一挡内某块被推翻 | 按块回流 | 该块降级回"移动块",其它块不动,UX 直接改 |

按块回流(一挡内)不创建 `archive/attempt-N/`,只在 PRD 里把该块从"稳定块"挪回"移动块"。归档是 **story 级**动作,只在整个实现路径错了时用。

## workflow-state.yaml 结构

```yaml
story_id: 2026-07-02-mood-tracking
intention: <一句话痛点,非方案>
phase: THINK              # THINK/PRD/DESIGN/DOMAIN-MODEL/TECH-DESIGN/CRYSTALLIZE/TEST/ASSERTION-SIGNOFF/BUILD/QA/BUG/REFLECT
                          # CRYSTALLIZE/TEST/ASSERTION-SIGNOFF 由自动链一次推进，仅升级点停下；其余逐阶段路由
attempt: 1
bug-counter: 0            # story 内 bug 计数，/bug 每次修复 +1
created: 2026-07-02
history:
  - {at: 2026-07-02, from: THINK, to: PRD, note: "完成需求洞察"}
  - {at: 2026-07-03, from: BUILD, to: PRD, note: "方案层假设错,归档 attempt-1,见 archive/attempt-1/reason.md"}
archive:
  - {attempt: 1, date: 2026-07-03, reason_file: archive/attempt-1/reason.md}
```

## 纪律

- **初衷锚定痛点**:`intention` 字段和 PRD 问题陈述必须是用户痛点,不是方案。方案会变,痛点不会。
- **根因诊断优先**:回流前必判"初衷在不在"。模型提议,人拍板。不跳过。
- **归档不删,删不归档**:初衷在 -> 归档(留证据);初衷错 -> 删(不留)。
- **UX 不归档**:一挡思考工具,直接改。
- **按块回流不建 attempt**:一挡内单块推翻,只挪 PRD 的稳定/移动块标记。
- **回流是人触发的重大判断**:模型可提议,但不自动执行归档或删除。

## 与参考项目的差异

- gstack 的 `/ship` 等只管前进;我们显式管理回流和 story 生命周期。
- superpowers 的 executing-plans 假设计划稳定;我们承认一挡会推翻,把推翻做成结构化动作。
- 核心:把"推倒重来"从隐性的失败,变成显式的、留证据的、可学习的动作。
