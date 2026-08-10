# 参考来源：demand-insight

## 理念

在写任何代码之前，先把问题说到机器可验的精度。本 skill 用对抗式访谈逼出隐性需求、边界条件和自相矛盾，并把"问题陈述"锚定为用户痛点——方案会变，痛点不会，它是后续回流的判断基准。

**方向来自 brainstorming，追问来自 grilling。** 用户进入 THINK 阶段时通常只有模糊痛点或初步念头，我们先像 brainstorming 一样帮其找准方向；一旦方向出现，就用 grilling 技术把假设钉到可验证的精度。

**第一性原理。** 需求讨论中最大的风险是把"现有方案""竞品做法""团队习惯"误认为问题本身。本 skill 在讨论陷入继承假设时，强制把用户拉回到"用户要完成的工作是什么"这一基本事实，从那里重新推导方向。

## 借鉴的 reference 文件

- `reference/superpowers/skills/brainstorming/SKILL.md`：从模糊想法到明确方向的流程（探索上下文、澄清问题、提出方案、获得批准）。
- `reference/mattpocock/skills/productivity/grilling/SKILL.md`：盘问 primitive——design tree + round-by-round frontier 批量提问（互不依赖的问题一轮问完、推荐答案、事实派子 agent）。`grill-me` 现在是它的薄包装，只转发 `/grilling`。
- `reference/mattpocock/skills/engineering/grill-with-docs/SKILL.md`：带引用/上下文的对抗式追问。
- `reference/gstack/office-hours/SKILL.md`：CEO 视角的野心/价值拷问。
- `reference/agent-skills/skills/interview-me/SKILL.md`：置信度 + GUESS、"想要 vs 应该想要"探测、95% 停止条件、confirmed intent 格式。

## 主要改动

- 以 superpowers `brainstorming` 为总体流程骨架：确认范围 → 探索上下文 → 澄清问题 → 提出 2-3 个方向 → 呈现并确认方向 → 记录洞察。
- 用 mattpocock `grilling` / `grill-with-docs` 的对抗式追问技术填充"澄清问题"环节：**round-by-round frontier 批量提问**（每轮抛出互不依赖的问题、每题带 GUESS 推荐答案）、展示思考、追问到可验证精度、显式化假设。
- 用 gstack `office-hours` 提供 CEO 视角的野心/价值拷问，填充"待探索维度"。
- 用 agent-skills `interview-me` 增强开场假设、Q+GUESS 提问、"想要 vs 应该想要"探测、95% 置信度停止条件、confirmed intent 输出。
- 输出固定为 `interview-notes.md`，作为 `/to-prd` 的输入。

## 未来局部更新建议

- superpowers `brainstorming` 更新时，检查"探索上下文 → 澄清 → 提出方案 → 批准"流程。
- mattpocock 若更新提问技术，检查"执行步骤"中的追问维度。
- mattpocock `grilling` 已吸收原 `batch-grill-me`（in-progress）的 frontier 批量模式（release/v1.2 起）：一次问完整条 frontier + 事实查找派子 agent 不阻塞。我们已跟进：**互不依赖的问题批量抛出、依赖问题跨轮**。v1.2 同时把"一次一问"设为**可覆盖偏好**（目标项目 `CLAUDE.md` 写 `When grilling, ask one question at a time.` 即切换）——本 skill 已吸收该机制。后续跟踪 grilling 的 round 边界定义与推荐答案格式精简（`Recommendation:` 标签已去除）。
- gstack 若更新 CEO 审查清单，检查"谁/为什么/边界/矛盾/野心"覆盖。
- agent-skills `interview-me` 更新时，检查开场假设、Q+GUESS、停止条件、confirmed intent 格式。

## 改动记录

- 2026-07-09：引入 agent-skills `interview-me` 的置信度 + GUESS、"想要 vs 应该想要"探测、95% 停止条件、confirmed intent 输出格式。
- 2026-08-06：mattpocock 同步评估后，将 `batch-grill-me`（批量 frontier 访谈）记入观察清单，暂不吸收。
- 2026-08-10：mattpocock `grilling` 在 release/v1.2 吸收 `batch-grill-me` 的 round-by-round frontier 批量模式并转正；本 skill 跟进更新：澄清环节从"一次一问"改为"每轮批量抛出互不依赖的 frontier 问题 + 每题推荐答案"，依赖问题跨轮串行。参考路径从 `grill-me`（薄包装）改为 `grilling`（primitive）。
- 2026-08-10：吸收 mattpocock `grilling` 的"一次一问可覆盖偏好"机制——目标项目 `CLAUDE.md` 写 `When grilling, ask one question at a time.` 即切回单题节奏；批量是默认，偏好可覆盖。
