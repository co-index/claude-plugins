# ccnotify — Claude Code plugin

[English](#english) | [中文](#中文)

## English

Clickable macOS notifications for Claude Code. When Claude finishes a task
(`Stop`) or needs your attention (`Notification`), you get a banner with the
project name and the task you asked for — **click it and you land back in the
exact app that was running Claude Code** (VS Code, Terminal, iTerm2, Warp,
ghostty, Hyper).

![ccnotify banner](../../docs/notification.png)

### Install

```text
/plugin marketplace add co-index/claude-plugins
/plugin install ccnotify@co-index
```

For clickable banners, install the
[ccnotify helper](https://github.com/co-index/ccnotify) once:

```sh
brew install co-index/tap/ccnotify
```

Without the helper the plugin falls back to `terminal-notifier` (if present)
and then to a non-clickable osascript notification.

### Configuration

The app to focus on click is detected from `TERM_PROGRAM`. Override it with:

```sh
export CCNOTIFY_ACTIVATE_BUNDLE_ID="com.example.MyTerminal"
```

Find a bundle id with `osascript -e 'id of app "Visual Studio Code"'`.

### Troubleshooting

- No banners? Allow **ccnotify** under System Settings → Notifications.
- macOS only; the hooks exit silently on other platforms.

## 中文

为 Claude Code 提供可点击的 macOS 通知。当 Claude 完成任务（`Stop`）或
需要你时（`Notification`）弹出横幅，显示项目名和任务内容——**点击横幅
即可跳回运行 Claude Code 的那个应用**（VS Code、Terminal、iTerm2、
Warp、ghostty、Hyper）。

![ccnotify 横幅](../../docs/notification.png)

### 安装

```text
/plugin marketplace add co-index/claude-plugins
/plugin install ccnotify@co-index
```

想要可点击的横幅，需要安装一次
[ccnotify 助手](https://github.com/co-index/ccnotify)：

```sh
brew install co-index/tap/ccnotify
```

没有它时插件会回退到 `terminal-notifier`（如果有），再回退到不可点击的
osascript 通知。

### 配置

点击后聚焦的应用按 `TERM_PROGRAM` 自动识别，可用环境变量覆盖：

```sh
export CCNOTIFY_ACTIVATE_BUNDLE_ID="com.example.MyTerminal"
```

查询应用 bundle id：`osascript -e 'id of app "Visual Studio Code"'`。

### 排查

- 看不到横幅？在 系统设置 → 通知 中允许 **ccnotify**。
- 仅支持 macOS；其他平台上 hook 会静默退出。
