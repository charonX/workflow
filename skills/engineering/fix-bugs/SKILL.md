---
name: fix-bugs
description: 在当前 story 内批量拉取已分类的 code-defect bug，统一修复、跑全量回归、输出修复报告。修复后在外部 issue 添加中文评论（不关闭），用户确认后由 /file-bug --close 关闭。
sources:
  - reference/gstack/investigate/SKILL.md
  - reference/agent-skills/skills/debugging-and-error-recovery/SKILL.md
  - reference/mattpocock/skills/engineering/diagnosing-bugs/SKILL.md
  - reference/superpowers/skills/systematic-debugging/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# fix-bugs

在当前 story 内批量修复已分类为 `code-defect` 的 bug。**不处理 req-gap 和 not-a-bug**，这两类需先回流到外层循环。

## 何时调用

- `/file-bug` 分类出 code-defect 后，用户说"开始修 bug"、"/fix-bugs"。
- `/story` 总入口在 `BUG_FIX` phase 时调用。
- 用户明确指定 `--bug=BUG-001,BUG-002`。

## 输入

- 当前 story ID
- `.aiassist/stories/<id>/bugs/BUG-*.md`
- `.aiassist/stories/<id>/requirements.md`
- `.aiassist/stories/<id>/tech-design.md`
- `.aiassist/stories/<id>/signoff.md`
- 实现代码和测试文件
- `.aiassist/global/issue-tracker.json`（可选）

## 输出

- 修复 commit（`[bugfix] BUG-NNN: <summary>`）
- `.aiassist/stories/<id>/bug-fix-report.md`
- 更新后的 bug 工件（状态 `fixed`，等用户确认后由 `/file-bug --close` 改为 `closed`）
- 外部 issue 中文评论（不关闭，等用户确认）

## 执行步骤

### 1. 确定当前 story

读取 `workflow-state.yaml` 的 `currentStory`，或取 `.aiassist/stories/` 下最近更新的目录。

### 2. 读取待修复 bug 列表

从 `.aiassist/stories/<id>/bugs/` 读取满足以下条件的 bug：
- `status` 为 `triaged`
- `category` 为 `code-defect`
- `story` 与当前 story 一致

如果用户指定 `--bug=...`：
- 检查每个 bug 是否属于当前 story；不属于则拒绝并提示切换 story。
- 也接受 `status: fixed` 的 bug（用户在 issue 追加评论后要再修一轮）。

如果用户指定 `--severity=critical,major`：只拉取对应 severity。

**同步外部 issue 新评论**：对每个待修 bug，若 frontmatter 有 `external-issue`，先 `gh issue view <n> --json comments` 拉取 `last-synced-comment-id` 之后的新评论，追加到 bug 工件「外部 issue 评论同步」section，作为本轮修复的补充信息（用户可能在 issue 上补充了复现细节、新现象）。更新 `last-synced-comment-id`。

### 3. 排序

按以下顺序：
1. severity：`critical` → `major` → `minor`
2. 依赖关系：被依赖的 bug 先修
3. 创建时间：早创建的先修

### 4. 逐个修复

对每个 bug：

#### 4.1 读取上下文
- bug 工件（症状、复现步骤、根因假设）
- 关联 REQ-ID 和测试文件
- 当前实现代码

#### 4.2 确保有回归测试
- 如果 bug 工件中已指定回归测试，检查该测试是否能复现失败。
- 如果没有，调用 `/test-author` 生成一个回归测试，并在 bug 工件中记录。
- **回归测试必须在修复前失败**（Prove-It 模式）。

#### 4.3 修复实现
- 调用 `/implementer` 的 fix subagent（带上 bug 上下文）。
- fix subagent 只修改实现代码，不修改业务测试契约。
- 修复后跑相关测试，确认回归测试从红变绿。

#### 4.4 提交
- commit 消息：`[bugfix] BUG-NNN: <summary>`
- 一个 bug 一个 commit，便于回滚。

#### 4.5 更新 bug 工件
- `status` 改为 `fixed`
- 记录修复 commit

### 5. 全量回归

所有 bug 修复完成后，调用 `/qa-runner` 跑全量测试（单元 + E2E）。

