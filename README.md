# atom notelink package

Create and use wiki style links in your notes. `[[like this]]`.

![atom-notelink](https://cloud.githubusercontent.com/assets/9103375/20638603/9e1ca0f8-b360-11e6-988c-f11a89033d29.gif)

Supports custom note markers and regex, so you can use single brackets `[like this]` or even custom symbols `🔗like this🔗` or `§like this§`. The start and end symbols can be different, for example: `★like this|` or even `❀like this♥`.

This package was [created by @dansheffler](https://github.com/dansheffler/zettelkasten-wiki) and I forked it to add some improvements.

## Commands

1. `notelink:follow` will follow the link under the cursor and open the note with that name. If there is no note with that name, a new note will be created.
  * `alt-click`
  * `alt-enter` on Windows and Linux
  * `ctrl-enter` on Mac

2. `notelink:copy-link` will get the link for the currently open note and place it into your system clipboard.
  * `alt-c` on Windows and Linux
  * `ctrl-alt-c` on Mac

3. When you begin typing a link symbol, the package will auto-suggest notes for you. This is `[[` by default.

You can make your own keymaps in your keymap.cson. Change `ctrl-enter` to something else:

```
'.platform-darwin atom-workspace atom-text-editor:not([mini])':
  'ctrl-enter': 'notelink:follow'
```

## Contribution

[Open an issue](https://github.com/xHN35RQ/atom-notelink/issues) if you have any problems, find any bugs or have any suggestions for improvement in the code or plugin architecture. Thanks.
