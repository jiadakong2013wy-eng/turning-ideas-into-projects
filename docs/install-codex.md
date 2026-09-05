# 在 Codex 中安装

## 方法一：Codex CLI

在 Windows PowerShell 中执行：

```powershell
git clone https://github.com/jiadakong2013wy-eng/turning-ideas-into-projects.git
Set-Location .\turning-ideas-into-projects
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

安装脚本会添加 `mingkon-skills` 市场并安装两个所需插件。完成后新建一个 Codex 任务。

如果提示找不到 `codex`，说明这台电脑只有 Codex Desktop，没有可用的 Codex CLI。请用下面的方法。

## 方法二：Codex Desktop

1. 从 [GitHub Releases](https://github.com/jiadakong2013wy-eng/turning-ideas-into-projects/releases) 下载 `turning-ideas-into-projects-codex-0.3.1.zip`。
2. 解压 ZIP，在 Codex Desktop 中打开解压后的目录。
3. 打开“插件”，找到 `Mingkon Skills`。
4. 安装 `Superpowers` 和界面上显示为 `turning-ideas-into-projects` 的插件。
5. 新建任务，在 `/` 菜单中选择 `turning-ideas-into-projects`。

测试输入：

```text
/turning-ideas-into-projects 我想做一个课堂观察工具，先判断是否值得做，不要直接编码。
```

## 更新

CLI 安装用户在仓库目录执行：

```powershell
git pull --ff-only
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

Desktop 用户下载新版 ZIP，重新打开并安装，然后新建任务。
