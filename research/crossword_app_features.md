# Crossword App Feature Inventory — Research for CrossLift (Task 8)

Compiled from knowledge of major crossword apps and platforms. This document catalogs features across popular apps to inform CrossLift's feature set — an iPad app that digitizes printed crosswords via camera.

> **Note:** WebSearch was unavailable during this research pass. All information below is based on well-documented, widely-known features of these apps as of early 2025. A follow-up pass with live web search is recommended to catch any recent additions.

---

## Apps Surveyed

| App | Platform | Model |
|-----|----------|-------|
| NYT Crossword | iOS, Android, Web | Subscription ($40/yr or NYT Games bundle) |
| LA Times Crossword | Web (free), syndicated via apps | Free (ad-supported) |
| Shortyz | Android (open-source) | Free |
| Crossme / Crossword Puzzle Free | iOS, Android | Free with ads / IAP |
| Puzzle Society (Washington Post) | Web | Free |
| CrossClimb (NYT) | iOS, Android, Web | Part of NYT Games |
| Crossword Explorer | iOS | Free + IAP |

---

## 1. Solver / Hint Features

### NYT Crossword
- **Reveal Letter** — fills in the correct letter for the selected cell, marks it with a visual indicator (small triangle).
- **Reveal Word** — fills in the entire current word (across or down).
- **Reveal Puzzle** — fills in every remaining cell (ends the solve).
- **Check Square** — verifies whether the currently selected cell is correct; incorrect letters are flagged.
- **Check Word** — checks all letters in the current word.
- **Check Puzzle** — checks every filled cell; incorrect ones get flagged.
- **Autocheck mode** — toggle that continuously checks letters as you type; incorrect entries are immediately highlighted. Disqualifies the solve from streak/stats in some views.
- **Clear Puzzle / Clear Incorrect** — option to remove all wrong letters while keeping correct ones.
- Any use of Reveal marks the puzzle as "assisted" in stats.

### LA Times Crossword (via syndicated web player)
- Check letter, check word, check puzzle.
- Reveal letter, reveal word, reveal puzzle.
- Generally simpler than NYT — fewer granular options.

### Shortyz
- Check letter, check word (relies on solution data embedded in .puz files).
- No autocheck mode.
- Errors highlighted in red when checked.

### Crossme / Crossword Puzzle Free
- Hint system (reveal a letter) — often costs in-app currency or shows an ad.
- Check puzzle to highlight wrong answers.
- Some versions: "smart hints" that reveal the easiest remaining clue.

### Key Takeaways for CrossLift
- Must-have: Check letter, check word, check puzzle, reveal letter, reveal word.
- Valuable: Autocheck toggle, "clear incorrect" option.
- Since CrossLift digitizes printed puzzles, it needs the solution key captured via OCR or user-verified to power these features. Consider a "no solution available" mode where hints are disabled.

---

## 2. Timer and Scoring

### NYT Crossword
- **Timer** prominently displayed at top of puzzle; starts on first input.
- Timer can be paused (puzzle is hidden while paused).
- Completion time recorded in stats.
- **No point-based scoring** — performance is measured purely by time and whether assists were used.
- Mini crossword has a separate leaderboard based on completion time.

### LA Times Crossword
- Timer displayed; records completion time.
- No scoring beyond time.

### Shortyz
- Timer with pause functionality.
- Tracks completion time per puzzle.
- Shows percentage complete.

### Crossme
- Timer, optional.
- Some versions include a "score" based on accuracy and speed.

### Key Takeaways for CrossLift
- Timer with pause is essential.
- Track: completion time, whether hints were used, accuracy percentage.
- Consider a "personal best" tracker per puzzle difficulty (e.g., Monday vs. Saturday for NYT-style grading).

---

## 3. Navigation UX

### NYT Crossword
- **Tap a cell** to select it; tap again to toggle between Across and Down.
- **Tap a clue** in the clue list to jump to that word in the grid.
- **Swipe/scroll clue bar** — a horizontal clue bar at the bottom shows the current clue; swipe left/right to move to next/previous clue.
- **Auto-advance** — cursor moves to next empty cell in the current word after typing a letter.
- **Skip filled cells** — option to skip over already-filled cells when advancing.
- **Tab / next-clue navigation** — physical keyboard Tab key moves to the next clue.
- **Pencil mode** — enter tentative answers in a lighter/gray font; toggle to convert to "ink."
- **Rebus mode** — allows entering multiple characters in a single cell (for rebus puzzles).
- Arrow keys supported with external keyboard on iPad.

### LA Times Crossword
- Tap to select cell, tap again to toggle direction.
- Clue list on the side (web) or below the grid.
- Auto-advance after letter entry.

### Shortyz
- Tap cell to select; tap again toggles direction.
- Hardware keyboard support (arrow keys, Tab for next clue).
- Long-press for special characters.

