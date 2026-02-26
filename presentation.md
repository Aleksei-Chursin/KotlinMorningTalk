---
title: Master Class on HTML Slides
author: Aleks
date: 2024-02-26
---

# Why HTML Slides?
- **Host for free**: Use GitHub Pages to share a URL instead of emailing large files.
- **No Microsoft Office**: Avoid the "horrors" of PPTX and DOCX formats.
- **Programmatic**: Generate slides directly from text or code.
- Command: pandoc -t slidy presentation.md -o index.html --self-contained

# Python Code Highlighting
As mentioned in the "Pro-tips," you can get automatic syntax highlighting by using three backticks:

# Comparison Table
| Feature | Markdown | Excel |
| :--- | :---: | ---: |
| Version Control | Easy | Hard |
| Data Safety | High | Low (Auto-formats) |
| Free Hosting | Yes | No |

```python
def hello_kotlin():
    print("Kotlin is great, but this highlighter loves Python!")

hello_kotlin()
```

# Image slide
![Screenshot 2026-01-24 184909.png](images/Screenshot%202026-01-24%20184909.png)