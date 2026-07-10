# 参考来源：bootstrap-workflow

## 理念

一人创作者的项目基础设施应该一次性、显式地建立，而不是在每个 story 里重复创建。本 skill 只负责初始化 `.aiassist/` 全局目录和更新目标项目 `CLAUDE.md`，不创建具体 story，把"项目级"和"story 级"职责分开。

## 借鉴的 reference 文件

- `reference/gstack/CLAUDE.md`

## 主要改动

- 把 `.aiassist/` 做成可显式初始化的项目级基础设施。
- 职责收窄：只创建 `.aiassist/global/` 和更新 `CLAUDE.md`，不创建具体 story，不复制 skills。
- story 创建移到 `/story`。
- 新增全局文档：`CONTEXT.md`、`business-capabilities.md`、`adr/`、`codegraph.json`。
- 新增 `checklists/` 目录（testing/security/performance/accessibility/observability）和结构化 `STANDARDS.md` 模板，由 `/reflect` 持续更新。
- 可选启用 CodeGraph，帮助 AI 通过代码知识图谱理解代码结构。
- **v0.12.0 起**：新增外部 issue tracker（GitHub/GitLab）配置；新增 `[bugfix]` commit 标签。

## 未来局部更新建议

- gstack CLAUDE.md 更新 project 约定时，检查目标项目 `CLAUDE.md` 附录内容。

## 改动记录

- 2026-07-01：整理参考来源，明确借鉴的 reference 文件。
- 2026-07-03：补全 SKILL.md 初始化流程；新增 `.aiassist/hooks/pre-commit` 与 `commit-msg`，强制实现 commit 与测试 commit 分离；新增多技术栈 CI/CD 模板（Node.js/Python/Swift/Go/Generic），bootstrap 时自动检测或询问用户选择；在 `project-claude-appendix.md.template` 中加入 commit 标签约定。
- 2026-07-08：新增 `CONTEXT.md`、`business-capabilities.md`、`adr/`、`codegraph.json` 全局文档；可选启用 CodeGraph。
- 2026-07-09：新增 `checklists/` 目录与结构化 `STANDARDS.md` 模板，由 `/reflect` 持续更新。
- 2026-07-10：新增外部 issue tracker（GitHub/GitLab）配置与 `[bugfix]` commit 标签。
