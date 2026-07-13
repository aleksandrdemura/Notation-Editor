// notes.js
const fs = require('fs');
const readline = require('readline');
const { exec } = require('child_process');
const os = require('os');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

const noteFreqs = {
    'C': 261.63, 'C#': 277.18, 'Db': 277.18,
    'D': 293.66, 'D#': 311.13, 'Eb': 311.13,
    'E': 329.63,
    'F': 349.23, 'F#': 369.99, 'Gb': 369.99,
    'G': 392.00, 'G#': 415.30, 'Ab': 415.30,
    'A': 440.00, 'A#': 466.16, 'Bb': 466.16,
    'B': 493.88
};

function parseNote(note) {
    note = note.trim();
    if (!note) return [null, null];
    let letter = '';
    let octave = 4;
    let i = 0;
    while (i < note.length && /[A-G#b]/.test(note[i])) {
        letter += note[i];
        i++;
    }
    if (i < note.length && /\d/.test(note[i])) {
        octave = parseInt(note.substring(i));
    }
    if (noteFreqs[letter]) {
        const freq = noteFreqs[letter] * Math.pow(2, octave - 4);
        return [freq, note];
    }
    return [null, null];
}

function playFreq(freq) {
    if (!freq || freq <= 0) return;
    const platform = os.platform();
    if (platform === 'win32') {
        // Use Windows beep (requires external tool or we just print)
        console.log(`  (would play ${freq.toFixed(1)} Hz on Windows)`);
    } else if (platform === 'linux') {
        // Try 'beep' command
        exec(`beep -f ${Math.round(freq)} -l 300`, (err) => {
            if (err) console.log(`  (beep failed: ${err.message})`);
        });
    } else {
        // macOS: no built-in beep
        console.log(`  (would play ${freq.toFixed(1)} Hz)`);
    }
}

function playNotes(notes) {
    if (notes.length === 0) {
        console.log('No notes to play.');
        return;
    }
    console.log('Playing melody...');
    notes.forEach((n, idx) => {
        const note = n.trim();
        if (!note) return;
        const [freq, parsed] = parseNote(note);
        if (!freq) {
            console.log(`  Skipping unknown note: ${note}`);
            return;
        }
        console.log(`  ${parsed} (${freq.toFixed(1)} Hz)`);
        playFreq(freq);
        // simple delay - we can't easily block in Node, so we'll just print.
        // For real delay we'd need async/await with setTimeout, but we keep it simple.
    });
}

function ask(question) {
    return new Promise(resolve => rl.question(question, resolve));
}

async function main() {
    let notes = [];
    console.log('=== Notation Editor ===');
    while (true) {
        console.log('\n1. Add note');
        console.log('2. Remove note');
        console.log('3. List notes');
        console.log('4. Play melody');
        console.log('5. Save to file');
        console.log('6. Load from file');
        console.log('7. Exit');
        const choice = await ask('Choose: ');
        switch (choice.trim()) {
            case '1': {
                const note = await ask('Enter note (e.g., C4, D#4): ');
                if (note.trim()) {
                    notes.push(note.trim());
                    console.log(`Added: ${note.trim()}`);
                } else {
                    console.log('Invalid note.');
                }
                break;
            }
            case '2': {
                if (notes.length === 0) {
                    console.log('No notes to remove.');
                    break;
                }
                const idxStr = await ask('Index to remove: ');
                const idx = parseInt(idxStr);
                if (isNaN(idx) || idx < 1 || idx > notes.length) {
                    console.log('Invalid index.');
                    break;
                }
                const removed = notes.splice(idx - 1, 1)[0];
                console.log(`Removed: ${removed}`);
                break;
            }
            case '3': {
                if (notes.length === 0) {
                    console.log('No notes.');
                } else {
                    notes.forEach((n, i) => console.log(`[${i+1}] ${n}`));
                }
                break;
            }
            case '4':
                playNotes(notes);
                break;
            case '5': {
                const fname = await ask('Filename: ');
                if (!fname.trim()) break;
                fs.writeFileSync(fname.trim(), notes.join('\n'));
                console.log(`Saved to ${fname.trim()}`);
                break;
            }
            case '6': {
                const fname = await ask('Filename: ');
                if (!fname.trim()) break;
                try {
                    const data = fs.readFileSync(fname.trim(), 'utf8');
                    const loaded = data.split('\n').map(l => l.trim()).filter(l => l);
                    notes = loaded;
                    console.log(`Loaded ${loaded.length} notes from ${fname.trim()}`);
                } catch (e) {
                    console.log('File not found.');
                }
                break;
            }
            case '7':
                console.log('Goodbye!');
                rl.close();
                return;
            default:
                console.log('Invalid choice.');
        }
    }
}

main().catch(console.error);
