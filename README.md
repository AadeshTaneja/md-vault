# MD Opener

A native macOS Markdown app with two views:

- **Viewer** — formatted, read-only-looking output: styled headings, lists, tables,
  code blocks, task lists, quotes, images.
- **Editor** — the raw source with `##`, `**`, backticks and everything else visible,
  syntax-highlighted so the structure still reads clearly.

Press **⌘E** to flip between them (or use the segmented control in the toolbar).

Built with SwiftUI + AppKit. No dependencies, no package manager, no Xcode project —
just `swiftc` and a hand-assembled app bundle.

## Build

```sh
./build.sh              # builds ./build/MD Opener.app
./build.sh --install    # builds, then copies to /Applications
```

Requires the Xcode Command Line Tools (`xcode-select --install`).

## Shortcuts

| Shortcut | Action |
|:---------|:-------|
| ⌘E | Toggle Editor / Viewer |
| ⌘1 / ⌘2 | Jump straight to Editor / Viewer |
| ⌘S | Save |
| ⌘+ / ⌘- / ⌘0 | Bigger / smaller / default text size |
| ⌘F | Find (in the editor) |
| ⌘O, ⌘N, ⌘W | Open, new, close — plus File ▸ Open Recent |

## Making it the default `.md` app

Open any file, then **File ▸ Set MD Opener as Default for Markdown…**

To undo: in Finder, select a `.md` file, ⌘I, change *Open with*, click *Change All*.

## Markdown supported

Headings (ATX + setext), bold / italic / bold-italic, inline code, strikethrough,
links, autolinks, images (local paths resolve relative to the document), blockquotes,
nested ordered + unordered lists, task lists, tight and loose lists, fenced and
indented code blocks, tables with column alignment, thematic breaks, hard line breaks,
backslash escapes. YAML front matter is hidden in the viewer.

## Layout

```
Sources/
  MDOpenerApp.swift      app entry, menu commands, default-app helper
  ContentView.swift      the two-view shell, toolbar, status bar
  MarkdownDocument.swift FileDocument (open/save/recents come from DocumentGroup)
  EditorView.swift       NSTextView-backed raw editor
  SyntaxHighlighter.swift regex highlighting for the editor
  Theme.swift            font + sizing rules
  Markdown/
    Inline.swift         inline scanner (emphasis, links, code spans…)
    InlineRenderer.swift inline model -> AttributedString
    Blocks.swift         block parser (lists, tables, quotes, fences…)
    MarkdownView.swift   SwiftUI renderer for the viewer
Resources/Info.plist     bundle + .md document type declarations
Tools/MakeIcon.swift     draws the app icon at build time
build.sh                 compile, iconify, assemble, sign, register
sample.md                a document that exercises every supported feature
```
