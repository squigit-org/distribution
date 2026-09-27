# Squigit 26.09.23

> **Mock release notes for interface review.** The sections below are sample content for checking Markdown rendering and the update screen. They are not a record of shipped changes.

## About this update screen

The desktop update view shows the release notes on the left and keeps **Update now** at the lower right. The notes can be several pages long; scrolling should move the document while the action remains reachable. For a Squigit app update, the button opens the [Squigit download section](https://squigit-org.github.io/#download) in your browser, where you can choose the package for your system.

This preview deliberately includes a mix of short paragraphs, long paragraphs, lists, links, inline code, a table, a code block, a quote, and math. It lets us inspect wrapping, spacing, and the scrollbar at narrow and wide window sizes. It also gives the button something substantial to sit beside while the document scrolls.

### What to look for

1. The title starts at the left edge of the notes column, with no centered text.
2. The action stays visible while you scroll from the first section to the final checklist.
3. A long link or inline token such as `squigit-desktop-release-preview-26.08.23-linux-x86_64.AppImage` wraps within the notes column.
4. The table can scroll horizontally inside the notes without moving the action.
5. Code keeps its syntax highlighting from the first visible frame.

## Example changes

These are illustrative entries for the preview, not product claims:

- **Conversation view:** A large thread can contain headings, fenced code, and formulas without crowding its controls.
- **Desktop navigation:** Returning to a previously opened conversation keeps the content ready in the current app session.
- **Update page:** The app and OCR update actions lead to different destinations that match each product's installation path.
- **Accessibility:** The update action has a visible disabled state while a required command is being prepared.

### Platform choices

| Platform | Example package | Where the action leads |
| :--- | :--- | :--- |
| Linux | AppImage or distribution package | Squigit downloads |
| macOS | Disk image | Squigit downloads |
| Windows | Installer | Squigit downloads |

The package names above are examples for layout review. The landing page remains the source for the actual available downloads and installation instructions.

## A longer reading section

A useful release note should help someone decide what to do next without forcing them to decode internal implementation details. It should start with the user-visible change, explain any action required, and state a limitation plainly. If a note links to a download, the link text should name its destination. If a step depends on the operating system, the note should say so before presenting a command or package name.

For this preview, imagine a reader arriving here after the app detects a newer version. They can scan the summary, read the details, and keep the action in view without losing their place. As they scroll down, the button remains in its own column. The scrollbar belongs to the document area at the far right of the screen. At the end of the page, the action should still be in the same corner and should not overlap the final paragraph.

> A release note is most useful when it says what changed, what the reader should do, and where to find more detail.

### Example configuration excerpt

The following JSON is sample text for checking a fenced code block. It is not an importable Squigit configuration file.

```json
{
  "releasePreview": true,
  "product": "app",
  "version": "26.08.23",
  "sections": ["summary", "details", "download"]
}
```

A formula is included solely to exercise math layout: the available document width is $W_{notes}=W_{screen}-W_{action}-W_{gap}$. On a narrow window, the notes column should shrink and wrap rather than pushing the button beyond the viewport.

$$
W_{notes} + W_{gap} + W_{action} = W_{content}
$$

## Before downloading

- Read the package requirements on the [download page](https://squigit-org.github.io/#download).
- Save any work that should be available after restarting the app.
- Choose the package that matches your operating system and architecture.
- Follow the installation steps shown for that package.

## Preview checklist

- [ ] Headings and paragraphs are aligned left.
- [ ] The action is always visible at the lower right.
- [ ] The action remains separate from the document scrollbar.
- [ ] Links open externally.
- [ ] Inline code, fenced code, tables, quotes, lists, and math have readable spacing.
- [ ] The final line can be reached without being hidden behind the action.

This is the end of the mock app release note. The long document is intentional so that scrolling behavior can be reviewed from top to bottom.
