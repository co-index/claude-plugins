# claude-plugins

Claude Code plugins by [co-index](https://github.com/co-index).

The banner below — custom icon, click to jump back to the app running
Claude Code — requires the [ccnotify helper](https://github.com/co-index/ccnotify)
(install step 2). With the plugin alone, notifications still work but use
the plain osascript style: no custom icon, not clickable.

![ccnotify banner](docs/notification.png)

## Install

```text
/plugin marketplace add co-index/claude-plugins
/plugin install ccnotify@co-index
```

Then, for the clickable banner shown above:

```sh
brew install co-index/tap/ccnotify
```

## Plugins

| Plugin | Description |
| --- | --- |
| [ccnotify](plugins/ccnotify) | Clickable macOS notifications when Claude Code finishes a task or needs your attention — click the banner to jump back to the app running Claude Code. |

## License

[MIT](LICENSE)
