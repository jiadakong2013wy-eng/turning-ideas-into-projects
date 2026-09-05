# 在 Claude Code 中安装

Claude Code 可以直接把 GitHub 仓库当作插件市场，不需要先下载 ZIP。

在 Claude Code 中依次输入：

```text
/plugin marketplace add jiadakong2013wy-eng/turning-ideas-into-projects
/plugin install superpowers@mingkon-skills
/plugin install turning-ideas-into-projects@mingkon-skills
/reload-plugins
```

新建一个 Claude Code 会话，然后输入：

```text
/turning-ideas-into-projects:turning-ideas-into-projects 我想做一个课堂观察工具，先判断是否值得做，不要直接编码。
```

如果已经有批准的阶段合同，也可以单独输入：

```text
/turning-ideas-into-projects:orchestrating-multi-model-work 按已批准范围执行，开始前告诉我模型分工。
```

## ZIP 安装

无法直接访问 GitHub 市场时，可从 [GitHub Releases](https://github.com/jiadakong2013wy-eng/turning-ideas-into-projects/releases) 下载 `turning-ideas-into-projects-claude-code-0.3.0.zip`，解压后用本地路径添加市场：

```text
/plugin marketplace add <解压目录的绝对路径>
/plugin install superpowers@mingkon-skills
/plugin install turning-ideas-into-projects@mingkon-skills
/reload-plugins
```

## 更新

```text
/plugin marketplace update mingkon-skills
/plugin update superpowers@mingkon-skills
/plugin update turning-ideas-into-projects@mingkon-skills
/reload-plugins
```

Claude Code 能创建普通子代理，不代表实际使用了 Terra、Luna 或 Sol。只有宿主能读出实际模型时，工作流才会把它记录为 `model_actual`。
