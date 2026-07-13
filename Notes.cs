// Notes.cs
using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;

class Notes
{
    private static List<string> notes = new List<string>();
    private static readonly Dictionary<string, double> NoteFreqs = new Dictionary<string, double>
    {
        {"C", 261.63}, {"C#", 277.18}, {"Db", 277.18},
        {"D", 293.66}, {"D#", 311.13}, {"Eb", 311.13},
        {"E", 329.63},
        {"F", 349.23}, {"F#", 369.99}, {"Gb", 369.99},
        {"G", 392.00}, {"G#", 415.30}, {"Ab", 415.30},
        {"A", 440.00}, {"A#", 466.16}, {"Bb", 466.16},
        {"B", 493.88}
    };

    [DllImport("kernel32.dll")]
    private static extern bool Beep(int freq, int duration);

    static void Main()
    {
        Console.WriteLine("=== Notation Editor ===");
        while (true)
        {
            Console.WriteLine("\n1. Add note");
            Console.WriteLine("2. Remove note");
            Console.WriteLine("3. List notes");
            Console.WriteLine("4. Play melody");
            Console.WriteLine("5. Save to file");
            Console.WriteLine("6. Load from file");
            Console.WriteLine("7. Exit");
            Console.Write("Choose: ");
            string choice = Console.ReadLine()?.Trim();
            switch (choice)
            {
                case "1":
                    Console.Write("Enter note (e.g., C4, D#4): ");
                    string note = Console.ReadLine()?.Trim();
                    if (!string.IsNullOrEmpty(note))
                    {
                        notes.Add(note);
                        Console.WriteLine($"Added: {note}");
                    }
                    else Console.WriteLine("Invalid note.");
                    break;
                case "2":
                    if (notes.Count == 0)
                    {
                        Console.WriteLine("No notes to remove.");
                        break;
                    }
                    Console.Write("Index to remove: ");
                    if (int.TryParse(Console.ReadLine(), out int idx) && idx >= 1 && idx <= notes.Count)
                    {
                        string removed = notes[idx - 1];
                        notes.RemoveAt(idx - 1);
                        Console.WriteLine($"Removed: {removed}");
                    }
                    else Console.WriteLine("Invalid index.");
                    break;
                case "3":
                    if (notes.Count == 0)
                        Console.WriteLine("No notes.");
                    else
                        for (int i = 0; i < notes.Count; i++)
                            Console.WriteLine($"[{i+1}] {notes[i]}");
                    break;
                case "4":
                    PlayMelody();
                    break;
                case "5":
                    Console.Write("Filename: ");
                    string fname = Console.ReadLine()?.Trim();
                    if (!string.IsNullOrEmpty(fname))
                    {
                        File.WriteAllLines(fname, notes);
                        Console.WriteLine($"Saved to {fname}");
                    }
                    break;
                case "6":
                    Console.Write("Filename: ");
                    fname = Console.ReadLine()?.Trim();
                    if (File.Exists(fname))
                    {
                        notes = new List<string>(File.ReadAllLines(fname));
                        Console.WriteLine($"Loaded {notes.Count} notes from {fname}");
                    }
                    else Console.WriteLine("File not found.");
                    break;
                case "7":
                    Console.WriteLine("Goodbye!");
                    return;
                default:
                    Console.WriteLine("Invalid choice.");
                    break;
            }
        }
    }

    static void PlayMelody()
    {
        if (notes.Count == 0)
        {
            Console.WriteLine("No notes to play.");
            return;
        }
        Console.WriteLine("Playing melody...");
        foreach (string n in notes)
        {
            var (freq, parsed) = ParseNote(n);
            if (freq == null)
            {
                Console.WriteLine($"  Skipping unknown note: {n}");
                continue;
            }
            Console.WriteLine($"  {parsed} ({freq.Value:F1} Hz)");
            // Try to beep
            try
            {
                if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
                {
                    Beep((int)freq.Value, 300);
                }
                else
                {
                    Console.WriteLine("  (sound not supported on this OS)");
                }
            }
            catch { }
        }
    }

    static (double? freq, string parsed) ParseNote(string note)
    {
        note = note.Trim();
        if (string.IsNullOrEmpty(note)) return (null, null);
        string letter = "";
        int octave = 4;
        int i = 0;
        while (i < note.Length && char.IsLetter(note[i]) || note[i] == '#')
        {
            letter += note[i];
            i++;
        }
        if (i < note.Length && char.IsDigit(note[i]))
        {
            octave = int.Parse(note.Substring(i));
        }
        if (NoteFreqs.TryGetValue(letter, out double baseFreq))
        {
            double freq = baseFreq * Math.Pow(2, octave - 4);
            return (freq, note);
        }
        return (null, null);
    }
}
