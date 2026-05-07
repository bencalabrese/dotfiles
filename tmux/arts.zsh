# shellcheck shell=bash
# Color palette and ASCII art patterns for tmux status bar.
# Sourced by .zshrc; values exported as TMUX_COLOR and TMUX_ART_0..2.

_tmux_palette=(160 28 27 90 37 130 22 55 124 166 32 100)

# 8 patterns × 3 lines. Index selects the pattern, lines go into TMUX_ART_0..2.
_tmux_arts=(
  # 0: zigzag
  '/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/'
  ' \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/'
  '/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/'

  # 1: diagonal
  '\  \  \  \  \  \  \  \  \  \  \  \  \'
  ' \  \  \  \  \  \  \  \  \  \  \  \  '
  '  \  \  \  \  \  \  \  \  \  \  \  \ '

  # 2: dots
  '·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  '
  '  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·'
  '·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  '

  # 3: blocks
  '▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░'
  '░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓'
  '▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░▓░'

  # 4: triangles
  '▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  '
  ' ▽  ▽  ▽  ▽  ▽  ▽  ▽  ▽  ▽  ▽  ▽  ▽ '
  '▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  '

  # 5: wave
  '~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  '
  '  ~~~  ~~~  ~~~  ~~~  ~~~  ~~~  ~~~   '
  '~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  '

  # 6: grid
  '┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼ '
  '│ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ '
  '┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼ '

  # 7: stars
  '★  ·  ★  ·  ★  ·  ★  ·  ★  ·  ★  ·  '
  '·  ★  ·  ★  ·  ★  ·  ★  ·  ★  ·  ★  '
  '★  ·  ★  ·  ★  ·  ★  ·  ★  ·  ★  ·  '
)

# $1 = hash value; sets TMUX_COLOR and TMUX_ART_0..2
_tmux_pick_theme() {
  local hash="$1"
  local n_colors=${#_tmux_palette[@]}
  local n_arts=$(( ${#_tmux_arts[@]} / 3 ))

  export TMUX_COLOR=${_tmux_palette[$(( hash % n_colors + 1 ))]}

  local art_idx=$(( hash % n_arts ))
  local base=$(( art_idx * 3 ))
  export TMUX_ART_0="${_tmux_arts[$(( base + 1 ))]}"
  export TMUX_ART_1="${_tmux_arts[$(( base + 2 ))]}"
  export TMUX_ART_2="${_tmux_arts[$(( base + 3 ))]}"
}
