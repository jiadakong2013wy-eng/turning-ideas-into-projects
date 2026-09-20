# Turning Ideas into Projects

把一个模糊想法，或一个需要升级的已有项目，逐步推进成方向明确、范围受控、可以验证的下一步。

它不会收到一句需求就直接写代码，而是先弄清楚问题、证据和边界，只执行当前已经批准的阶段；阶段结束后会给出独立复核结果和下一步建议。

当前版本：`0.4.0`

## 适合什么场景

- 只有一个初步想法，还不确定值不值得做、应该做成什么。
- 想升级已有项目，但需要先理解现有源码、界面、文档和历史决策。
- 项目会持续多个阶段，需要防止目标漂移、范围失控或“做完了但没人验收”。
- 当前阶段需要外部研究、多模型分工、长任务执行或独立技术复审。

如果只是改一个明确文案、修一个已定位的小问题，直接完成该任务通常更简单，不必启动完整流程。

## 最快开始

新项目：

```text
turning-ideas-into-projects：我想做一个帮助老师快速备课的工具。先判断有没有必要做，不要直接编码。
```

已有项目升级：

```text
turning-ideas-into-projects：我想升级现有项目。先让我选择重要目录、关键文档、排除项和可用的历史对话，再建立项目基线。
```

在支持 `/` 菜单的平台中，直接选择 `turning-ideas-into-projects`；不同平台的完整命令名称可能略有不同，安装页面会给出示例。

## 两个入口怎么选

### `turning-ideas-into-projects`

这是日常使用的主入口，适合从想法、问题或已有项目升级开始。它负责判断当前处于哪个阶段、需要什么证据、哪些内容可以读取或修改，以及何时进入执行和验收。

当一个阶段已经批准并冻结，而且确实需要多模型协作时，主流程会自动启用 `orchestrating-multi-model-work`。启用前会明确告诉你：

- 为什么需要多模型协作；
- 当前执行的是哪一版阶段合同；
- 默认准备让哪些模型分别做什么；
- 哪些能力在当前平台不可用；
- 你可以指定、替换或禁用某个模型。

如果任务很简单、阶段尚未批准或范围还不清楚，就不会启动多模型执行。

### `orchestrating-multi-model-work`

也可以单独使用，但前提是已经有一个批准并冻结的阶段：目标、允许修改的范围、验证方法、停止条件和验收人都已明确。

```text
orchestrating-multi-model-work：按当前已批准的阶段合同执行。开始前告诉我模型分工，并记录实际运行模型。
```

它不负责重新定义产品方向，也不能把一个模糊想法直接变成开发任务。如果缺少冻结合同，它只会给出路由建议，不会假装已经开始执行。

## 新项目与已有项目升级

### 新项目

先弄清楚目标用户、真实问题、替代方案和限制，再给出以下判断之一：

- `GO`：证据支持继续；
- `PIVOT`：问题值得解决，但方向需要调整；
- `HOLD`：暂时缺少关键证据，达到条件后再继续；
- `STOP`：当前不值得投入。

只有你批准方向后，才会进入计划、合同和执行。

### 已有项目升级

已有项目不能只凭仓库名或旧对话就假定已经理解。流程会先请你选择信息来源：

- **优先读取**：重要目录、关键源码、需求、设计文档和正式决策；
- **可选读取**：测试、日志、任务记录和你选中的历史对话；
- **明确排除**：过期方案、实验目录、生成文件、无关项目和敏感区域；
- **暂未确认**：可能相关，但需要你确认后才能深入读取的材料。

如果你不知道哪些目录重要，它可以先做一次只读的浅层扫描，只查看项目说明、根目录和一级目录，然后给出建议阅读清单，等你确认后再深入。

理解方式会根据项目类型调整：

- 代码项目会看相关入口、数据流、配置、依赖、测试和最小调用链；
- 界面项目除了源码，还应查看实际界面、截图或关键操作流程；
- API、服务或库重点看接口、调用路径、Schema、示例和测试；
- 无法直接访问项目时，可以使用你提供的压缩包、截图、录屏、日志或结构化交接材料。

