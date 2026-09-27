# Squigit OCR 0.1.1

> **Mock release notes for interface review.** This document is sample content for checking the OCR update screen. It does not announce shipped OCR changes.

## How the OCR update action works

Squigit OCR is updated through the package manager for your system. When the update command is ready, **Update now** opens a new terminal and inserts the command at the prompt. The command is **staged, not executed**: review it and press **Enter** yourself. If the app cannot determine a supported command, the button remains disabled and the reason appears next to it.

That behavior is different from a Squigit app update, which opens the [download section](https://squigit-org.github.io/#download) in a browser. The two routes share the same release-note layout so the document remains readable while the correct action is always visible.

### Command preparation states

1. The page first checks whether the OCR engine is available.
2. On a supported system, it resolves the package-manager command.
3. While that work is in progress, the disabled button reads **Preparing updates…** and shows a spinner.
4. Once ready, the button reads **Update now**.
5. Clicking it opens a terminal and stages the command for review.

The sample table below is intentionally wider than a short paragraph. It should stay inside the notes column, including at narrow window widths.

| System | Example staged command | What the reader does next |
| :--- | :--- | :--- |
| Debian family | `sudo apt update && sudo apt install --only-upgrade -y squigit-ocr` | Review and press Enter |
| RPM family | `sudo dnf upgrade -y squigit-ocr` | Review and press Enter |
| macOS | `brew upgrade squigit-ocr` | Review and press Enter |
| Windows | `winget upgrade --id SquigitOrg.SquigitOCR --exact --accept-source-agreements --accept-package-agreements` | Review and press Enter |

These examples describe the command-injection flow. Package availability and support still depend on the machine and its configured package sources.

## Example output

The block below is sample terminal text for Markdown and syntax rendering. It is not an instruction to run this exact command outside the update flow.

```bash
# Example only: inspect the staged command before running it.
sudo apt update
sudo apt install --only-upgrade -y squigit-ocr
squigit-ocr --version
```

Inline terms such as `winget`, `brew`, `dnf`, and `apt` should remain easy to read inside a paragraph. A very long token like `squigit-ocr-command-preview-for-renderer-layout-inspection` should wrap instead of widening the action column.

## Reading a long note

Long notes are useful for checking whether the document and action remain independent. You should be able to scroll this section while the button stays near the lower right corner. The button should not drift upward with the paragraphs, disappear beneath the footer, or cover the scrollbar. The document should keep its own reading width and remain aligned to the left rather than narrowing into a centered card.

A good OCR update note would also say when a restart is needed, whether language models are affected, and whether any package-manager permission prompt is expected. This mock text does not make those claims. It only provides enough material to check the layout and the renderer before real release details are written.

> The terminal opens with a command at the prompt. The user decides whether to execute it.

### Formatting sample

- **Bold text** calls out an action.
- *Italic text* can add a short qualification.
- [A destination link](https://squigit-org.github.io/distribution/) should look like a link and open externally.
- Nested lists should remain readable:
  - First inspect the staged command.
  - Then check the package source.
  - Finally press Enter only when ready.

The inline expression $t_{prepare} < t_{install}$ is only a math-rendering sample. It should not be interpreted as a timing guarantee. This block formula is another layout sample:

$$
T_{total} = T_{prepare} + T_{review} + T_{install}
$$

## Troubleshooting example

If command preparation cannot finish, the action remains disabled. The page should explain whether OCR is unavailable or the platform is unsupported. It should not show an enabled button that has no destination. If opening a terminal fails after clicking, a toast should describe the failure while the release notes stay in place.

For an actual OCR update, follow the package-manager output in the terminal. The app does not silently execute the staged command, and a release note should never imply that it does.

## Preview checklist

- [ ] The button is present from the first render.
- [ ] Preparation shows a spinner and a disabled button.
- [ ] Unsupported systems show a disabled action with an explanation.
- [ ] The table stays inside the note column.
- [ ] Code, links, math, lists, and quotes render like thread assistant messages.
- [ ] The final paragraph remains reachable without moving the action.

This is the end of the mock OCR release note. Its length is intentional so that the full scroll behavior can be checked.
