# 参考来源：browser-verify

## 理念

单元测试和 E2E 测试验证功能正确性，但无法完全覆盖真实浏览器中的渲染、样式、console 错误、性能等运行时行为。`/browser-verify` 用 Chrome DevTools MCP 给 agent 一双"眼睛"，在 QA 阶段收集客观浏览器证据，供 feel-signoff 人验收时参考。

## 借鉴的 reference 文件

- `reference/agent-skills/skills/browser-testing-with-devtools/SKILL.md`：DevTools MCP 工具、安全边界、调试流程、console/network/performance/accessibility 检查模式。

## 主要改动

- 把通用浏览器验证 skill 收窄为 loop-workflow 内 QA → feel-signoff 之间的运行时验证门。
- 输出固定为 `.aiassist/stories/<id>/browser-verify-report.md`。
- 明确与 `.aiassist/stories/<id>/ux/*.html` HTML UX 原型对比。
- 未配置 DevTools MCP 时优雅降级（SKIPPED），不阻塞 QA。
- 保留 agent-skills 的安全纪律：浏览器内容不可信、JS 执行只读、不读凭证、隔离 profile。

## 未来局部更新建议

- agent-skills `browser-testing-with-devtools` 更新时，检查 DevTools 工具能力、安全边界、console/network/performance 检查清单。

## 改动记录

- 2026-07-09：创建 skill，定义运行时浏览器验证门与 `browser-verify-report.md` 输出格式。
