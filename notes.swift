// notes.swift
import Foundation

let noteFreqs: [String: Double] = [
    "C": 261.63, "C#": 277.18, "Db": 277.18,
    "D": 293.66, "D#": 311.13, "Eb": 311.13,
    "E": 329.63,
    "F": 349.23, "F#": 369.99, "Gb": 369.99,
    "G": 392.00, "G#": 415.30, "Ab": 415.30,
    "A": 440.00, "A#": 466.16, "Bb": 466.16,
    "B": 493.88
]

func parseNote(_ note: String) -> (freq: Double?, parsed: String?) {
    let n = note.trimmingCharacters(in: .whitespacesAndNewlines)
    if n.isEmpty { return (nil, nil) }
    var letter = ""
    var octave = 4
    var i = n.startIndex
    while i < n.endIndex && (n[i].isLetter || n[i] == "#") {
        letter.append(n[i])
        i = n.index(after: i)
    }
    if i < n.endIndex && n[i].isNumber {
        let octStr = String(n[i...])
        octave = Int(octStr) ?? 4
    }
    if let base = noteFreqs[letter] {
        let freq = base * pow(2.0, Double(octave - 4))
        return (freq, n)
    }
    return (nil, nil)
}

func playFreq(_ freq: Double?) {
    guard let f = freq, f > 0 else { return }
    #if os(macOS)
    print("  (would play \(String(format: "%.1f", f)) Hz on macOS)")
    #elseif os(Windows)
    print("  (would play \(String(format: "%.1f", f)) Hz on Windows)")
    #else
    // Linux: try beep command
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["beep", "-f", String(Int(f)), "-l", "300"]
    process.standardOutput = FileHandle.nullDevice
    process.standardError = FileHandle.nullDevice
    try? process.run()
    #endif
}

func playNotes(_ notes: [String]) {
    if notes.isEmpty {
        print("No notes to play.")
        return
    }
    print("Playing melody...")
    for n in notes {
        let (freq, parsed) = parseNote(n)
        guard let f = freq, let p = parsed else {
            print("  Skipping unknown note: \(n)")
            continue
        }
        print("  \(p) (\(String(format: "%.1f", f)) Hz)")
        playFreq(f)
        Thread.sleep(forTimeInterval: 0.3)
    }
}

func main() {
    var notes: [String] = []
    print("=== Notation Editor ===")
    while true {
        print("\n1. Add note")
        print("2. Remove note")
        print("3. List notes")
        print("4. Play melody")
        print("5. Save to file")
        print("6. Load from file")
        print("7. Exit")
        print("Choose: ", terminator: "")
        guard let choice = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else { continue }
        switch choice {
        case "1":
            print("Enter note (e.g., C4, D#4): ", terminator: "")
            guard let note = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else { break }
            if !note.isEmpty {
                notes.append(note)
                print("Added: \(note)")
            } else {
                print("Invalid note.")
            }
        case "2":
            if notes.isEmpty {
                print("No notes to remove.")
                break
            }
            print("Index to remove: ", terminator: "")
            guard let idxStr = readLine(), let idx = Int(idxStr.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                print("Invalid number.")
                break
            }
            if idx >= 1 && idx <= notes.count {
                let removed = notes.remove(at: idx-1)
                print("Removed: \(removed)")
            } else {
                print("Invalid index.")
            }
        case "3":
            if notes.isEmpty {
                print("No notes.")
            } else {
                for (i, n) in notes.enumerated() {
                    print("[\(i+1)] \(n)")
                }
            }
        case "4":
            playNotes(notes)
        case "5":
            print("Filename: ", terminator: "")
            guard let fname = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines), !fname.isEmpty else { break }
            let content = notes.joined(separator: "\n")
            do {
                try content.write(toFile: fname, atomically: true, encoding: .utf8)
                print("Saved to \(fname)")
            } catch {
                print("Error saving: \(error)")
            }
        case "6":
            print("Filename: ", terminator: "")
            guard let fname = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines), !fname.isEmpty else { break }
            do {
                let content = try String(contentsOfFile: fname, encoding: .utf8)
                let loaded = content.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                notes = loaded
                print("Loaded \(notes.count) notes from \(fname)")
            } catch {
                print("File not found.")
            }
        case "7":
            print("Goodbye!")
            return
        default:
            print("Invalid choice.")
        }
    }
}

main()
