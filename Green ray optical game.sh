#!/bin/sh
echo -ne '\033c\033]0;Green ray optical game\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Green ray optical game.x86_64" "$@"
