# Turning Ideas into Projects

把一个模糊想法，或一个需要升级的已有项目，推进成范围受控、可验证的下一步。

| 软件 | 安装方式 | 详细步骤 |
|---|---|---|
| Codex | GitHub 插件市场或 Codex ZIP | [Codex 安装说明](docs/install-codex.md) |
| Claude Code | 直接添加 GitHub 插件市场 | [Claude Code 安装说明](docs/install-claude-code.md) |
| Claude Desktop | 分别上传两个单 Skill ZIP | [Claude Desktop 安装说明](docs/install-claude-desktop.md) |
| 腾讯 WorkBuddy | 导入 WorkBuddy ZIP | [WorkBuddy 安装说明](docs/install-workbuddy.md) |
| 中国联通 UniClaw | 分别导入两个根目录 Skill ZIP | [UniClaw 安装说明](docs/install-uniclaw.md) |

不要把一个平台的 ZIP 导入另一个平台；各平台包共用工作流，但安装结构不同。

## 两种模式

- 新项目：说明想法、目标用户和限制；Skill 会先判断是否值得做，再只推进你批准的阶段。
- 已有项目升级：先让用户选择重要目录、关键文档、明确排除项和可用的历史对话；没有提供的材料保持为未确认，不假定已理解。

```text
turning-ideas-into-projects 我想升级现有项目。先让我选择重要目录、文档、排除项和历史对话，再决定下一步。
```

已批准且冻结的阶段可单独使用 `orchestrating-multi-model-work` 执行与验证。

## 七阶段

1. 定位  2. 理解  3. 定方向  4. 定计划  5. 定合同  6. 执行验证  7. 独立验收与下一步

## 下载与校验

发布包在 [GitHub Releases](https://github.com/jiadakong2013wy-eng/turning-ideas-into-projects/releases)。下载后用同一版本的 `SHA256SUMS.txt` 核对完整性；具体安装操作请看上表对应指南。
