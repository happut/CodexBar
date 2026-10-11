---
summary: "Synthetic menu-bar progress-bar comparison renders for the graphical usage-bar token PR."
read_when:
  - Reviewing the menu-bar graphical progress bar UI change
---

# Menu bar progress bar screenshots

Deterministic synthetic renders. No real account, credential, session, or personal identifier is included.
Values match the renderer test fixtures (`5h` session at 89% used, weekly at 89% used, matching reset countdowns).

| File | What it shows |
| --- | --- |
| [comparison.png](comparison.png) | Side-by-side before/after of the stacked menu-bar title |
| [before-percent-text.png](before-percent-text.png) | Current percent-text tokens (`5h 89% · in 4h 46m`) |
| [after-graphical-bars.png](after-graphical-bars.png) | New `progressBar` tokens drawn as capsule `NSTextAttachment` bars |

These are illustrative PIL renders of the status-item title composition, not live accessibility captures.
