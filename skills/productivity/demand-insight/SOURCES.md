# 参考来源：demand-insight

## 理念

在写任何代码之前，先把问题说到机器可验的精度。本 skill 用对抗式访谈逼出隐性需求、边界条件和自相矛盾，并把"问题陈述"锚定为用户痛点——方案会变，痛点不会，它是后续回流的判断基准。

**方向来自 brainstorming，追问来自 grilling。** 用户进入 THINK 阶段时通常只有模糊痛点或初步念头，我们先像 brainstorming 一样帮其找准方向；一旦方向出现，就用 grilling 技术把假设钉到可验证的精度。

**第一性原理。** 需求讨论中最大的风险是把"现有方案""竞品做法""团队习惯"误认为问题本身。本 skill 在讨论陷入继承假设时，强制把用户拉回到"用户要完成的工作是什么"这一基本事实，从那里重新推导方向。

## 借鉴的 reference 文件

- `reference/superpowers/skills/brainstorming/SKILL.md`：从模糊想法到明确方向的流程（探索上下文、澄清问题、提出方案、获得批准）。
- `reference/mattpocock/skills/productivity/grill-me/SKILL.md`：通用盘问技术，把 design tree 的树枝补全。
- `reference/mattpocock/skills/engineering/grill-with-docs/SKILL.md`：带引用/上下文的对抗式追问。
- `reference/gstack/office-hours/SKILL.md`：CEO 视角的野心/价值拷问。
- `reference/agent-skills/skills/interview-me/SKILL.md`：一次一问、置信度 + GUESS、"想要 vs 应该想要"探测、95% 停止条件、confirmed intent 格式。

## 主要改动

- 以 superpowers `brainstorming` 为总体流程骨架：确认范围 → 探索上下文 → 澄清问题 → 提出 2-3 个方向 → 呈现并确认方向 → 记录洞察。
- 用 mattpocock `grill-me` / `grill-with-docs` 的对抗式追问技术填充"澄清问题"环节：一次一问、展示思考、追问到可验证精度、显式化假设。
- 用 gstack `office-hours` 提供 CEO 视角的野心/价值拷问，填充"待探索维度"。
- 用 agent-skills `interview-me` 增强开场假设、Q+GUESS 提问、"想要 vs 应该想要"探测、95% 置信度停止条件、confirmed intent 输出。
- 输出固定为 `interview-notes.md`，作为 `/to-prd` 的输入。

## 未来局部更新建议

- superpowers `brainstorming` 更新时，检查"探索上下文 → 澄清 → 提出方案 → 批准"流程。
- mattpocock 若更新提问技术，检查"执行步骤"中的追问维度。
- gstack 若更新 CEO 审查清单，检查"谁/为什么/边界/矛盾/野心"覆盖。
- agent-skills `interview-me` 更新时，检查开场假设、Q+GUESS、停止条件、confirmed intent 格式。

## 改动记录

- 2026-07-09：引入 agent-skills `interview-me` 的置信度 + GUESS、"想要 vs 应该想要"探测、95% 停止条件、confirmed intent 输出格式。
