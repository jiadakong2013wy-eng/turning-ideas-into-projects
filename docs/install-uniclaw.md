# 在中国联通元景 UniClaw 中安装

1. 打开 [GitHub v0.3.1 Release](https://github.com/jiadakong2013wy-eng/turning-ideas-into-projects/releases/tag/v0.3.1)。
2. 下载下面两个 ZIP：
   - `turning-ideas-into-projects-uniclaw-0.3.1.zip`
   - `orchestrating-multi-model-work-uniclaw-0.3.1.zip`
3. 在 UniClaw 的“设置”或“技能（Skills）管理”中选择导入本地 Skill，依次导入两个 ZIP。
4. 每个 ZIP 的根目录都直接包含 `SKILL.md`。不要再次打包，也不要先套一层文件夹。
5. 导入后确认 `turning-ideas-into-projects` 和 `orchestrating-multi-model-work` 都可见。
6. 新建任务时先挂载需要操作的项目目录，然后输入下面的测试内容。

```text
turning-ideas-into-projects：我想做一个课堂观察工具，先判断是否值得做，不要直接编码。
```

已经有批准的阶段合同后，可以单独选择 `orchestrating-multi-model-work`。

## 客户端没有 ZIP 导入入口时

UniClaw 官方 Agent Skills 文档给出的 Windows 全局目录是：

```text
%USERPROFILE%\.chatcode\skills\
```

分别解压两个 ZIP，把内容放入与 Skill 同名的目录：

```text
%USERPROFILE%\.chatcode\skills\turning-ideas-into-projects\
%USERPROFILE%\.chatcode\skills\orchestrating-multi-model-work\
```

两个目录下都应直接看到 `SKILL.md`。然后重启 UniClaw 并新建任务。项目级安装可以放在：

```text
<项目目录>\.chatcode\skills\
```

## 更新

下载新版的两个 UniClaw ZIP，分别重新导入；使用目录安装时，替换两个同名 Skill 目录。更新后重启客户端并新建任务。

## 能力说明

- UniClaw 中名为“深度研究”的功能不会仅凭名称自动等同于 ChatGPT Deep Research。
- 只有它返回可追踪来源、任务身份和可读取结果时，才能进入外部证据包流程。
- 模型下拉框代表请求；没有实际运行模型读回时，记录仍然是 `unknown`。
