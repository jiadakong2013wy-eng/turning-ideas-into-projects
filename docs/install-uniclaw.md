# 在中国联通元景 UniClaw 中安装

1. 打开 [GitHub v0.3.0 Release](https://github.com/jiadakong2013wy-eng/turning-ideas-into-projects/releases/tag/v0.3.0)。
2. 下载 `turning-ideas-into-projects-uniclaw-0.3.0.zip`。
3. 在 UniClaw 的“设置”或“技能（Skills）管理”中选择上传插件、导入技能包或导入本地 ZIP。
4. 导入后确认 `turning-ideas-into-projects` 和 `orchestrating-multi-model-work` 可见。
5. 新建任务时先挂载需要操作的项目目录，然后输入下面的测试内容。

```text
turning-ideas-into-projects：我想做一个课堂观察工具，先判断是否值得做，不要直接编码。
```

已经有批准的阶段合同后，可以单独选择 `orchestrating-multi-model-work`。

## 客户端没有 ZIP 导入入口时

UniClaw 官方 Agent Skills 文档给出的 Windows 全局目录是：

```text
%USERPROFILE%\.chatcode\skills\
```

解压 ZIP，把其中 `skills` 目录下面的每个技能文件夹复制到上述目录，然后重启 UniClaw 并新建任务。项目级安装可以放在：

```text
<项目目录>\.chatcode\skills\
```

## 更新

下载新版 UniClaw ZIP，重新导入；使用目录安装时，用新版 `skills` 下的同名文件夹替换旧文件夹。更新后重启客户端并新建任务。

## 能力说明

- UniClaw 中名为“深度研究”的功能不会仅凭名称自动等同于 ChatGPT Deep Research。
- 只有它返回可追踪来源、任务身份和可读取结果时，才能进入外部证据包流程。
- 模型下拉框代表请求；没有实际运行模型读回时，记录仍然是 `unknown`。
