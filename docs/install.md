# 安装

循环工作流目前主要提供一套 **Claude Code skill** 集合，并已同步发布 **Kimi Code 插件**。你可以通过 Claude Code 或 Kimi Code 的插件机制安装，也可以手动复制 skill 文件到其他项目。理念本身不绑定任何工具，如果你使用其他 agent 平台，可以把 `skills/` 下的 `SKILL.md` 翻译成对应平台的 prompt 或工具调用。

## 目录

- [Claude Code Marketplace（推荐）](#claude-code-marketplace推荐)
- [Kimi Code 插件](#kimi-code-插件)
- [Vercel Labs skills CLI](#vercel-labs-skills-cli)
- [手动复制或软链](#手动复制或软链)
- [迁移到其他 agent 平台](#迁移到其他-agent-平台)
- [保持同步](#保持同步)

---

## Claude Code Marketplace（推荐）

在任意项目的 Claude Code 会话中：

```bash
# 1. 添加本仓库作为 marketplace（只需一次）
/plugin marketplace add charonX/workflow

# 2. 安装插件
/plugin install loop-workflow@charonx-workflow

# 3. 安装后刷新插件
/reload-plugins
```

> marketplace 名是 `charonx-workflow`，插件名是 `loop-workflow`。
> 后续更新：先 `/plugin marketplace update charonx-workflow` 拉取最新目录，再 `/reload-plugins` 重载；必要时可 `/plugin uninstall loop-workflow@charonx-workflow` 后重新安装。

---

## Kimi Code 插件

在任意 Kimi Code 会话中，直接安装本仓库 GitHub 地址：

```bash
/plugins install https://github.com/charonX/workflow
```

安装完成后，执行 `/reload` 或新建一个会话使插件生效。

> 当前 Kimi 插件安装是**用户级**（对所有项目生效），尚不支持项目级作用域。安装后所有 skill 会作为 Kimi Agent Skills 加载。

安装后，用 Kimi 的 skill 调用方式触发工作流：

- `/skill:story` —— 工作流总入口，新建或继续 story
- `/skill:bootstrap-workflow` —— 在目标项目中初始化工作流基础设施
- `/skill:demand-insight`、 `/skill:to-prd`、 `/skill:tech-design` …… 其他阶段 skill

Kimi Code 插件依赖仓库根目录的 `kimi.plugin.json` 清单，它会扫描 `skills/productivity/`、`skills/engineering/` 和 `skills/maintenance/` 下的所有 `SKILL.md`。

---

## Vercel Labs skills CLI

```bash
npx skills@latest add charonX/workflow
```

---

## 手动复制或软链

如果你本地有本仓库的克隆，可以把 `skills/` 目录复制或软链到目标项目的 `.claude/skills/`：

```bash
# 1. 克隆本仓库（如尚未克隆）
git clone https://github.com/charonX/workflow.git

# 2. 复制到目标项目
cd /path/to/your-project
rm -rf .claude/skills/*
cp -R /path/to/workflow/skills/productivity/* .claude/skills/
cp -R /path/to/workflow/skills/engineering/* .claude/skills/
cp -R /path/to/workflow/skills/maintenance/* .claude/skills/

# 或软链（仅本地开发）
ln -s /path/to/workflow/skills/productivity/* .claude/skills/
ln -s /path/to/workflow/skills/engineering/* .claude/skills/
ln -s /path/to/workflow/skills/maintenance/* .claude/skills/
```

---

## 迁移到其他 agent 平台

循环工作流的核心理念（测试即契约、外层 / 内层循环、两道签核、REQ 可追溯等）不依赖 Claude Code。如果你使用 Cursor、Windsurf、自定义 agent 或其他 LLM 工具链，可以：

1. 阅读 `skills/<bucket>/<skill-name>/SKILL.md`，理解每个步骤要做什么、输入输出是什么、约束是什么。
2. 把每个 skill 改写为你所在平台的 prompt、tool call、MCP server 或 agent 编排脚本。
3. 保留相同的产物目录结构（`.aiassist/`）和术语，使工作流可复用。

如果你完成了某个平台的迁移，欢迎提交 PR 补充到本文档。

---

## 保持同步

当本仓库的 skill 更新后：

- **Marketplace 方式**：`/plugin marketplace update charonx-workflow`
- **npx skills 方式**：`npx skills@latest add charonX/workflow`
- **本地软链开发**：更新会自动生效，无需重新安装
- **其他平台迁移**：定期拉取本仓库，按你的映射脚本重新生成 prompt 或配置
