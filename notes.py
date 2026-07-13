# notes.py
import os
import sys
import math
import time
import platform

# Frequency table for notes in octave 4
NOTE_FREQS = {
    'C': 261.63, 'C#': 277.18, 'Db': 277.18,
    'D': 293.66, 'D#': 311.13, 'Eb': 311.13,
    'E': 329.63,
    'F': 349.23, 'F#': 369.99, 'Gb': 369.99,
    'G': 392.00, 'G#': 415.30, 'Ab': 415.30,
    'A': 440.00, 'A#': 466.16, 'Bb': 466.16,
    'B': 493.88
}

def parse_note(note):
    """Parse note string like 'C4' or 'Bb3' into (freq, name)."""
    note = note.strip()
    if not note:
        return None, None
    # Separate letter part and octave
    letter = ''
    octave = 4
    i = 0
    while i < len(note) and note[i].isalpha():
        letter += note[i]
        i += 1
    if i < len(note) and note[i].isdigit():
        octave = int(note[i:])
    # Map letter to base frequency
    if letter not in NOTE_FREQS:
        return None, None
    base_freq = NOTE_FREQS[letter]
    freq = base_freq * (2 ** (octave - 4))
    return freq, note

def play_freq(freq, duration_ms=300):
    """Play a frequency using system beep or fallback to print."""
    if freq is None or freq <= 0:
        return
    system = platform.system()
    try:
        if system == 'Windows':
            import winsound
            winsound.Beep(int(freq), duration_ms)
        elif system == 'Linux':
            # Try using the 'beep' command
            import subprocess
            subprocess.run(['beep', '-f', str(int(freq)), '-l', str(duration_ms)], check=False)
        else:
            # macOS: no built-in beep; just print
            print(f"  (would play {freq:.1f} Hz)")
    except Exception as e:
        print(f"  (sound failed: {e})")

def play_notes(notes):
    if not notes:
        print("No notes to play.")
        return
    print("Playing melody...")
    for note in notes:
        note = note.strip()
        if not note:
            continue
        freq, parsed = parse_note(note)
        if freq is None:
            print(f"  Skipping unknown note: {note}")
            continue
        print(f"  {parsed} ({freq:.1f} Hz)")
        play_freq(freq, 300)
        time.sleep(0.05)

def main():
    notes = []
    print("=== Notation Editor ===")
    while True:
        print("\n1. Add note")
        print("2. Remove note")
        print("3. List notes")
        print("4. Play melody")
        print("5. Save to file")
        print("6. Load from file")
        print("7. Exit")
        choice = input("Choose: ").strip()
        if choice == '1':
            note = input("Enter note (e.g., C4, D#4): ").strip()
            if note:
                notes.append(note)
                print(f"Added: {note}")
            else:
                print("Invalid note.")
        elif choice == '2':
            if not notes:
                print("No notes to remove.")
                continue
            try:
                idx = int(input("Index to remove: ")) - 1
                if 0 <= idx < len(notes):
                    removed = notes.pop(idx)
                    print(f"Removed: {removed}")
                else:
                    print("Invalid index.")
            except ValueError:
                print("Invalid number.")
        elif choice == '3':
            if not notes:
                print("No notes.")
            else:
                for i, n in enumerate(notes, 1):
                    print(f"[{i}] {n}")
        elif choice == '4':
            play_notes(notes)
        elif choice == '5':
            fname = input("Filename: ").strip()
            if not fname:
                continue
            with open(fname, 'w') as f:
                for n in notes:
                    f.write(n + '\n')
            print(f"Saved to {fname}")
        elif choice == '6':
            fname = input("Filename: ").strip()
            try:
                with open(fname, 'r') as f:
                    loaded = [line.strip() for line in f if line.strip()]
                notes = loaded
                print(f"Loaded {len(notes)} notes from {fname}")
            except FileNotFoundError:
                print("File not found.")
        elif choice == '7':
            print("Goodbye!")
            break
        else:
            print("Invalid choice.")

if __name__ == "__main__":
    main()
