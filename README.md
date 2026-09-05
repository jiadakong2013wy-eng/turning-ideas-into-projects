# Turning Ideas into Projects

把一个还没想清楚的想法，逐步变成方向明确、范围受控、可以验证的项目任务。

它不会一上来就写代码，而是先判断值不值得做、应该怎么做，再只执行当前已经批准的阶段。

## 从 GitHub 安装

请按自己使用的软件选择对应说明：

| 软件 | 安装方式 | 详细步骤 |
|---|---|---|
| Codex | GitHub 插件市场或 Codex ZIP | [Codex 安装说明](docs/install-codex.md) |
| Claude Code | 直接添加 GitHub 插件市场 | [Claude Code 安装说明](docs/install-claude-code.md) |
| 腾讯 WorkBuddy | 从 GitHub Release 下载 WorkBuddy ZIP 后导入 | [WorkBuddy 安装说明](docs/install-workbuddy.md) |
| 中国联通 UniClaw | 从 GitHub Release 下载两个 UniClaw ZIP，分别导入 | [UniClaw 安装说明](docs/install-uniclaw.md) |

不要把一个平台的 ZIP 导入另一个平台。各平台包使用同一套工作流，但安装结构不同。

## 怎么用

从模糊想法开始：

```text
turning-ideas-into-projects 我想做一个帮助老师快速备课的工具，先判断有没有必要做，不要直接编码。
```

如果当前阶段已经批准，而且范围、允许修改的文件和验收方法都已明确，可以单独使用：

```text
orchestrating-multi-model-work 按当前已经批准的范围执行，开始前告诉我模型分工。
```

在支持斜杠命令的软件里，从 `/` 菜单选择对应名称即可。

## 它会怎么推进

1. 澄清问题、用户和价值。
2. 给出继续、调整、暂缓或停止的判断。
3. 只规划你批准的当前阶段。
4. 需要多模型协作时，先告诉你原因和模型分工。
5. 执行编码和验证。
6. 使用没有参与实现的新上下文独立复审，再把结果和风险告诉你。

默认分工是：Deep Research 收集外部证据，Sol 做研究复核和独立复审，Terra 负责计划协调，Luna 负责编码。你可以指定、更换或禁用模型。

如果软件不能证明实际模型、研究任务或独立复审已经运行，它会明确停止或要求外部交接，不会假装完成。

## 下载与校验

发布包在 [GitHub Releases](https://github.com/jiadakong2013wy-eng/turning-ideas-into-projects/releases)。下载后可以用同一版本的 `SHA256SUMS.txt` 核对文件是否完整。
