# 在腾讯 WorkBuddy 中安装

WorkBuddy 使用自己的 Skill ZIP，不能直接安装 Codex 或 Claude Code 的插件包。

1. 打开 [GitHub v0.3.0 Release](https://github.com/jiadakong2013wy-eng/turning-ideas-into-projects/releases/tag/v0.3.0)。
2. 下载 `turning-ideas-into-projects-workbuddy-0.3.0.zip`。
3. 在 WorkBuddy 打开“专家 · Skills · 连接器”中的“Skills”。
4. 选择“添加 Skill”或“导入本地 Skill 包”，上传刚下载的 ZIP。
5. 确认 `turning-ideas-into-projects` 和 `orchestrating-multi-model-work` 已启用。
6. 新建任务，选择 `turning-ideas-into-projects` Skill 标签，或直接输入下面的测试内容。

```text
turning-ideas-into-projects：我想做一个课堂观察工具，先判断是否值得做，不要直接编码。
```

已经有批准的阶段合同后，可以单独选择 `orchestrating-multi-model-work`。

## 更新

从新的 GitHub Release 下载同名 WorkBuddy ZIP，在 Skills 管理中重新导入。更新后新建任务测试，不要用旧任务判断新版是否生效。

## 能力说明

- WorkBuddy 的模型选择器只代表你希望使用哪个模型。
- 只有任务界面或运行回执能显示实际模型时，才会记录为实际运行模型。
- 内置研究只有在能返回来源、任务身份和结果回读时，才能代替外部证据采集。
- 如果客户端版本没有“导入本地 Skill 包”，请通过 WorkBuddy 开放平台的 Skill 创建入口上传这个 ZIP；不要改 ZIP 内的目录层级。
