# 参考来源：file-bug

## 理念

bug 治理需要与调试修复分离。`/file-bug` 不负责 root cause fix，而负责把缺陷**显式化、分类、路由到正确的下游 skill**。它让"发现 bug"成为工作流中的一等公民，而不是隐式地混在实现或 QA 阶段。

## 借鉴的 reference 文件

- `reference/gstack/investigate/SKILL.md`：5 阶段调查流程、scope freeze、DEBUG REPORT 结构、3-strike 规则。
- `reference/agent-skills/skills/debugging-and-error-recovery/SKILL.md`：6 步调试流程、Stop-the-Line Rule、回归测试要求。
- `reference/mattpocock/skills/engineering/diagnosing-bugs/SKILL.md`：feedback loop 优先、回归测试先于修复、架构升级路径。
- `reference/superpowers/skills/systematic-debugging/SKILL.md`：Iron Law（无 root cause 不修复）、红队反理性化模式。

## 主要改动

- 把"调试修复"与"缺陷治理"分开：`
- `/file-bug` 只登记、复现、分类、路由，不写修复代码。
- bug 工件挂在当前 story 下，避免跨 story 上下文丢失。
- 引入 code-defect / test-gap / req-gap / not-a-bug 四分类。
- 支持从 GitHub/GitLab issue 拉取（保留 body 图片 markdown 与评论），本地工件为真相源。
- 强制要求 code-defect 先补充/确认回归测试，再进入修复。
- 外部 issue 作为**对话通道**：中文 body；`--sync-comments` 拉取新评论；`--close` 用户确认后关闭。

## 未来局部更新建议

- 参考项目更新调试方法时，同步到 `/fix-bugs` 和 `/implementer` fix subagent，不直接改 `/file-bug`。
- 新增 issue tracker（Linear/Jira）时，扩展 `issue-tracker.json` 和同步规则。
- 未来可增加从 Sentry/监控告警自动创建 bug 的入口。

## 改动记录

- 2026-07-10：外部 issue 改为对话通道：中文 body、保留图片、`--sync-comments` 同步评论、`--close` 用户确认后关闭；bug 工件加 `external-issue` / `last-synced-comment-id` 字段。
- 2026-07-10：创建 `/file-bug`，定义 story 内 bug 登记、分类、路由流程。
