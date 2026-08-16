---
name: wizard
description: 生成一个交互式 bash wizard，逐步引导人完成只有人能做的步骤（配凭据、CI secrets、陌生的第三方后台、一次性迁移/切换）。不用于 agent 自己能做的步骤。独立触发，不绑定 story。
sources:
  - reference/mattpocock/skills/engineering/wizard/SKILL.md
  - reference/mattpocock/skills/engineering/wizard/template.sh
---

# wizard

一个 **wizard** 是 bash 脚本：逐步引导人完成手工流程——每次重复都要向 AI 重讲一遍的繁琐步骤。它打开每个 URL、说清要点哪里、捕获值、写进该去的地方（`.env`、GitHub secrets）、每步确认、并显示还剩几阶段。可配置第三方服务、跑一次性迁移、或把项目从一个状态搬到另一个。

**用户体验已由 `template.sh` 解决**：stage-by-stage 进度、确认门、跨平台 URL 打开（含 WSL）、隐藏秘密输入、幂等 `.env` upsert、`gh secret`/`gh variable` 写入、收尾汇总。**你的工作只是划定流程并编写 stages。** `STAGES` 标记上方的库部分在每个 wizard 里都相同——一致性正是意义所在，绝不手改它。

wizard 默认临时：为一次运行而生，存到 scratch 或 `scripts/`，用完删掉。仅当用户想要可重复的 setup 路径且应留在 repo 里时才 commit。

## 何时调用

用户需要执行**只有人能做的步骤**时：

- Provisioning 基础设施、设置凭据或 CI secrets、走一个陌生的第三方后台。
- 跑一次性迁移或 cutover，需要人确认不可逆步骤。
- 一个流程每隔一段时间就要重新执行（新成员配环境），值得固化成可重复脚本。

**不调用的情况**：

- Agent 自己能完成的步骤 → 直接做，不生成 wizard。
- 初始化目标项目的工作流基础设施 → 走 `/bootstrap-workflow`（它初始化 `.aiassist/` 与 CLAUDE.md 附录；wizard 是通用人工步骤引导，两者互补）。

## 输入

- 流程范围：一句话说清"要完成什么"。例：`为新成员配置本地 Stripe 测试环境`。
- 用户后续会调整 stages 顺序与取舍（见执行步骤 1）。

## 输出

一个 bash 脚本。默认临时（scratch 或 `scripts/`，用完删除）；仅当用户要可重复的 setup 路径时 commit 并链接进 README。

## 执行步骤

### 1. 划定流程（Scope the procedure）

列出人必须做的每个手工步骤与沿途捕获的每个值。**先读 repo 再开口问**：

- Setup：`.env`、`.env.example`、`.env.*`、`README`、`docker-compose*`、框架配置、`.github/workflows/*`（每个 `secrets.*` / `vars.*` 引用都是一个 wizard 必须产出的值）。
- Migration / transition：当前状态、目标状态、两者之间的不可逆动作。

然后把有序 stages 列表和每个产生的值给用户确认——可以增删改序。

**完成当**：每个 stage 都已按序命名；对每个捕获值都知道 (a) 人从哪里拿，(b) 写到哪里（`.env`、GitHub secret、两者、或无处——有些 stage 是纯动作），(c) 是 secret（隐藏输入）还是公开。

### 2. 映射每个 stage 的路径（Map each stage's journey）

对每个 stage，写出人走的精确路径：开哪个 URL、在哪里做什么、值显示在何处、填入哪个变量——例："Dashboard → Developers → API keys → Reveal test key → copy"。不确定当前 UI 或确切命令就说出来并问用户或查文档——**永远不要编造可能不存在的步骤**。

**完成当**：每个 stage 都能追溯到陌生人可照做的具体指示。

### 3. 编写 wizard（Author the wizard）

把 `template.sh` 复制到目标路径。把示例 stage 替换成按依赖顺序每个一步 `stage`。用库 helpers——`stage`、`say`/`step`、`open_url`、`ask`/`ask_secret`、`write_env`、`set_secret`/`set_var`、`pause`/`confirm`——并设 `TOTAL_STAGES` 为你写的 stage 数。

守住 template 的规格：先开 URL 再要它的值，secret 用 `ask_secret`，每个持久化值 `write_env`，只有 CI 真需要的值才 `set_secret`，任何不可逆动作前 `confirm`。每个 `stage` 清屏只显示当前步骤——一个 stage 只做一件聚焦的事，别让用户需要的任何东西滚出屏幕。**不要碰标记线上方的库。**

### 4. 验证并交付（Verify and hand off）

- `bash -n <script>`；有 `shellcheck` 就跑。
- `chmod +x <script>`。
- **不要自己端到端跑**——它开浏览器并阻塞等输入。改为静态 trace：步骤 1 的每个值都被捕获且落到步骤 1 说的地方；每个 `set_secret` 名与 CI 的 `secrets.*` 引用逐字匹配。
- 告诉用户怎么跑。如果它是可重复的 setup 路径，commit 并链接进 README，让下一个人跑脚本而不是问 AI。

## 输出格式

见 [template.sh](template.sh)。作者区在 `STAGES` 标记线以下：`TOTAL_STAGES` + `banner` 开头 + `finish` 结尾 + 中间每个 stage 一个聚焦任务。

## 纪律

1. **库不动**：`STAGES` 标记上方的 wizard 库绝不手改；一致性是目的。
2. **先读 repo 再问**：用户不该回答你自己能从 `.env`、workflows、README 看出来的东西。
3. **不编造步骤**：不确定的 UI/命令问用户或查文档，不发明。
4. **secret 纪律**：secret 走 `ask_secret`（隐藏输入）；只有 CI 真正需要的值才写 GitHub secrets。
5. **不可逆前 confirm**：每步确认 + 显示剩余阶段数。
6. **验证靠静态 trace**：不开浏览器端到端跑；trace 每个值的落点与每个 secret 名。

## 与相邻 skill 的边界

| Skill | 负责 | 不负责 |
|---|---|---|
| `/wizard` | 生成引导人工步骤的交互式 bash 脚本 | 一次性手工操作本身、agent 能自动完成的步骤 |
| `/bootstrap-workflow` | 初始化目标项目工作流基础设施（`.aiassist/`、CLAUDE.md 附录） | 通用人工步骤引导 |
| `/research` | 找事实 | 生成脚本 |

## 示例

```bash
/wizard 为新成员配置本地 Stripe 测试环境
# → 确认 stages（Stripe 后台建 key、写 .env、设 CI secret）→ 生成 wizard 脚本到 scripts/ → 静态验证
```

```bash
/wizard 把 CI 从 CircleCI 迁移到 GitHub Actions
# → 当前状态/目标状态/不可逆动作 → wizard 引导人逐个点掉迁移项 → 确认后跑
```
