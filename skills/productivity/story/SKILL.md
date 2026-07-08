---
name: story
description: "双循环工作流总入口。管理 story 生命周期:读取 workflow-state 路由到当前阶段(外层人控设计循环 / 内层 agent 实现循环),在签核门切换循环,并在发现根本问题时执行回流。"
disable-model-invocation: true
sources:
  - workflow/design/workflow-framework.md
  - workflow/design/test-as-contract-workflow.md
  - reference/gstack/CLAUDE.md
  - reference/superpowers/skills/subagent-driven-development/SKILL.md
---

# story

本 skill 是工作流总入口,承担三件事:

1. **路由**:读 `workflow-state.yaml`,把用户送进当前 story 所处的阶段。
2. **循环切换**:在 assertion-signoff(门 1)把外层设计循环交给内层实现循环;在 feel-signoff(门 2)把内层实现循环交回外层验收/回流。
3. **回流**:当用户发现"根本问题"时,执行归档重做或删 story。

## 核心概念:两个循环 + story = 初衷

- **外层循环 — 人控制的设计上下文**:THINK → PRD → DESIGN → DOMAIN-MODEL → TECH-DESIGN → CRYSTALLIZE → TEST → ASSERTION-SIGNOFF。人做决定、签核、改需求。
- **内层循环 — agent 控制的实现迭代**:BUILD → QA。AI 在测试契约内自主迭代到全绿。
- **门 1(assertion-signoff)**:外层循环的终点,把完整上下文(REQ + 测试)交给 AI。
- **门 2(feel-signoff)**:内层循环的终点,人验收 AI 产出;不通过则回流到外层循环修设计。

一个 story 对应一个**初衷**——用户痛点,不是具体方案。

- 初衷在,story 就在。实现路径错了(无论一挡二挡),换实现,story 不换 → **归档重做**。
- 初衷本身错了/痛点不成立,story 没存在意义 → **删 story**,不归档。

初衷的锚点是 PRD 的"问题陈述"——`/to-prd` 强制把它写成痛点形态。

## 输入

- `.aiassist/stories/<id>/workflow-state.yaml`(已存在 story)
- 用户的当前意图(新建 / 继续 / 回流)

## 路由:开始或继续一个 story

### A. 新建 story

1. 与用户确认初衷(一句话痛点,不是方案)。
2. 生成 story-id(日期+短描述,如 `2026-07-02-mood-tracking`)。
3. 从模板创建:
   - `templates/story/workflow-state.yaml.template` → `.aiassist/stories/<id>/workflow-state.yaml`
4. 把 phase 设为 `THINK`,attempt 记为 1。
5. 调用 `/demand-insight` 进入需求洞察。

### B. 继续 story

1. 读 `workflow-state.yaml`。
2. 按 `phase` 路由:

| 当前 phase | 所属循环 | 路由到 |
|---|---|---|
| THINK | 外层 | `/demand-insight` |
| PRD | 外层 | `/to-prd` |
| DESIGN | 外层 | `/design` |
| DOMAIN-MODEL | 外层 | `/domain-model` |
| TECH-DESIGN | 外层 | `/tech-design`（若对技术/API/库不熟，可先 `/research`） |
| CRYSTALLIZE | 外层 | `/crystallize` |
| TEST | 外层 | `/test-author` |
| ASSERTION-SIGNOFF | **门 1** | `/signoff --stage=assertion` |
| BUILD | 内层 | `/implementer` |
| QA | 内层 | `/qa-runner` |
| FEEL-SIGNOFF | **门 2** | `/signoff --stage=feel` |
| REFLECT | 外层 | `/reflect` |

3. 若 `archive` 下已有历史 attempt,提示用户:"本 story 已尝试过 N 次,最新归档原因见 `archive/attempt-N/reason.md`,这次别踩同样的坑。"

### C. 手动审查（可选但建议）

以下关键转换点，建议人手动触发 `/review`，最好在新会话中执行：

| 审查时机 | stage | 审查产物 | 通过后可进入 |
|---|---|---|---|
| PRD 完成后 | `prd` | `prd.md` | TECH-DESIGN |
| 技术方案完成后 | `tech` | `prd.md` + `tech-design.md` | CRYSTALLIZE |
| BUILD 完成后 | `code` | diff + 全部契约文档 | QA |

