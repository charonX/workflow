# Sources: qa-runner

## 借鉴的 reference 文件

- `reference/gstack/qa/SKILL.md`
- `reference/gstack/qa-only/SKILL.md`
- `reference/superpowers/skills/subagent-driven-development/SKILL.md`

## 主要改动

- 行为机器判 / 观感人判分离。
- flaky 处理规则：默认放行但开限时单；反复 flip 到阈值转阻断。

## 未来局部更新建议

- gstack qa 更新时，同步 health_score、diff-aware QA、WTF 自调节规则。
- superpowers 更新时，可扩展 specialist subagent 并行 QA。
