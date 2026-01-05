# DromsTrashKillCount (DTKC)


A lightweight World of Warcraft addon that tracks trash kills and displays multikill streaks in real-time. Originally a simple counter, DTKC adds advanced multikill logic and customizable visual tiers for an arcade-like experience.

---

## ✨ Features

- **Real-Time Tracking:** Instant updates for total trash kills.
- **Multikill Logic:** Group kills together using configurable time windows.
- **Dynamic Visuals:** Text labels, font sizes, and colors scale with your streak intensity.
- **Zero Dependencies:** Optimized performance with no external libraries.
- **Independent Toggles:** Hide or show the Total and Multikill frames separately.

---

## ⚔️ Multikill Modes

DTKC calculates streaks using two distinct methods:

### Streak Mode
*   **Logic:** Every kill **refreshes** the timer window.
*   **Best For:** Sustained combat and continuous pulls (Diablo-style).

### Burst Mode
*   **Logic:** The timer is **fixed** and does not refresh.
*   **Best For:** Tracking "one-shot" AoE explosions or simultaneous kills (Use short windows like 0.15s).

---

## 🛠️ Slash Commands

Use `/dtkc` followed by the commands below to configure your experience.

### Timing & Configuration
- `/dtkc window <seconds>` — Set the time window for grouping kills.
- `/dtkc display <seconds>` — Set how long the multikill frame stays visible.
- `/dtkc mode streak` — Switch to Streak logic.
- `/dtkc mode burst` — Switch to Burst logic.

### Visibility Toggles
- `/dtkc total show/hide` — Toggle the total kill counter frame.
- `/dtkc multi show/hide` — Toggle the multikill streak frame.

---

## 🎨 Visual Progression

The multikill frame evolves as you slay more enemies. The UI shifts through these tiers:

1. **Multi Kill** (Double/Triple)
2. **Mega Kill** 
3. **Ultra Kill**
4. **Rampage**
5. **9 more ranks for you to find out**

---

## 📦 Compatibility & Installation

1. Download the latest release.
2. Extract the content of the src folder to your `Interface/AddOns/` directory.
3. **Version:** Optimized for **World of Warcraft 3.3.5 (WotLK)**.
4. **Persistence:** Settings are currently session-based.

---

## 📜 License
This project is free to use and modify. Contributions are welcome!
