---
name: bug
description: 单 bug 人机协同处理。报告症状 -> 诊断根因 -> 分类（人确认裁决）-> 修/补测试/就地补全/关闭 -> 三道闸门 -> commit -> 停下。一次一个 bug，不批量；不落本地 bug 工件，追溯靠 REQ-TRACE + commit。支持从外部 issue 实时拉取。
sources:
  - reference/gstack/investigate/SKILL.md
  - reference/agent-skills/skills/debugging-and-error-recovery/SKILL.md
  - reference/mattpocock/skills/engineering/diagnosing-bugs/SKILL.md
  - reference/superpowers/skills/systematic-debugging/SKILL.md
  - workflow/design/test-as-contract-workflow.md
  - workflow/design/adr/0002-single-bug-fix-loop.md
---

# bug

单 bug 人机协同处理。一次调用一个 bug：诊断根因 -> 分类（人确认裁决）-> 按类别处置 -> 过三道闸门 -> commit -> 停下。**不落本地 bug 工件，不批量修。** 决策依据见 `design/adr/0002-single-bug-fix-loop.md`。

## 何时调用

- 用户在 story 内说"发现 bug"、"这里有问题"、"/bug"。
- `/qa-runner` 建议对某失败做 bug 处理。
- QA 通过后，用户发现实现与已批准 HTML UX 参照有偏差（观感/视觉/行为）。
- 用户想从外部 issue 拉取症状（`--from-issue=N`）。
- 用户确认外部 issue 已修复，想关闭（`--close-issue=N`）。

## 输入

- 当前 story ID（从 `workflow-state.yaml` 或 `.aiassist/stories/` 最近更新推导）
- `.aiassist/stories/<id>/prd.md`（含 §10 技术方案）、`requirements.md`、`signoff.md`、`ux/`
- 实现代码和测试文件
- `.aiassist/global/issue-tracker.json`（可选，外部 issue 用）
- bug 症状、复现步骤、期望/实际、环境、截图/日志（口述或 issue body）

## 输出

- 修复 commit `[bugfix] BUG-NNN: <summary>`（一个 bug 一个 commit）
- 失败回归测试（带 `// REQ-TRACE`），或新增测试
- 更新 `workflow-state.yaml`：phase `BUG`，`bug-counter` +1
- 外部 issue 中文评论（不关闭，等用户确认）

**不生成** `bugs/BUG-NNN.md`、`triage.md`、`bug-fix-report.md`（已废止，见 ADR 0002）。

## 执行步骤

### 1. 确定当前 story

读 `workflow-state.yaml` 的 `currentStory`，或取 `.aiassist/stories/` 下最近更新的目录。phase 设为 `BUG`。

### 2. 收集症状

向用户收集：症状（一句话）、复现步骤、期望 vs 实际、环境、截图/日志。

如果 `--from-issue=N`：
- `gh issue view N --json title,body,comments`（或 `glab`）拉取标题、正文、评论。
- **保留 body 中的图片 markdown**（`user-images.githubusercontent.com` URL 公开可访问），作为症状/复现步骤。
- issue 评论作为补充信息。issue body 是症状起点，仍需与用户确认/补充。

### 3. 诊断根因（Iron Law：无根因不修复）

- 读 `requirements.md` 找相关 REQ-ID，读现有测试判断覆盖情况。
- 复现：运行相关产品命令/测试，确认 bug 存在。
- 读实现代码，定位根因，形成**根因假设**。
- **把根因假设外显给用户**（参考 mattpocock：测试前把排序假设给人看）。用户不一定阻塞，但假设必须可见，人可用领域知识即时改判。

### 4. 分类（inline，人确认裁决）

| 类别 | 判定标准 | 处置 |
|---|---|---|
| **code-defect** | 实现偏离已签核 REQ（含功能缺陷和视觉/feel 偏差）；或测试本应暴露但该 case 未覆盖 | 进步骤 5 修复 |
| **test-gap** | 行为符合当前 REQ，但测试未覆盖该边界/路径 | `/test-author` 补测试；如测试暴露实现缺陷，转 code-defect |
| **req-gap** | REQ/PRD 未定义或定义错误；或已批准 HTML UX 参照本身要改；或诊断发现没有正确测试 seam | **就地补全**：增量更新 PRD（含 §10 技术方案）/REQ/HTML + 补测试 seam，回步骤 5 继续修。UX 方向/初衷级推翻则升级 `/story` 真回流。见步骤 8 |
| **not-a-bug** | 实际行为符合 REQ，只是用户预期不同 | 记录决策（commit note 或口述），不修。见步骤 9 |