检查后会先给出一份“现有项目基线”，把已验证事实、用户确认事实、历史线索、推断、未知项和未检查范围分开写清楚。你确认基线后，才会设计升级方向。

## 七个阶段

| 阶段 | 做什么 | 阶段结果 |
|---|---|---|
| 1. 定位 | 判断是新项目还是已有项目升级，确认目标和授权范围 | 模式与边界明确 |
| 2. 理解 | 澄清新想法，或在批准范围内建立已有项目基线 | 问题与现状得到确认 |
| 3. 定方向 | 比较方案，决定继续、调整、暂缓或停止 | 方向和非目标得到批准 |
| 4. 定计划 | 形成近、中、远路线，只激活当前阶段 | 当前阶段计划明确 |
| 5. 定合同 | 冻结本阶段目标、白名单、证据、停止条件和验收人 | 执行边界不可随意漂移 |
| 6. 执行验证 | 按合同研究、编码、测试并保存证据 | 得到可复查的执行结果 |
| 7. 独立验收与下一步 | 由未参与实现的新上下文复核，再决定后续阶段 | `verified_pass`、`verified_fail` 或 `blocked` |

不会因为“代码已经写了”就宣布完成。技术复核通过也不等于用户验收，最终是否接受仍由你决定。

## 多模型什么时候启动

只有同时满足下面条件，才会进入多模型协作：

1. 当前阶段已经得到批准；
2. 阶段合同已经冻结；
3. 任务确实需要外部证据、模型专长分工、长时间子任务或独立复审；
4. 当前平台能够实际创建并回读对应任务或模型。

### 启动时怎样选模型

系统会先识别当前平台、订阅或席位、可见模型以及是否会产生额外费用，然后展示推荐方案。你有四种选择：

1. **推荐适配**：兼顾质量、订阅内额度、任务匹配和独立复审；选择器会优先推荐这一档。
2. **质量优先**：使用当前平台已确认可用的最强合适模型；如果会额外付费，会先单独说明并征得同意。
3. **省额度/速度优先**：优先使用更快或订阅内模型，但不会降低证据和独立复审要求。
4. **自定义每个角色**：分别选择主线、研究复核、计划、编码和独立复审模型。

选择器出现在对话中：支持选择控件的平台会显示选项，其他平台会显示上面的编号菜单。首次选择后才开始派发任务；也可以说“以后默认采用推荐适配”，让同一项目后续阶段只告知分工，不再重复选择。你随时可以改选，例如：

```text
主线=Astra，研究复核=Sol，计划=Terra，编码=Luna，独立复审=Sol
```

模型更新后不需要重写整个流程。新模型在当前平台可见，且能力、订阅/费用和任务回读方式得到确认后，就可以进入推荐。开始前核实可用性，开始后记录实际运行模型；“名字更新、版本号更大”本身不能证明更适合。无法回读实际模型时记为 `unknown`。如果平台只允许你手动切换模型，会给出切换和继续任务的方法。

**费用不明确、额度耗尽或模型被限流时，会先检查你已同意的备用方案；没有合适方案就提醒你选择，不会自动购买额度。** 模型偏好只记录在当前获准的项目中，不修改全局设置。

### 各平台的推荐路由

