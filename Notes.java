// Notes.java
import java.io.*;
import java.util.*;
import java.lang.Math;

public class Notes {
    private static List<String> notes = new ArrayList<>();
    private static final Map<String, Double> NOTE_FREQS = new HashMap<>();
    static {
        NOTE_FREQS.put("C", 261.63); NOTE_FREQS.put("C#", 277.18); NOTE_FREQS.put("Db", 277.18);
        NOTE_FREQS.put("D", 293.66); NOTE_FREQS.put("D#", 311.13); NOTE_FREQS.put("Eb", 311.13);
        NOTE_FREQS.put("E", 329.63);
        NOTE_FREQS.put("F", 349.23); NOTE_FREQS.put("F#", 369.99); NOTE_FREQS.put("Gb", 369.99);
        NOTE_FREQS.put("G", 392.00); NOTE_FREQS.put("G#", 415.30); NOTE_FREQS.put("Ab", 415.30);
        NOTE_FREQS.put("A", 440.00); NOTE_FREQS.put("A#", 466.16); NOTE_FREQS.put("Bb", 466.16);
        NOTE_FREQS.put("B", 493.88);
    }

    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        System.out.println("=== Notation Editor ===");
        while (true) {
            System.out.println("\n1. Add note");
            System.out.println("2. Remove note");
            System.out.println("3. List notes");
            System.out.println("4. Play melody");
            System.out.println("5. Save to file");
            System.out.println("6. Load from file");
            System.out.println("7. Exit");
            System.out.print("Choose: ");
            String choice = reader.readLine().trim();
            switch (choice) {
                case "1":
                    System.out.print("Enter note (e.g., C4, D#4): ");
                    String note = reader.readLine().trim();
                    if (!note.isEmpty()) {
                        notes.add(note);
                        System.out.println("Added: " + note);
                    } else System.out.println("Invalid note.");
                    break;
                case "2":
                    if (notes.isEmpty()) {
                        System.out.println("No notes to remove.");
                        break;
                    }
                    System.out.print("Index to remove: ");
                    try {
                        int idx = Integer.parseInt(reader.readLine().trim());
                        if (idx >= 1 && idx <= notes.size()) {
                            String removed = notes.remove(idx - 1);
                            System.out.println("Removed: " + removed);
                        } else System.out.println("Invalid index.");
                    } catch (NumberFormatException e) {
                        System.out.println("Invalid number.");
                    }
                    break;
                case "3":
                    if (notes.isEmpty()) System.out.println("No notes.");
                    else {
                        for (int i = 0; i < notes.size(); i++)
                            System.out.println("[" + (i+1) + "] " + notes.get(i));
                    }
                    break;
                case "4":
                    playMelody();
                    break;
                case "5":
                    System.out.print("Filename: ");
                    String fname = reader.readLine().trim();
                    if (!fname.isEmpty()) {
                        try (PrintWriter pw = new PrintWriter(fname)) {
                            for (String n : notes) pw.println(n);
                        }
                        System.out.println("Saved to " + fname);
                    }
                    break;
                case "6":
                    System.out.print("Filename: ");
                    fname = reader.readLine().trim();
                    try (BufferedReader br = new BufferedReader(new FileReader(fname))) {
                        List<String> loaded = new ArrayList<>();
                        String line;
                        while ((line = br.readLine()) != null) {
                            line = line.trim();
                            if (!line.isEmpty()) loaded.add(line);
                        }
                        notes = loaded;
                        System.out.println("Loaded " + notes.size() + " notes from " + fname);
                    } catch (FileNotFoundException e) {
                        System.out.println("File not found.");
                    }
                    break;
                case "7":
                    System.out.println("Goodbye!");
                    return;
                default:
                    System.out.println("Invalid choice.");
            }
        }
    }

    private static void playMelody() {
        if (notes.isEmpty()) {
            System.out.println("No notes to play.");
            return;
        }
        System.out.println("Playing melody...");
        for (String n : notes) {
            double[] freq = parseNote(n);
            if (freq == null) {
                System.out.println("  Skipping unknown note: " + n);
                continue;
            }
            System.out.printf("  %s (%.1f Hz)%n", n, freq[0]);
            // Attempt to beep using Java's Toolkit (not available) – print only.
            // Java doesn't have a simple beep without external libs.
        }
    }

    private static double[] parseNote(String note) {
        note = note.trim();
        if (note.isEmpty()) return null;
        String letter = "";
        int octave = 4;
        int i = 0;
        while (i < note.length() && (Character.isLetter(note.charAt(i)) || note.charAt(i) == '#')) {
            letter += note.charAt(i);
            i++;
        }
        if (i < note.length() && Character.isDigit(note.charAt(i))) {
            octave = Integer.parseInt(note.substring(i));
        }
        if (NOTE_FREQS.containsKey(letter)) {
            double base = NOTE_FREQS.get(letter);
            double freq = base * Math.pow(2, octave - 4);
            return new double[]{freq};
        }
        return null;
    }
}
