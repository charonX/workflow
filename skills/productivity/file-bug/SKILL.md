---
name: file-bug
description: 在当前 story 内登记、复现、分类 bug，生成 bug 工件并决定路由。支持从 GitHub/GitLab issue 拉取。
sources:
  - reference/gstack/investigate/SKILL.md
  - reference/agent-skills/skills/debugging-and-error-recovery/SKILL.md
  - reference/mattpocock/skills/engineering/diagnosing-bugs/SKILL.md
  - reference/superpowers/skills/systematic-debugging/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# file-bug

在当前 story 内登记 bug，完成复现、分类和路由决策。**不直接写修复代码**。

## 何时调用

- 用户在 story 内说"发现 bug"、"这里有问题"、"/file-bug"。
- `/qa-runner` 建议"是否为该失败创建 bug 工件"。
- 用户想从外部 issue tracker 拉取 issue 到当前 story。

## 输入

- 当前 story ID（从 `workflow-state.yaml` 或当前 `.aiassist/stories/` 最近更新推导）
- `.aiassist/stories/<id>/prd.md`
- `.aiassist/stories/<id>/requirements.md`
- `.aiassist/stories/<id>/tech-design.md`
- `.aiassist/stories/<id>/signoff.md`
- `.aiassist/global/issue-tracker.json`（可选）
- bug 描述、复现步骤、期望/实际行为、环境、截图/日志
- 外部 issue URL/编号（可选）

## 输出

- `.aiassist/stories/<id>/bugs/BUG-NNN.md`
- `.aiassist/stories/<id>/bugs/BUG-NNN-triage.md`
- 更新 `workflow-state.yaml`：phase 设为 `BUG_TRIAGE`

## 执行步骤

### 1. 确定当前 story

读取 `workflow-state.yaml` 的 `currentStory`，或取 `.aiassist/stories/` 下最近更新的目录。

### 2. 收集 bug 报告

向用户收集：
- 症状（一句话描述）
- 复现步骤
- 期望行为 vs 实际行为
- 环境（浏览器/设备/分支/commit）
- 截图/日志/错误信息（如有）

如果从外部 issue 创建（`--from-issue=123`）：
- 使用 `gh issue view 123` 或 `glab issue view 123` 拉取标题和正文。
- 把外部 issue 信息作为 bug 报告起点，仍需向用户确认/补充。

### 3. 创建 bug 工件

按 `templates/story/bug.md.template` 生成 `.aiassist/stories/<id>/bugs/BUG-NNN.md`，状态为 `open`。

编号规则：顺序递增 `BUG-001`、`BUG-002`……以当前 story 的 `bugs/` 目录下最大编号 +1 为准。

### 4. 尝试复现与定位

- 读取 `requirements.md` 找到相关 REQ-ID。
- 读取现有测试，判断是否有测试覆盖该场景。
- 如有必要，运行相关产品命令/测试，确认 bug 存在。
- 读取实现代码，初步判断是否偏离 REQ。

### 5. 分类并路由

| 类别 | 判定标准 | 路由 |
|---|---|---|
| **code-defect** | 实现偏离已签核 REQ；或当前测试本应暴露但该 case 未覆盖 | 更新 bug 状态为 `triaged` → 路由到 `/fix-bugs` |
| **test-gap** | 行为符合当前 REQ，但测试未覆盖该边界/路径 | 调用 `/test-author` 补充测试；如测试暴露实现缺陷，再转 `code-defect` |
| **req-gap** | REQ/PRD 未定义或定义错误 | 回流到外层循环：更新 PRD/REQ → 重新签核 → `/fix-bugs` |
| **not-a-bug** | 实际行为符合 REQ，只是用户预期不同 | 关闭 bug，记录决策 |

分类时必须明确说明理由，引用相关 REQ-ID 或 PRD 段落。

### 6. 更新 bug 工件

填写根因、路由决策、关联 REQ-ID。生成 `BUG-NNN-triage.md` 记录分类理由。

### 7. 外部 issue 同步

如果 `.aiassist/global/issue-tracker.json` 的 `enabled` 为 true：
- 手动创建的 bug：询问是否同步创建外部 issue。
- 从外部 issue 创建的 bug：在本地工件中记录 `source`。

不自动双向同步；外部 tracker 是通知渠道，本地工件是真相源。

### 8. 跨 story bug 处理

如果判断 bug 不属于当前 story：
1. 建议用户切换到对应 story 重新 `/file-bug`；或
2. 建议为跨 story bug 单开一个新 story 专门治理；或
3. 如果是全局基础设施问题，走 ADR/独立修复分支，不进入当前 story bug 循环。

不得把明显不属于当前 story 的 bug 硬塞进当前 story。

## 命令格式

```bash
/file-bug --create
/file-bug --create --from-issue=123
/file-bug --triage=BUG-001
/file-bug --close=BUG-001
```

## 纪律

- **只在当前 story 内创建 bug 工件**。
- **分类必须有依据**：引用 REQ、测试或 PRD 段落，不凭猜测。
- **不直接修复**：`/file-bug` 只负责登记和路由，修复交给 `/fix-bugs` 或 `/test-author`。
- **回归测试优先**：code-defect 必须先有回归测试（或明确利用现有测试）再修复。
- **外部 tracker 只是通知渠道**：真相源始终是 `.aiassist/stories/<id>/bugs/BUG-NNN.md`。

## 与 `/fix-bugs` 的关系

```
/file-bug
  │
  ▼ 登记 + 分类
BUG-NNN.md (status: triaged)
  │
  ▼ code-defect
/fix-bugs
  │
  ▼ 修复 + 回归
bug-fix-report.md
```

## 与参考项目的差异

- gstack `investigate`、agent-skills `debugging-and-error-recovery`、mattpocock `diagnosing-bugs`、superpowers `systematic-debugging` 都侧重**调试修复**。
- `/file-bug` 侧重**缺陷治理**：登记、分类、路由、回补追踪。调试修复本身交给 `/fix-bugs` 和 `/implementer` fix subagent。