| 平台 | 推荐适配 | 订阅与回退 |
|---|---|---|
| Codex | GPT-6 Astra 负责主线和最难裁决；Terra 负责任务计划与协调；Sol 负责科学研究、证据复核、架构和独立技术复审；Luna 负责编码和聚焦测试 | Astra 不可用时回退到 Terra / Sol / Luna 分工，并记录原因 |
| Claude Max / 高级席位 | Fable 5/5.1 处理最难主线或最终复审；Opus 5 负责计划、研究和复核；Sonnet 5 负责编码 | 仅在当前套餐确实包含 Fable 时自动推荐 |
| Claude Pro / 标准席位 | Opus 5 负责主线、计划、研究和独立复审；Sonnet 5 负责编码 | Fable 5/5.1 可能在模型列表中，但使用 pay-as-you-go credits；没有明确同意额外付费时不会选择 |
| Claude Free | 使用当前可见的 Sonnet 5，并用新会话或新任务做独立复审 | 合同要求的关键能力不可用时暂停，不冒充等价能力 |
| WorkBuddy | Kimi-K3（或 DeepSeek-V4-Pro）负责主线、研究和独立复审；GLM-5.3 负责长上下文计划；Kimi-K2.7-Code（或 MiniMax-M3）负责编码；DeepSeek-V4-Flash 负责简单快速任务 | 默认只推荐当前模型列表可见的国内模型，并遵守快速、均衡、极致模式和 Token Plan 范围 |
| UniClaw | 根据当前客户端实际可见的模型和能力推荐 | 不预写不存在的固定模型名；无法确认模型、费用或任务回执时暂停对应分支 |

ChatGPT Deep Research 不属于上表中的主线模型。它只负责收集带来源的外部证据；Astra、Opus、Kimi 等模型负责理解、判断、计划、实现或复审，二者不是互相替代的关系。

