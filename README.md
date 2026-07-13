🎼 Notation Editor (Simple)

A minimal **musical notation editor** for the command line.  
Create, edit, save, load, and play simple note sequences (e.g., `C4`, `D#4`, `Bb3`).  
Built in **7 programming languages** – ideal for learning music fundamentals, data structures, or quick prototyping.

## ✨ Features
- **Add notes** – append a note (e.g., `C4`, `F#5`, `Bb3`).
- **Remove notes** – delete a note by its index.
- **List notes** – show the entire sequence with indices.
- **Save/Load** – store your melody in a plain text file (one note per line).
- **Play** – attempt to play the melody using system beeps or display frequencies.
- **Cross‑platform** – works on Windows, macOS, and Linux (with varying sound support).

## 🗂 Languages & Files
| Language          | File         |
|-------------------|--------------|
| Python            | `notes.py`   |
| Go                | `notes.go`   |
| JavaScript (Node) | `notes.js`   |
| C#                | `Notes.cs`   |
| Java              | `Notes.java` |
| Ruby              | `notes.rb`   |
| Swift             | `notes.swift`|

## 🚀 How to Run
Each file is standalone – run it with the appropriate interpreter/compiler.

| Language | Command |
|----------|---------|
| Python   | `python notes.py` |
| Go       | `go run notes.go` |
| JavaScript | `node notes.js` |
| C#       | `dotnet run` (or `csc Notes.cs && Notes.exe`) |
| Java     | `javac Notes.java && java Notes` |
| Ruby     | `ruby notes.rb` |
| Swift    | `swift notes.swift` |

**Sound support:**  
- **Windows**: uses `Console.Beep` (C#) / `winsound.Beep` (Python).  
- **Linux**: tries `beep` (install via `sudo apt install beep`).  
- **macOS**: tries `afplay` (macOS built‑in) – note: `afplay` alone cannot generate a tone, so on macOS the program will only display frequencies.  
If sound is unavailable, the program prints frequencies instead.

## 📊 Example Session
=== Notation Editor ===

Add note

Remove note

List notes

Play melody

Save to file

Load from file

Exit
Choose: 1
Enter note (e.g., C4, D#4): C4
Added: C4

Choose: 1
Enter note: E4
Added: E4

Choose: 3
[1] C4
[2] E4

Choose: 4
Playing: C4 (261.6 Hz)
Playing: E4 (329.6 Hz)

Choose: 5
Filename: melody.txt
Saved to melody.txt

Choose: 7
Goodbye!

text

## 🔧 Commands (Interactive Menu)
| Option | Description |
|--------|-------------|
| 1 | Add a note |
| 2 | Remove a note by index |
| 3 | List all notes |
| 4 | Play the melody |
| 5 | Save notes to a text file |
| 6 | Load notes from a text file |
| 7 | Exit |

## 📁 File Format
Each line contains a single note name (e.g., `C4`, `F#5`, `Bb3`).  
Empty lines are ignored.

## 🤝 Contributing
Add support for chords, durations, or a graphical interface – PRs welcome!

## 📜 License
MIT – use freely.
💻 Code Implementations
1. Python (notes.py)
