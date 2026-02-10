#!/usr/bin/env zsh

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:$PATH"

# Capture input JSON
INPUT=$(cat)
[[ -z "$INPUT" ]] && exit 0

pass_task() {
  echo "$INPUT"
  exit 0
}

# Parse safely
STATUS=$(echo "$INPUT" | jq -r 'try .status catch ""')
[[ "$STATUS" != "completed" ]] && pass_task

# -----------------------------
# Resolve dirs
# -----------------------------
TASKDATA=$(task _get rc.data.location 2>/dev/null)
[[ -z "$TASKDATA" ]] && TASKDATA="$HOME/.local/share/task"

RPGDIR="$TASKDATA/rpg"
DATADIR="$RPGDIR/data"
SOUNDDIR="$RPGDIR/sounds"
mkdir -p "$DATADIR"

lvl_file="$DATADIR/level.dat"
streak_file="$DATADIR/streak.dat"

# Load Level
if [[ -f "$lvl_file" ]]; then
  read LEVEL CUR_XP TOTAL_XP <"$lvl_file"
else
  LEVEL=1 CUR_XP=0 TOTAL_XP=0
fi

# XP gain
TAGS=$(echo "$INPUT" | jq -r 'try (.tags // []) | join(" ")')
if [[ "$TAGS" == *"big"* ]]; then xp=20
elif [[ "$TAGS" == *"medium"* ]]; then xp=15
else xp=10
fi

CUR_XP=$((CUR_XP + xp))
TOTAL_XP=$((TOTAL_XP + xp))
NEXT_LVL_XP=$((50 * LEVEL))
LEVEL_UP=0
if ((CUR_XP >= NEXT_LVL_XP)); then
  CUR_XP=$((CUR_XP - NEXT_LVL_XP))
  LEVEL=$((LEVEL + 1))
  LEVEL_UP=1
fi
echo "$LEVEL $CUR_XP $TOTAL_XP" >"$lvl_file"

# Daily streak
today=$(date +%F)
if [[ -f "$streak_file" ]]; then
  read LAST_DATE STREAK <"$streak_file"
else
  LAST_DATE="" STREAK=0
fi
if [[ "$LAST_DATE" == "$today" ]]; then STREAK=$((STREAK + 1))
else STREAK=1
fi
echo "$today $STREAK" >"$streak_file"

# -----------------------------
# NORMAL EFFECTS (send all output to /dev/null)
# -----------------------------
[[ -f "$SOUNDDIR/complete.wav" ]] && play -q "$SOUNDDIR/complete.wav" reverb 20 >/dev/null 2>&1 &

command -v keymapp >/dev/null 2>&1 && {
  keymapp set-led --all "#FF00FF" >/dev/null 2>&1
  sleep 0.2
  keymapp set-led --all "#000000" >/dev/null 2>&1
}

command -v notify-send >/dev/null 2>&1 &&
  notify-send "✅ Task Complete" "+$xp XP | Streak: $STREAK" >/dev/null 2>&1 &

# -----------------------------
# LEVEL UP EFFECTS
# -----------------------------
if ((LEVEL_UP == 1)); then
  [[ -f "$SOUNDDIR/levelup.wav" ]] &&
    play -q "$SOUNDDIR/levelup.wav" reverb 60 >/dev/null 2>&1 &

  command -v notify-send >/dev/null 2>&1 &&
    notify-send "🎉 LEVEL UP!" "You reached level $LEVEL" >/dev/null 2>&1 &

  command -v espeak >/dev/null 2>&1 &&
    espeak "Level $LEVEL achieved." >/dev/null 2>&1 &

  [[ -f "$RPGDIR/confetti.mp4" ]] && command -v mpv >/dev/null 2>&1 &&
    mpv --fullscreen --no-audio --loop-file=inf "$RPGDIR/confetti.mp4" >/dev/null 2>&1 &
fi

# -----------------------------
# Pass JSON back (last thing)
# -----------------------------
echo "$INPUT"
exit 0

