# ccnotify — Claude Code plugin

Clickable macOS notifications for Claude Code. When Claude finishes a task
(`Stop`) or needs your attention (`Notification`), you get a banner with the
project name and the task you asked for — **click it and you land back in the
exact app that was running Claude Code** (VS Code, Terminal, iTerm2, Warp,
ghostty, Hyper).

当 Claude 完成任务或需要你时弹出 macOS 横幅，显示项目名和任务内容；
**点击横幅即可跳回运行 Claude Code 的那个应用**。

## Install / 安装

```text
/plugin marketplace add co-index/claude-plugins
/plugin install ccnotify@co-index
```

For clickable banners, install the [ccnotify helper](https://github.com/co-index/ccnotify) once
(没有它时通知仍然可用，但不可点击)：

```sh
brew install co-index/tap/ccnotify
```

Without the helper the plugin falls back to `terminal-notifier` (if present)
and then to a non-clickable osascript notification.

## Configuration / 配置

The app to focus on click is detected from `TERM_PROGRAM`. Override it with:

```sh
export CCNOTIFY_ACTIVATE_BUNDLE_ID="com.example.MyTerminal"
```

Find a bundle id with `osascript -e 'id of app "Visual Studio Code"'`.

## Troubleshooting / 排查

- No banners? Allow **ccnotify** under System Settings → Notifications.
- macOS only; the hooks exit silently on other platforms.
