# atom-notelink package

Create and use wiki style links in your notes. `[[like this]]`.

Supports custom note markers and regex, so you can use single brackets `[like this]` or even custom symbols `🔗like this🔗` or `§like this§`. The start and end symbols can be different, for example: `★like this|` or even `❀like this♥`.

This package was [created by @dansheffler](https://github.com/dansheffler/zettelkasten-wiki) and I forked it to add some improvements.

## Setup

After installation, go to the settings for this package and set the location to your notes directory. You can also customize the link symbols and regex.

## Commands

1. `atom-notelink:follow` will follow the link under the cursor and open the note with that name. If there is no note with that name, a new note will be created.
  * `ctrl-enter` on Mac
  * `alt-enter` on Windows and Linux
  * `alt-click`

2. `atom-notelink:follow` will get the link for the currently open note and place it into your system clipboard.
  * `ctrl-alt-c` on Mac
  * `alt-c` on Windows and Linux

3. When you begin typing a link symbol, the package will auto-suggest notes for you. This is `[[` by default.

You can make your own keymaps in your keymap.cson. Change `ctrl-enter` to something else:

```
'.platform-darwin atom-workspace atom-text-editor:not([mini])':
  'ctrl-enter': 'atom-notelink:follow'
```

## Contribution

[Open an issue](https://github.com/xHN35RQ/atom-notelink/issues) if you have any problems, find any bugs or have any suggestions for improvement in the code or plugin architecture. Thanks.
