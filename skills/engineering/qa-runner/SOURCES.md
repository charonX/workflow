# 参考来源：qa-runner

## 理念

内层实现循环的终点验证：行为机器判，观感人判。QA 不是额外步骤，而是契约的第二轮验证：跑 E2E、收集回归证据、处理不稳定测试，让"完成"有客观依据，为 feel-signoff 提供事实基础。

## 借鉴的 reference 文件

- `reference/gstack/qa/SKILL.md`
- `reference/gstack/qa-only/SKILL.md`
- `reference/superpowers/skills/subagent-driven-development/SKILL.md`
- `reference/agent-skills/skills/ci-cd-and-automation/SKILL.md`：Playwright CI 安装、build、报告产物上传。
- `reference/agent-skills/references/testing-patterns.md`：Playwright E2E 测试结构与断言模式。

## 主要改动

- 行为机器判 / 观感人判分离。
- 不稳定测试处理规则：默认放行但开限时单；反复时绿时红到阈值转阻断。
- E2E 通过后可选调用 `/browser-verify`，用 Chrome DevTools MCP 收集运行时浏览器证据。未配置时优雅降级为 SKIPPED。
- **v0.10.1 起**：增加 Playwright 依赖检查、CI 模板、报告产物收集、重试与 flaky 分类处理。
- **v0.12.0 起**：QA 失败时建议调用 `/file-bug` 登记 bug。

## 未来局部更新建议

- gstack qa 更新时，同步健康分、差异感知 QA、WTF 自调节规则。
- superpowers 更新时，可扩展专家子代理并行 QA。
- agent-skills `ci-cd-and-automation` / `testing-patterns` 更新时，同步 Playwright CI 与 E2E 测试模式。

## 改动记录

- 2026-07-03：增加 coverage 报告收集步骤，QA 报告模板新增 Coverage 章节，低于阈值时 QA 不通过。
- 2026-07-09：新增运行时浏览器验证步骤，E2E 通过后调用 `/browser-verify`；QA 报告模板新增 Browser Verify 章节。
- 2026-07-09：增加 Playwright E2E 依赖检查、CI 模板、flaky 处理。
- 2026-07-10：QA 失败时建议调用 `/file-bug`。
