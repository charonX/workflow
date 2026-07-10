# 参考来源：fix-bugs

## 理念

修复 bug 不是一次性的代码改动，而是一个**有约束的循环**：复现 → 回归测试 → 修复 → 验证 → 回补文档 → 关闭。`/fix-bugs` 把这个循环结构化，并确保它在当前 story 的完整上下文中执行。

## 借鉴的 reference 文件

- `reference/gstack/investigate/SKILL.md`：5 阶段调查、回归测试要求、范围冻结、DEBUG REPORT。
- `reference/agent-skills/skills/debugging-and-error-recovery/SKILL.md`：6 步调试、root cause 修复、回归测试、Stop-the-Line Rule。
- `reference/mattpocock/skills/engineering/diagnosing-bugs/SKILL.md`：feedback loop、修复前回归测试、post-mortem。
- `reference/superpowers/skills/systematic-debugging/SKILL.md`：Iron Law、失败测试先于修复、架构质疑规则。

## 主要改动

- 批量修复当前 story 内已分类的 code-defect bug。
- 强制 Prove-It 模式：修复前必须有失败的回归测试。
- 一个 bug 一个 `[bugfix]` commit。
- 修复后必须跑全量回归，而不只是单个测试。
- 输出结构化 `bug-fix-report.md`。
- 支持同步关闭 GitHub/GitLab issue。
- test-gap / req-gap 不在这里修复，而是回流到外层循环。

## 未来局部更新建议

- 参考项目更新调试技术时，同步到 fix subagent 的实现策略。
- 新增 issue tracker 集成时，扩展同步规则。
- 未来可增加跨 story 批量治理的 `/bug-sprint` skill。

## 改动记录

- 2026-07-10：创建 `/fix-bugs`，定义 story 内批量 bug 修复、全量回归、报告、关闭流程。
