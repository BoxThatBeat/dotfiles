#!/usr/bin/env python3

import sys
import json
import os
from datetime import date

def read_tasks_from_stdin():
    tasks = []
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        tasks.append(json.loads(line))
    return tasks

def main():
    tasks = read_tasks_from_stdin()

    # on-modify gives us 2 tasks: original + modified
    if not tasks:
        sys.exit(0)

    if len(tasks) == 1:
        task = tasks[0]
    else:
        # Use the modified version (second object)
        task = tasks[1]

    # Only award XP when task becomes completed
    if task.get("status") != "completed":
        print(json.dumps(task))
        return

    # Resolve TaskWarrior data directory
    taskdata = os.environ.get(
        "TASKDATA",
        os.path.expanduser("~/.local/share/task")
    )

    rpgdir = os.path.join(taskdata, "rpg")
    datadir = os.path.join(rpgdir, "data")

    os.makedirs(datadir, exist_ok=True)

    level_file = os.path.join(datadir, "level.dat")
    streak_file = os.path.join(datadir, "streak.dat")
    event_file = os.path.join(rpgdir, "event.trigger")

    # -----------------------------
    # Load Level Data
    # -----------------------------
    if os.path.exists(level_file):
        try:
            with open(level_file, "r") as f:
                level, cur_xp, total_xp = map(int, f.read().strip().split())
        except Exception:
            level, cur_xp, total_xp = 1, 0, 0
    else:
        level, cur_xp, total_xp = 1, 0, 0

    # -----------------------------
    # XP Calculation
    # -----------------------------
    tags = task.get("tags", [])

    if "big" in tags:
        xp = 20
    elif "medium" in tags:
        xp = 15
    else:
        xp = 10

    cur_xp += xp
    total_xp += xp

    next_level_xp = 50 * level
    if cur_xp >= next_level_xp:
        cur_xp -= next_level_xp
        level += 1

    with open(level_file, "w") as f:
        f.write(f"{level} {cur_xp} {total_xp}")

    # -----------------------------
    # Daily Streak
    # -----------------------------
    today = date.today().isoformat()

    if os.path.exists(streak_file):
        try:
            with open(streak_file, "r") as f:
                last_date, streak = f.read().strip().split()
                streak = int(streak)
        except Exception:
            last_date, streak = "", 0
    else:
        last_date, streak = "", 0

    if last_date == today:
        streak += 1
    else:
        streak = 1

    with open(streak_file, "w") as f:
        f.write(f"{today} {streak}")

    # -----------------------------
    # Trigger sync event
    # -----------------------------
    try:
        with open(event_file, "w") as f:
            f.write(str(total_xp))
    except Exception:
        pass

    # CRITICAL: output exactly ONE JSON task
    print(json.dumps(task))

if __name__ == "__main__":
    main()