- 如果全量回归失败：
  - 定位失败的 bug 或相互影响。
  - 修复后重新跑全量。
  - 超过轮数上限仍失败 → 停止，向用户报告 blocker。

全量回归通过后，bug 工件 `status` 为 `fixed`，在外部 issue 添加中文评论（不关闭），等用户确认。用户用 `/file-bug --close` 确认后 `status` 改为 `closed`。**所有 code-defect bug 都 `closed` 且 QA 全绿时**，进入 `/reflect`（门 2：最终验收 + 知识沉淀）；`fixed`（等确认）的 bug 不算 `closed`，不进入 REFLECT。

### 6. 输出修复报告

按 `templates/story/bug-fix-report.md.template` 生成 `.aiassist/stories/<id>/bug-fix-report.md`。

报告包含：
- 修复列表（BUG-ID、类别、严重程度、摘要、commit、状态）
- 全量回归结果
- 需要回补的文档清单（针对 test-gap / req-gap 的发现）
- 外部 issue 状态（已评论等确认 / 已关闭 / 待同步评论）

### 7. BACKFILL 提示

对 test-gap 或 req-gap 的发现：
- 提示用户是否需要更新 PRD/REQ/CONTEXT/ADR。
- 不自动修改这些文档；由 `/to-prd`、 `/crystallize`、 `/domain-model` 等外层 skill 处理。

### 8. 评论外部 issue（不关闭）

修复完成且全量回归通过后，对每个 `status: fixed` 的 bug：
- 如果 frontmatter 有 `external-issue` 且 `issue-tracker.json` 的 `sync.onFixBugsComment` 为 true：
  - `gh issue comment <n> --body "..."` 添加**中文**修复说明，内容包含：修复摘要、修复 commit、请用户验证。
  - **不执行 `gh issue close`**--issue 保持 open，等用户在 issue 或会话中确认。
- 本地 bug 工件 `status` 保持 `fixed`（不是 `closed`）。
- 「关闭」是独立动作，由用户确认后用 `/file-bug --close=BUG-001` 执行。
- 更新 `workflow-state.yaml`：从 `BUG_FIX` 回到 `QA`（还有未关闭 bug 或需重新 QA）或 `REFLECT`（所有 bug 已 `closed` 且 QA 全绿）。

> `fixed`（修复完成，等用户确认）和 `closed`（用户确认）是两个状态。`fixed` 的 bug 仍算「未关闭」，不进入 `REFLECT`。

## 命令格式

```bash
/fix-bugs                    # 修复当前 story 所有 triaged code-defect
/fix-bugs --bug=BUG-001,BUG-002
/fix-bugs --severity=critical,major
```

## 纪律

- **只处理当前 story 的 bug**：跨 story bug 拒绝处理。
- **只处理 code-defect**：test-gap 先补测试；req-gap 先回流外层；not-a-bug 直接关闭。
- **回归测试必须先失败**：修复前必须能复现失败，禁止无测试直接改代码。
- **一个 bug 一个 commit**：便于回滚和审查。
- **不修改业务测试契约**：fix subagent 对业务测试只读。
- **全量回归通过才算完成**：单个 bug 的测试绿不等于整个修复完成。
- **修复后评论不关 issue**：`gh issue comment` 添加中文修复说明，**不执行 `gh issue close`**；关闭由用户确认后 `/file-bug --close` 执行。
- **`fixed` ≠ `closed`**：修复完成是 `fixed`，用户确认才是 `closed`；`fixed` 的 bug 不算关闭，不进入 REFLECT。

## 与 `/file-bug` 的关系

```
/file-bug
  │
  ▼ 登记 + 分类
triaged code-defect bugs
  │
  ▼ /fix-bugs
逐个修复 → 全量回归 → issue 中文评论（不关闭）→ 报告
  │
  ▼ status: fixed
用户在 issue / 会话反馈
  │
  ▼ /file-bug --sync-comments（拉新评论）→ /fix-bugs 再修  或  /file-bug --close（确认关闭）
```

## 与参考项目的差异

- gstack `investigate` 等参考技能把"调查 + 修复"放在一个 skill 里。
- 我们的工作流把"治理"（`/file-bug`）和"修复"（`/fix-bugs`）分开，并把修复约束在 story 内，保证上下文完整。
