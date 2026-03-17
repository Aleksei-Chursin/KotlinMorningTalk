#!/bin/bash
set -e  # Exit on error

# Build presentation from Markdown to reveal.js HTML slideshow
# Each # heading and --- separator creates a new slide

# Check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo "❌ Error: pandoc is not installed"
    echo "Install it with: sudo apt-get install pandoc"
    exit 1
fi

pandoc presentation.md \
  -t revealjs \
  -s \
  -o index.html \
  --slide-level=1 \
  --metadata generator=pandoc \
  -V theme=white \
  -V transition=slide

echo "✓ Presentation built: index.html"
echo "Open index.html in a browser to view the slideshow"
