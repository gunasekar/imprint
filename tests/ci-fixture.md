<!--
title:        "imprint CI smoke test"
subtitle:     "A render that must always succeed"
description:  "A minimal document that exercises the pandoc -> typst render path without Mermaid, so CI stays deterministic and headless-Chromium-free."
author:       "CI"
date:         "2026"
category:     "Test"
footer_text:  "imprint CI"
cover:        true
accent:       "#2563EB"
font_body:    "Source Sans 3"
font_head:    "IBM Plex Sans"
font_mono:    "JetBrains Mono"
-->
# Render smoke test

This fixture deliberately avoids Mermaid so the render needs only pandoc,
Typst, and python3 — no headless browser. It still covers the constructs
imprint restyles, so a regression in the template or preprocessor fails CI.

> **Note.** A block quote becomes a tinted callout, and a bold `**Label.**`
> lead gives it a colored label.

## Tables

| Setting | Where | What it does |
|--------|--------|-------------------------------------------------|
| `accent` | config | The single theme color for links, rules, headers |
| `cover` | front matter | Whether the title page renders |

## A task list

- [x] Front matter parsed
- [ ] Not done yet

<!-- pagebreak -->

## Code

Inline `imprint in.md` and a fenced block:

```sh
imprint report.md --cover
```
