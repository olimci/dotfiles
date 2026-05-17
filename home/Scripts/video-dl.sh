#!/bin/sh
set -eu

dest="$HOME/Downloads/Movies"
url="$(pbpaste)"

if [ -z "$url" ]; then
  printf 'clipboard is empty\n' >&2
  exit 1
fi

mkdir -p "$dest"
yt-dlp -o "$dest/%(title)s.%(ext)s" "$url"