分类必须引用相关 REQ-ID 或 PRD 段落，不凭猜测。**分类不是一次性赌注**：步骤 5 修复中若 3-strike 或 no-seam 信号出现，重分类为 req-gap 就地补全。

**向用户说明分类建议，由人确认**后继续（人可即时改判）。

### 5. 修复 code-defect

#### 5.1 确保有失败回归测试（Prove-It）

- 若已有测试覆盖该 bug：确认它能复现失败（红）。
- 若无：调 `/test-author` 生成回归测试，**修复前必须红**。这正是"根据 bug 添加新测试用例"。
- 回归测试头部必须有 `// REQ-TRACE`、`// CAPABILITY-TRACE`、`// ENTITY-TRACE`。

#### 5.2 修复实现

- 调 `/implementer` 的 fix subagent（带 bug 上下文：症状、复现、根因、关联 REQ、回归测试路径）。
- fix subagent 只改实现代码，对业务测试只读。
- 修复后跑该 bug 回归测试 + 受影响测试，确认红->绿。

#### 5.3 三道闸门

- **3-strike**：本 bug 3 次修复尝试仍未绿 -> STOP，向用户报告，评估 req-gap / 架构错（"3 次失败 = 架构错，不是假设错"）。不准试第 4 次。重分类走步骤 8。
- **blast-radius**：fix 触及 >5 文件 -> AskUserQuestion 确认范围后再提交。
- **req-gap 检测**：修复中发现根因其实是 REQ 漏/错/HTML 要改/no seam -> 走步骤 8 就地补全。

#### 5.4 提交

- BUG-NNN 取自 `workflow-state.yaml` 的 `bug-counter`，+1。
- commit：`[bugfix] BUG-NNN: <summary>`（issue-sourced 可附 `#N`）。
- 一个 bug 一个 commit，便于回滚。

### 6. 外部 issue 评论（不关闭）

若 `--from-issue=N` 且 `issue-tracker.json` 的 `enabled` 为 true：
- `gh issue comment N --body "..."`，**中文**修复说明：修复摘要、commit、请用户验证。
- **不执行 `gh issue close`**--issue 保持 open，等用户确认。
- 截图不上传（gh 不支持附件）；用户提供的截图在会话内引用，不落 bug 工件。

### 7. 停下，把决策交给人

报告这一个 bug：根因、分类、回归测试、commit、issue 评论（如有）。建议下一个动作：

- 还有失败 / 别的 bug -> 继续 `/bug`
- 全量回归收尾 -> `/qa-runner`
- 都处理完 -> `/reflect`

**不自动连续修下一个**。人在场，人决定。

### 8. req-gap 就地补全（非回流 · 默认收敛路径）

诊断或修复中判定 req-gap 时，**不踢回外层重走、不退 phase、不归档**。req-gap 是默认收敛路径：QA 验收发现意图缺口 → 就地增量更新产物 + 补测试，补完回步骤 5 继续把这个 bug 修完。**不是重新设计。**

1. 向用户说明：根因在 REQ/PRD（含技术方案）/HTML 层，不是代码层；但不需要重新设计，只需就地补全相应产物与测试。
2. 就地补全动作（按根因选一）：
   - REQ 漏 case -> `/crystallize` 补验收标准增量。
   - PRD 写错 / §10 技术方案缺 seam 或契约 -> 人改 PRD，或 `/tech-design` 深潜补全 §10。
   - 缺测试 seam -> `/test-author` 补测试骨架。
   - HTML UX 参照小改 -> `/design` 改 HTML（一挡可改）。
3. 补完后**回步骤 5.1**（失败回归测试），继续修复这个 bug，不退出 `/bug`。
4. **升级条件**：诊断判定是 UX 方向推翻或初衷不成立 -> 不就地补全，改走 `/story` 真回流（归档重做/删 story）。这是 req-gap 与真回流的边界，由根因诊断、人拍板。
5. **超范围归类**：缺口超出当前 story 范围（不属于本 story 承诺）-> 不与用户纠结，直接显式决策：**新建 story** 或 **归入范围外**，并在本次修复中只做能就地补的部分。
6. REQ 实质契约变更（改了契约语义，非补 case）-> 提示人考虑门 1 重审受影响断言；不强制退 phase。
7. 更新 `workflow-state.yaml`：**phase 保持 BUG**，history 记一条 req-gap 补全说明（更新了哪些产物）。不退 phase、不建 `archive/attempt-N/`。

