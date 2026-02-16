taskrpg_prompt() {
  local file="$HOME/.local/share/task/rpg/data/level.dat"

  [[ ! -f "$file" ]] && return

  read LEVEL CUR_XP TOTAL_XP < "$file"
  local NEXT_LVL_XP=$((50 * LEVEL))

  # Progress bar math
  local bar_length=10
  local filled=$(( CUR_XP * bar_length / NEXT_LVL_XP ))
  local empty=$(( bar_length - filled ))

  local bar=""
  for i in {1..$filled}; do bar+="█"; done
  for i in {1..$empty}; do bar+="░"; done

  echo "%F{magenta}Lv$LEVEL%f %F{green}$bar%f"
}