模型与套餐会变化，推荐以客户端实际可见能力为准。当前规则参考 [OpenAI GPT-6 Astra 指南](https://developers.openai.com/api/docs/guides/latest-model)、[Claude Fable 套餐说明](https://support.claude.com/en/articles/15424964-claude-fable-models-on-your-plan)、[Claude Opus 5](https://www.anthropic.com/news/claude-opus-5)、[Claude Sonnet 5](https://www.anthropic.com/news/claude-sonnet-5) 和 [WorkBuddy 模型配置](https://www.workbuddy.cn/docs/workbuddy/From-Beginner-to-Expert-Guide/Function-Description/Model)。

### Deep Research 会在什么情况下启动

当冻结合同明确需要一个“外部证据包”时才启动，例如：最新市场情况、法规、论文、竞品、许可证、下载数据或跨来源事实核对。

下面这些情况不会启动：

- 只是阅读本地源码、界面或你指定的项目文档；
- 普通的小范围编码任务；
- 合同没有说明研究要交付什么；
- 当前平台无法创建或回读 Deep Research 任务；
- 任务要的是一份包含资料搜集、横向比较、纵向演变、叙事和排版的完整研究报告。

最后一种属于端到端研究报告，不会在同一范围内再并行启动 Deep Research，避免与横纵分析等完整研究流程重复。需要交叉检查时，由当前平台选定的研究复核模型在新上下文中检查证据和结论（Codex 默认 Sol）。其他平台原生研究只有能提供带来源的结果、任务身份和结果回读时，才可按平台规则承担同一收集工作。

如果 Deep Research 不可用，系统会明确标记 `external_handoff_required`，给出可复制的研究提示词，等待你提供报告或分享链接，不会假装研究任务已经运行。

## 你会看到怎样的进度

在模式选择、范围批准、项目基线、方向批准、合同冻结、执行开始、执行结束和独立复审等关键节点，会给出简洁进度卡：

```markdown
**总体进度：第 6/7 阶段——执行验证**
已完成：项目基线、升级方向、阶段计划和合同冻结。
当前结果：编码完成，验证证据已保存。
剩余任务：独立技术复审和用户验收。
**下一步计划：由未参与实现的新上下文重新运行验收。**
**需要你处理：无。**
```

需要你决策、下一步计划、重要风险和阻塞原因会使用粗体，方便快速找到真正需要关注的内容。没有变化的长任务不会反复刷屏。

## 支持的平台与安装

| 平台 | 安装方式 | 说明 |
|---|---|---|
| Codex CLI / Desktop | GitHub 插件市场或 Codex ZIP | [Codex 安装说明](docs/install-codex.md) |
| Claude Code | 直接添加 GitHub 插件市场，或使用 Claude Code ZIP | [Claude Code 安装说明](docs/install-claude-code.md) |
| Claude Desktop | 分别上传两个单 Skill ZIP | [Claude Desktop 安装说明](docs/install-claude-desktop.md) |
| 腾讯 WorkBuddy | 导入一个 WorkBuddy ZIP | [WorkBuddy 安装说明](docs/install-workbuddy.md) |
| 中国联通元景 UniClaw | 分别导入两个根目录 Skill ZIP | [UniClaw 安装说明](docs/install-uniclaw.md) |

不要把一个平台的 ZIP 导入另一个平台；它们使用同一套流程，但目录结构和安装方式不同。

### Codex CLI 快速安装

在 Windows PowerShell 中执行：

```powershell
git clone https://github.com/jiadakong2013wy-eng/turning-ideas-into-projects.git
Set-Location .\turning-ideas-into-projects
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

如果提示找不到 `codex`，说明电脑上没有可用的 Codex CLI，请改用 Codex Desktop ZIP 安装方法。

### Claude Code 快速安装

```text
/plugin marketplace add jiadakong2013wy-eng/turning-ideas-into-projects
/plugin install superpowers@mingkon-skills
/plugin install turning-ideas-into-projects@mingkon-skills
/reload-plugins
```

安装或更新后请新建任务或会话。旧任务可能仍使用旧版缓存，不能作为新版是否生效的判断依据。

## v0.4.0 安装包

| 文件 | 用途 |
|---|---|
| `turning-ideas-into-projects-codex-0.4.0.zip` | Codex 本地插件市场 |
| `turning-ideas-into-projects-claude-code-0.4.0.zip` | Claude Code 本地插件市场 |
| `turning-ideas-into-projects-workbuddy-0.4.0.zip` | WorkBuddy 导入包，包含两个入口 |
| `turning-ideas-into-projects-uniclaw-0.4.0.zip` | UniClaw 主流程 |
| `orchestrating-multi-model-work-uniclaw-0.4.0.zip` | UniClaw 多模型执行协调 |
| `turning-ideas-into-projects-claude-desktop-0.4.0.zip` | Claude Desktop 主流程 |
| `orchestrating-multi-model-work-claude-desktop-0.4.0.zip` | Claude Desktop 多模型执行协调 |

UniClaw 和 Claude Desktop 需要分别导入两个 ZIP。WorkBuddy、Codex 和 Claude Code 使用各自的整包。

每份 ZIP 的 `README.md` 提供对应平台的安装方法，`USAGE.md` 提供完整用法、七阶段流程和模型选择说明。

## 更新与常见问题

- **安装后看不到新版**：重启客户端并新建任务，不要在旧任务里判断。
- **Windows 找不到 `pwsh`**：安装脚本可以使用系统自带的 `powershell`，命令见上文。
- **找不到 `codex`**：使用 Codex Desktop ZIP 安装，不要继续运行 CLI 安装脚本。
- **模型名称选了但回执是 `unknown`**：平台只能记录你的请求，不能回读实际运行模型；系统不会猜测。
- **已有项目资料太多**：先选优先目录和排除项；不确定时只做一级目录浅扫，再确认阅读清单。
- **研究能力不可用**：流程会给出外部交接提示词并暂停相应分支，不会用无来源内容代替。

CLI 安装用户更新仓库后重新运行安装脚本：

```powershell
git pull --ff-only
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

其他平台从新版 Release 下载对应 ZIP，重新导入后新建任务。

## 下载与校验

安装包在 [GitHub Releases](https://github.com/jiadakong2013wy-eng/turning-ideas-into-projects/releases)。下载后使用同一版本的 `SHA256SUMS.txt` 核对文件是否完整。

Windows PowerShell 示例：

```powershell
Get-FileHash .\turning-ideas-into-projects-codex-0.4.0.zip -Algorithm SHA256
```

将输出与 `SHA256SUMS.txt` 中对应文件的哈希进行比较；不一致时不要安装。