### Crossme
- Similar tap-to-toggle pattern.
- Virtual keyboard integrated below grid.
- Some versions: gesture to swipe across a word to select it.

### Key Takeaways for CrossLift
- Tap-to-toggle across/down is the universal standard — must implement.
- Clue bar at bottom (NYT-style) works well on iPad; also show full clue list in a sidebar or slide-out panel.
- Pencil mode is very popular with serious solvers — high-priority feature.
- Rebus support matters for advanced puzzles.
- External keyboard support (arrow keys, Tab, Shift+Tab) is expected on iPad.
- Auto-advance with skip-filled-cells option.

---

## 4. Streak Tracking, Stats, and History

### NYT Crossword
- **Daily streak** — consecutive days of completing the puzzle (no reveals). This is the flagship engagement feature.
- **Streak freeze** — not officially offered, but users are very vocal about losing streaks.
- **Stats dashboard**: total puzzles solved, current streak, longest streak, average solve time by day of week.
- **Solve history** — calendar view showing which days you completed, with color coding (gold star = no assists, blue = completed with assists).
- **Monthly/weekly solve time trends.**

### LA Times Crossword
- Minimal stats — mostly just completion status.
- No streak tracking in the free web version.

### Shortyz
- Tracks completion status per puzzle.
- No streak or advanced stats.

### Crossme
- Basic stats: puzzles completed, average time.
- Some streak tracking in premium versions.

### Key Takeaways for CrossLift
- Streak tracking is a major engagement driver — implement for CrossLift.
- Calendar/history view showing completed puzzles with color coding.
- Stats: total solved, current streak, longest streak, average time, best time.
- Since CrossLift digitizes arbitrary printed puzzles, streaks could track "daily solve habit" rather than a specific publication's calendar.

---

## 5. Input Methods

### NYT Crossword
- **On-screen keyboard** — standard alphabet layout, integrated into the app (not the system keyboard).
- **External/hardware keyboard** — full support on iPad, including arrow keys, Tab, Delete.
- **No handwriting or stylus support.**
- Pencil mode is a "soft input" toggle, not actual handwriting recognition.

### LA Times Crossword
- On-screen keyboard (web-based).
- No stylus/handwriting support.

### Shortyz
- System keyboard on Android.
- Hardware keyboard supported.

### Crossme
- In-app keyboard.
- Some versions support voice input (limited).

### Key Takeaways for CrossLift
- Custom on-screen keyboard (alphabet only, no numbers/symbols) is standard.
- iPad external keyboard support is a must.
- **Apple Pencil / stylus handwriting** — no major crossword app does this well. This is a significant differentiation opportunity for CrossLift. Allowing users to write letters with Apple Pencil (using on-device handwriting recognition) would feel natural for a "digitized print puzzle" experience.
- Consider: tap cell with Pencil to select, then write the letter directly.

---

## 6. Social / Sharing Features

### NYT Crossword
- **Crossword with Friends** — added ~2023-2024, lets you race against a friend on the same puzzle in real time. Split-screen view showing both solvers' progress.
- **Share completion stats** — share card showing solve time, streak, day of week.
- **Leaderboard** (Mini crossword) — shows friends' completion times.
- **No in-puzzle chat.**

### LA Times Crossword
- Share buttons for social media (basic).
- No multiplayer.

### Shortyz
- No social features.

### Crossme
- Basic sharing of completion stats.
- Some versions: global leaderboards.

### Key Takeaways for CrossLift
- Multiplayer/race mode is a differentiator NYT introduced — consider for future.
- Shareable completion cards (image with time, puzzle name, streak) are table stakes.
- Since CrossLift puzzles come from print, sharing could include "I just digitized and solved [Puzzle Name] in X:XX."

---

## 7. Accessibility Features

### NYT Crossword
- **VoiceOver support** — cells and clues are read aloud; grid is navigable.
- **Dynamic Type** — clue text respects system font size.
- **High contrast mode** — optional setting for grid colors.
- **Reduced motion** — respects system setting.
- **Screen reader announces**: cell position, current letter, clue text, direction.

### LA Times Crossword
- Basic web accessibility (keyboard navigation, screen reader labels).
- Limited compared to NYT.

### Shortyz
- Basic Android accessibility (TalkBack support).
- Not deeply optimized.

### Key Takeaways for CrossLift
- VoiceOver support for iOS is important — announce cell coordinates, clue text, entered letters.
- Dynamic Type for clue lists and UI text.
- High contrast and colorblind-friendly grid themes.
- Zoom/pinch on the grid for users with low vision.
- Consider: adjustable grid line thickness, customizable cell size.

---

## 8. Novel / Unique Features Worth Borrowing

