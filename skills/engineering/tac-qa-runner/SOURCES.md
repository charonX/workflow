# 参考来源：qa-runner

## 借鉴的 reference 文件

- `reference/gstack/qa/SKILL.md`
- `reference/gstack/qa-only/SKILL.md`
- `reference/superpowers/skills/subagent-driven-development/SKILL.md`

## 主要改动

- 行为机器判 / 观感人判分离。
- 不稳定测试处理规则：默认放行但开限时单；反复时绿时红到阈值转阻断。

## 未来局部更新建议

- gstack qa 更新时，同步健康分、差异感知 QA、WTF 自调节规则。
- superpowers 更新时，可扩展专家子代理并行 QA。
