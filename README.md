# CrossLift

**Lift a Crossword.** An iPad app for digitizing printed crosswords and solving them with Apple Pencil.

Take a photo of a crossword puzzle from a newspaper, book, or magazine, and solve it digitally on your iPad — with the tactile feel of writing by hand.

## Features

- **Photo import** — Photograph a crossword with your iPad camera or choose an image from your photo library.
- **Apple Pencil drawing** — Write directly on the crossword image with your Apple Pencil. Your handwriting sits on a layer above the original image.
- **Color picker** — Choose from 6 ink colors (blue, red, green, black, purple, orange) to organize your work or distinguish between solve attempts.
- **Eraser** — Erase strokes with the bitmap eraser tool.
- **Undo / Clear** — Undo your last stroke or clear all drawings.
- **Pan and zoom** — One-finger pan, pinch-to-zoom, and double-tap to zoom in or out. Tap the "Fit" button to reset to the full image view.
- **Magnifier** — Long-press anywhere on the puzzle to open a magnified view of that area. Drag while holding to reposition the magnifier. After releasing, drag within the magnified popup to pan around. Draw with Apple Pencil directly in the magnified view — strokes appear at the correct size and position on the main canvas.

## User Guide

### Getting Started
1. Open CrossLift on your iPad.
2. Tap **Take a Photo** to photograph a printed crossword, or **Choose from Library** to select an existing image.
3. The crossword image fills the screen. You're ready to solve!

### Writing Answers
- Use your **Apple Pencil** to write letters in the crossword squares.
- Tap a **color dot** in the toolbar to change ink color.
- Tap the **eraser icon** to switch to eraser mode. Tap any color to switch back to pen mode.
- Tap **Undo** to undo your last stroke, or **Clear** to erase all drawings.

### Navigating the Puzzle
- **One-finger drag** to pan around the image.
- **Pinch** to zoom in and out.
- **Double-tap** to toggle between zoomed-in and full view.
- Tap the **Fit button** (arrows icon) to reset to the full image view.

### Using the Magnifier
The magnifier is designed for reading small clue text — especially useful for printed crosswords with small print.

1. **Long-press** (hold ~0.3 seconds) anywhere on the puzzle to open the magnifier.
2. **Drag while holding** to move the magnified area in real time.
3. **Release** to lock the magnifier in place.
4. **Drag inside the magnifier popup** to pan around the magnified area.
5. **Draw with Apple Pencil** inside the magnifier for precise writing in small squares.
6. **Tap the dimmed background** or the **Dismiss button** to close the magnifier.

## Tech Stack

- **Swift / SwiftUI** — Native iPad app
- **PencilKit** — Apple Pencil drawing with pressure sensitivity and palm rejection
- **UIKit** — UIScrollView for pan/zoom, custom UIViewRepresentable bridges

## Requirements

- iPad with Apple Pencil support
- iOS 18.0 or later
- Xcode 26+ (for building from source)

## Building from Source

1. Clone the repository.
2. Open `CrossLift/CrossLift.xcodeproj` in Xcode.
3. Select an iPad simulator or connect your iPad.
4. Build and run (Cmd+R).

Note: Running on a physical iPad requires an Apple Developer account (free accounts work but the app expires after 7 days).

## Roadmap

- Confidence toggle (tentative vs locked-in answers)
- OCR-based "prettified" crossword view
- Crossword solver / hint system
- Multiplayer with per-user drawing layers

## License

This project is currently in active development.
