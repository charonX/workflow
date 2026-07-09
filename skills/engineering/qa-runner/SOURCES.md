# 参考来源：qa-runner

## 理念

内层实现循环的终点验证：行为机器判，观感人判。QA 不是额外步骤，而是契约的第二轮验证：跑 E2E、收集回归证据、处理不稳定测试，让"完成"有客观依据，为 feel-signoff 提供事实基础。

## 借鉴的 reference 文件

- `reference/gstack/qa/SKILL.md`
- `reference/gstack/qa-only/SKILL.md`
- `reference/superpowers/skills/subagent-driven-development/SKILL.md`

## 主要改动

- 行为机器判 / 观感人判分离。
- 不稳定测试处理规则：默认放行但开限时单；反复时绿时红到阈值转阻断。
- E2E 通过后可选调用 `/browser-verify`，用 Chrome DevTools MCP 收集运行时浏览器证据。未配置时优雅降级为 SKIPPED。

## 未来局部更新建议

- gstack qa 更新时，同步健康分、差异感知 QA、WTF 自调节规则。
- superpowers 更新时，可扩展专家子代理并行 QA。

## 改动记录

- 2026-07-03：增加 coverage 报告收集步骤，QA 报告模板新增 Coverage 章节，低于阈值时 QA 不通过。
- 2026-07-09：新增运行时浏览器验证步骤，E2E 通过后调用 `/browser-verify`；QA 报告模板新增 Browser Verify 章节。