| Feature | Source App | Description | CrossLift Relevance |
|---------|-----------|-------------|---------------------|
| **Pencil mode** | NYT | Tentative answers in gray; convert to ink | High — mirrors the real pencil-vs-pen experience of print solving |
| **Rebus entry** | NYT | Multiple characters in one cell | Medium — needed for advanced puzzles |
| **Crossword with Friends** | NYT | Real-time co-solving race | Medium — future feature |
| **Mini Crossword** | NYT | Quick 5x5 daily puzzle, <1 min | Low (CrossLift uses user's own puzzles) |
| **Auto-fill detection** | Various | Detects when puzzle is fully filled and prompts check | High — good UX polish |
| **Clue magnification** | Crossme | Tapping a clue shows it large on screen | Medium — helpful on iPad |
| **Dark mode** | NYT, others | Full dark theme for grid and UI | High — expected on iPad |
| **Puzzle rating** | Crossme, others | Rate puzzle difficulty after completion | Low-Medium |
| **Solve-later bookmarks** | Shortyz | Mark puzzles to return to | High — essential for puzzle library |
| **Grid zoom + pan** | Various | Pinch to zoom, pan around large grids | High — critical for iPad, especially for larger grids |
| **Word reference / dictionary lookup** | Crossword Solver apps | Tap a clue to look up potential answers | Medium — useful but may undermine the solve challenge |
| **Haptic feedback** | NYT (iOS) | Subtle haptic on correct puzzle completion | Low-Medium — nice polish |
| **Celebration animation** | NYT | Confetti / animation on puzzle completion | Medium — satisfying feedback |

---

## 9. Puzzle Management

### NYT Crossword
- **Auto-save** — progress saved automatically; resume anytime.
- **Archive** — subscribers can access puzzles dating back to 1993.
- **Download for offline** — puzzles can be downloaded for offline solving.
- **Puzzle calendar** — browse by date, see completion status.
- **Delete progress** — option to restart a puzzle from scratch.

### LA Times Crossword
- Auto-save on the web player.
- Limited archive (typically ~2 weeks).

### Shortyz
- Downloads .puz files from multiple sources.
- Saves progress locally.
- Puzzle list with completion status indicators.
- Can import .puz files manually.

### Crossme
- Cloud save (with account).
- Puzzle packs organized by theme/difficulty.
- Resume in progress puzzles.

### Key Takeaways for CrossLift
- **Auto-save is mandatory** — save after every letter entry.
- **Puzzle library** — show all digitized puzzles with status (not started, in progress, completed).
- **Metadata per puzzle**: source (e.g., "NYT Sunday 3/15/2026"), date digitized, difficulty, completion time, whether assists were used.
- **Re-solvable** — option to clear and re-solve a puzzle.
- **Import/export** — consider supporting .puz file format for interoperability.
- **iCloud sync** — sync puzzle library across devices.
- **Offline support** — all puzzles are local after camera capture, so offline solving is natural.

---

## Summary: Priority Features for CrossLift MVP

### P0 — Must Have
- Grid display with tap-to-select, tap-to-toggle direction
- On-screen keyboard (custom, letters only)
- Auto-advance cursor with skip-filled option
- Clue bar (current clue) + full clue list panel
- Timer with pause
- Auto-save progress
- Puzzle library with status indicators
- Check letter / check word / check puzzle
- Reveal letter / reveal word
- Dark mode

### P1 — Should Have
- Pencil mode (tentative answers)
- Streak tracking and stats dashboard
- Calendar/history view
- External keyboard support (arrow keys, Tab)
- Completion animation and share card
- VoiceOver / accessibility support
- Grid zoom and pan
- Clear incorrect letters
- Autocheck toggle

### P2 — Nice to Have
- Apple Pencil handwriting input (major differentiator)
- Rebus entry support
- iCloud sync across devices
- .puz file import/export
- Puzzle difficulty rating
- Dictionary/reference lookup
- Haptic feedback
- High-contrast / colorblind themes

### P3 — Future / Stretch
- Multiplayer co-solve (a la NYT "Crossword with Friends")
- Global/friends leaderboards
- AI-powered clue assistance
- Puzzle collections / tagging / folders

---

## CrossLift-Specific Considerations

Since CrossLift digitizes printed crosswords via camera, several unique considerations apply:

1. **Solution availability** — Print puzzles may or may not have solutions available. CrossLift needs a "no solution" mode where check/reveal features are disabled, and a workflow for users to input the solution key later (e.g., photograph the solution page).

2. **OCR accuracy** — Users will need to verify/correct the digitized grid and clues. A clear editing flow post-capture is essential.

3. **Grid structure variety** — Print puzzles come in many grid sizes and styles (American, British/cryptic, barred grids, etc.). The app should handle at least standard American-style blocked grids at MVP.

4. **Clue numbering** — Must be auto-detected or manually adjustable if OCR misreads clue numbers.

5. **Puzzle provenance** — Users may want to tag puzzles with source info (publication, date, author) for their personal library.

6. **Copyright considerations** — The app digitizes puzzles for personal use. The app should not facilitate sharing of copyrighted puzzle content between users.
