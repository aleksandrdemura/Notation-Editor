// notes.go
package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"runtime"
	"strconv"
	"strings"
	"time"
)

var noteFreqs = map[string]float64{
	"C":  261.63, "C#": 277.18, "Db": 277.18,
	"D":  293.66, "D#": 311.13, "Eb": 311.13,
	"E":  329.63,
	"F":  349.23, "F#": 369.99, "Gb": 369.99,
	"G":  392.00, "G#": 415.30, "Ab": 415.30,
	"A":  440.00, "A#": 466.16, "Bb": 466.16,
	"B":  493.88,
}

func parseNote(note string) (float64, string) {
	note = strings.TrimSpace(note)
	if note == "" {
		return 0, ""
	}
	// Separate letter and octave
	letter := ""
	octave := 4
	i := 0
	for i < len(note) && (note[i] >= 'A' && note[i] <= 'G' || note[i] == '#') {
		letter += string(note[i])
		i++
	}
	if i < len(note) && note[i] >= '0' && note[i] <= '9' {
		oct, _ := strconv.Atoi(note[i:])
		octave = oct
	}
	if val, ok := noteFreqs[letter]; ok {
		freq := val * math.Pow(2, float64(octave-4))
		return freq, note
	}
	return 0, ""
}

func playFreq(freq float64) {
	if freq <= 0 {
		return
	}
	osName := runtime.GOOS
	switch osName {
	case "windows":
		// Use syscall to call Beep (kernel32)
		// We'll use external command 'beep' not available; we print instead.
		fmt.Printf("  (would play %.1f Hz on Windows)\n", freq)
	default:
		// For Linux/macOS, we can try using 'beep' or print
		// For macOS, no built-in; just print.
		fmt.Printf("  (would play %.1f Hz)\n", freq)
	}
}

func playNotes(notes []string) {
	if len(notes) == 0 {
		fmt.Println("No notes to play.")
		return
	}
	fmt.Println("Playing melody...")
	for _, n := range notes {
		n = strings.TrimSpace(n)
		if n == "" {
			continue
		}
		freq, parsed := parseNote(n)
		if freq == 0 {
			fmt.Printf("  Skipping unknown note: %s\n", n)
			continue
		}
		fmt.Printf("  %s (%.1f Hz)\n", parsed, freq)
		playFreq(freq)
		time.Sleep(300 * time.Millisecond)
	}
}

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	var notes []string
	fmt.Println("=== Notation Editor ===")
	for {
		fmt.Println("\n1. Add note")
		fmt.Println("2. Remove note")
		fmt.Println("3. List notes")
		fmt.Println("4. Play melody")
		fmt.Println("5. Save to file")
		fmt.Println("6. Load from file")
		fmt.Println("7. Exit")
		fmt.Print("Choose: ")
		scanner.Scan()
		choice := strings.TrimSpace(scanner.Text())
		switch choice {
		case "1":
			fmt.Print("Enter note (e.g., C4, D#4): ")
			scanner.Scan()
			note := strings.TrimSpace(scanner.Text())
			if note != "" {
				notes = append(notes, note)
				fmt.Printf("Added: %s\n", note)
			} else {
				fmt.Println("Invalid note.")
			}
		case "2":
			if len(notes) == 0 {
				fmt.Println("No notes to remove.")
				continue
			}
			fmt.Print("Index to remove: ")
			scanner.Scan()
			idxStr := strings.TrimSpace(scanner.Text())
			idx, err := strconv.Atoi(idxStr)
			if err != nil || idx < 1 || idx > len(notes) {
				fmt.Println("Invalid index.")
				continue
			}
			removed := notes[idx-1]
			notes = append(notes[:idx-1], notes[idx:]...)
			fmt.Printf("Removed: %s\n", removed)
		case "3":
			if len(notes) == 0 {
				fmt.Println("No notes.")
			} else {
				for i, n := range notes {
					fmt.Printf("[%d] %s\n", i+1, n)
				}
			}
		case "4":
			playNotes(notes)
		case "5":
			fmt.Print("Filename: ")
			scanner.Scan()
			fname := strings.TrimSpace(scanner.Text())
			if fname == "" {
				continue
			}
			file, err := os.Create(fname)
			if err != nil {
				fmt.Println("Error creating file:", err)
				continue
			}
			defer file.Close()
			for _, n := range notes {
				file.WriteString(n + "\n")
			}
			fmt.Printf("Saved to %s\n", fname)
		case "6":
			fmt.Print("Filename: ")
			scanner.Scan()
			fname := strings.TrimSpace(scanner.Text())
			file, err := os.Open(fname)
			if err != nil {
				fmt.Println("File not found.")
				continue
			}
			defer file.Close()
			var loaded []string
			sc := bufio.NewScanner(file)
			for sc.Scan() {
				line := strings.TrimSpace(sc.Text())
				if line != "" {
					loaded = append(loaded, line)
				}
			}
			notes = loaded
			fmt.Printf("Loaded %d notes from %s\n", len(notes), fname)
		case "7":
			fmt.Println("Goodbye!")
			return
		default:
			fmt.Println("Invalid choice.")
		}
	}
}
