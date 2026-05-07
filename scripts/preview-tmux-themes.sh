#!/usr/bin/env zsh
# Cycles through all 12 tmux theme combinations (covers all 8 patterns + all 12 colors).
# Usage: ./scripts/preview-tmux-themes.sh

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES_DIR/tmux/arts.zsh"

PATTERN_NAMES=(zigzag diagonal dots blocks triangles wave grid stars)
TOTAL=12

for hash in {0..$((TOTAL - 1))}; do
  _tmux_pick_theme "$hash"
  pattern_idx=$(( hash % 8 ))
  pattern_name="${PATTERN_NAMES[$((pattern_idx + 1))]}"

  tmux kill-server 2>/dev/null

  echo ""
  echo "  ID $hash / $((TOTAL - 1))  —  pattern: $pattern_name  color: $TMUX_COLOR"
  echo "  Exit tmux with 'exit' or Ctrl-D to advance."
  echo ""

  tmux -f "$DOTFILES_DIR/tmux/tmux.conf" new-session \
    -e "ONA_WORKSPACE_NAME=id-$hash / $pattern_name" \
    -e "ONA_WORKSPACE_COLOR=$TMUX_COLOR" \
    -e "TMUX_COLOR=$TMUX_COLOR" \
    -e "TMUX_ART_0=$TMUX_ART_0" \
    -e "TMUX_ART_1=$TMUX_ART_1" \
    -e "TMUX_ART_2=$TMUX_ART_2"
done

tmux kill-server 2>/dev/null
echo "Done — all $TOTAL themes previewed."