`/review` 是建议性门，输出报告后由人决定是否继续、修复后重审，或回流。

## 回流:发现根本问题时

### 第一步:根因诊断(必做,不跳过)

任何回流前,先和用户一起判定**错误假设活在哪一层**。模型提议,人拍板。

- 错误在用户需求/痛点本身 → 走"删 story"。
- 错误在实现路径(方案/REQ/UX 方向) → 走"归档重做"。
- 错误只是 REQ 漏了个 case / 断言自相矛盾 → **不算回流**,走局部纠错(`/crystallize` 补验收标准,或门 1 重审,或逃生口)。见下文"不算回流的情况"。

判定标准:初衷(问题陈述里的痛点)还成立吗?
- 成立 → 归档重做。
- 不成立 → 删 story。

### 第二步:执行

#### 归档重做(初衷不变,实现路径错了)

1. **归档本次 attempt**:
   - 创建 `.aiassist/stories/<id>/archive/attempt-<N>/`。
   - 移入**承诺层产物**:`prd.md`、`tech-design.md`、`requirements.md`、`requirements-*.hash`、`signoff.md`、`qa-report.md`、相关代码。
   - **不归档**:`ux/`(一挡思考工具,直接改)、`interview-notes.md`(软的)、`workflow-state.yaml`(状态机本身,要更新不是归档)。
2. **写归档原因**:`archive/attempt-<N>/reason.md`,记录根因(错误假设活在哪一层)+ 推翻理由 + 下次该避开什么。这是下次 `/demand-insight` 的关键输入。
3. **更新 workflow-state**:
   - `attempt` +1。
   - `phase` 回到根因层对应阶段:根因在需求层 → `THINK`;在方案层 → `PRD`;在技术方案层 → `TECH-DESIGN`;在 UX 暴露的约束层 → `DESIGN`。
   - `history` 追加一条:`{from, to, reason, date}`。
4. **同 story 重做**:从回退后的 phase 起跑。UX 原型留在 `ux/` 直接改,不搬。

#### 删 story(初衷本身错了)

1. 与用户确认:痛点不成立,不是"换个实现能救"的。
2. 整个 `.aiassist/stories/<id>/` 删除,**不归档**——没有初衷可参考,留证据无意义。
3. 从 `.aiassist/stories/` 索引(如有)移除。

### 不算回流的情况(走局部纠错,不动 story 结构)

| 情况 | 机制 | 动作 |
|---|---|---|
| REQ 漏了一个 case | `/signoff --stage=feel` 已有 | 回 `/crystallize` 补验收标准增量 |
| 断言自相矛盾/不可满足 | 逃生口 | 回门 1 重审断言 |
| 实现者烧完轮数不绿 | 逃生口 | 上报,换模型或回门 1 |
| 一挡内某块被推翻 | 按块回流 | 该块降级回"移动块",其它块不动,UX 直接改 |

按块回流(一挡内)不创建 `archive/attempt-N/`,只在 PRD 里把该块从"稳定块"挪回"移动块"。归档是 **story 级**动作,只在整个实现路径错了时用。

## workflow-state.yaml 结构

```yaml
story_id: 2026-07-02-mood-tracking
intention: <一句话痛点,非方案>
phase: THINK              # THINK/PRD/DESIGN/DOMAIN-MODEL/TECH-DESIGN/CRYSTALLIZE/TEST/ASSERTION-SIGNOFF/BUILD/QA/FEEL-SIGNOFF/REFLECT
attempt: 1
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
- **归档不删,删不归档**:初衷在 → 归档(留证据);初衷错 → 删(不留)。
- **UX 不归档**:一挡思考工具,直接改。
- **按块回流不建 attempt**:一挡内单块推翻,只挪 PRD 的稳定/移动块标记。
- **回流是人触发的重大判断**:模型可提议,但不自动执行归档或删除。

## 与参考项目的差异

- gstack 的 `/ship` 等只管前进;我们显式管理回流和 story 生命周期。
- superpowers 的 executing-plans 假设计划稳定;我们承认一挡会推翻,把推翻做成结构化动作。
- 核心:把"推倒重来"从隐性的失败,变成显式的、留证据的、可学习的动作。