> req-gap 不是回流。真回流（初衷级推翻）由 `/story` 执行，见 `skills/productivity/story/SKILL.md` 的"回流"章节。

### 9. not-a-bug 分支

判定 not-a-bug 时：与用户确认后，commit 一条 `[docs]` 或仅口述记录决策（引用相关 REQ/PRD 段落说明为何不是 bug）。不修代码。若来自外部 issue，`gh issue comment` 中文说明后 `gh issue close`。

### 10. 关闭外部 issue（`--close-issue=N`）

- 与用户确认：bug 已修复且验证通过。
- `gh issue close N`，加中文关闭评论（如「已确认修复，关闭 issue」）。
- 更新 `workflow-state.yaml`。

### 11. 跨 story bug

如果判断 bug 不属于当前 story：建议切到对应 story 再 `/bug`；或为跨 story bug 单开新 story；全局基础设施问题走 ADR/独立分支，不进当前 story bug 处理。不得硬塞。

## 命令格式

```bash
/bug                          # 口述症状 -> 诊断 -> 分类(人确认) -> 修 -> commit
/bug --from-issue=123         # 从 issue 拉症状 -> 诊断 -> 修 -> 评论 issue(不关)
/bug --close-issue=123        # 用户确认后关闭 issue
```

## 纪律

- **一次一个 bug**：不批量、不连续自动修下一个。人决定下一个。
- **无根因不修复**（Iron Law）：必须复现 + 定位根因后才能改代码。
- **分类人确认**：分类是裁决，模型提议，人拍板。分类随诊断证据可修正。
- **回归测试必须先红**（Prove-It）：禁止无测试直接改代码。
- **三道闸门必过**：3-strike / blast-radius(>5 文件) / req-gap 检测。卡住即停，问人。
- **req-gap 就地补全，不是回流**：就地更新 PRD（含技术方案）/REQ/HTML + 补测试，phase 保持 BUG，补完继续修；只有 UX 方向/初衷级推翻才升级 `/story` 真回流。
- **不落本地 bug 工件**：无 `bugs/`、无 bug.md、无 triage.md、无 bug-fix-report.md。追溯靠 `// REQ-TRACE` + commit `[bugfix] BUG-NNN`。
- **只改当前 story**：跨 story bug 拒绝处理。
- **fix subagent 对业务测试只读**。
- **修复后评论不关 issue**：`gh issue comment` 加中文说明，不 `gh issue close`；关闭由用户确认后 `--close-issue` 执行。
- **issue 用中文**（遵循 `issue-tracker.json` 的 `language`）。

## 视觉/feel 缺陷的分类规则

| 情况 | 分类 | 处置 |
|---|---|---|
| 实现偏离已批准 HTML UX 参照 | `code-defect` | 步骤 5 修复 |
| HTML UX 参照本身要改（设计决策实现后被推翻） | `req-gap` | 步骤 8 就地补全（/design 改 HTML） |
| 纯主观审美偏好，无 REQ/HTML 依据 | `not-a-bug` | 步骤 9 关闭记录 |
| 视觉/feel 场景缺测试覆盖（响应式断点、暗色模式） | `test-gap` | 补测试 -> 暴露缺陷则转 code-defect |

> 已批准 HTML UX 参照是最终权威。代码写完后不在 bug 处理中推翻设计；如需小改走 req-gap 就地补全；UX 方向推翻走 `/story` 真回流。

## 与参考项目的差异

- gstack `investigate`、agent-skills `debugging-and-error-recovery`、mattpocock `diagnosing-bugs`、superpowers `systematic-debugging` 都是单 skill 调试修复，无独立"提 bug"步骤，无本地 bug 工件。`/bug` 与之一致。
- 落地我们的约束：分类四分法（code-defect/test-gap/req-gap/not-a-bug）、REQ-TRACE 追溯、story 内处理、外部 issue 对话通道、req-gap 就地补全（真回流交 `/story`）。
- 决策依据见 `design/adr/0002-single-bug-fix-loop.md`。
