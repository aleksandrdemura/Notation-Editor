# notes.rb
NOTE_FREQS = {
  'C' => 261.63, 'C#' => 277.18, 'Db' => 277.18,
  'D' => 293.66, 'D#' => 311.13, 'Eb' => 311.13,
  'E' => 329.63,
  'F' => 349.23, 'F#' => 369.99, 'Gb' => 369.99,
  'G' => 392.00, 'G#' => 415.30, 'Ab' => 415.30,
  'A' => 440.00, 'A#' => 466.16, 'Bb' => 466.16,
  'B' => 493.88
}

def parse_note(note)
  note = note.strip
  return [nil, nil] if note.empty?
  letter = ''
  octave = 4
  i = 0
  while i < note.length && (note[i].match?(/[A-G#b]/))
    letter << note[i]
    i += 1
  end
  if i < note.length && note[i].match?(/\d/)
    octave = note[i..-1].to_i
  end
  if NOTE_FREQS.key?(letter)
    freq = NOTE_FREQS[letter] * (2 ** (octave - 4))
    return [freq, note]
  end
  [nil, nil]
end

def play_freq(freq)
  return unless freq && freq > 0
  # Try using system beep if available
  if RUBY_PLATFORM =~ /mswin|mingw|windows/
    # Windows: use winsound? Not available in Ruby by default.
    puts "  (would play #{freq.round(1)} Hz on Windows)"
  elsif RUBY_PLATFORM =~ /linux/
    system("beep -f #{freq.round} -l 300 2>/dev/null")
  else
    # macOS or other
    puts "  (would play #{freq.round(1)} Hz)"
  end
end

def play_notes(notes)
  if notes.empty?
    puts "No notes to play."
    return
  end
  puts "Playing melody..."
  notes.each do |n|
    freq, parsed = parse_note(n)
    if freq.nil?
      puts "  Skipping unknown note: #{n}"
      next
    end
    puts "  #{parsed} (#{freq.round(1)} Hz)"
    play_freq(freq)
    sleep 0.3
  end
end

def main
  notes = []
  puts "=== Notation Editor ==="
  loop do
    puts "\n1. Add note"
    puts "2. Remove note"
    puts "3. List notes"
    puts "4. Play melody"
    puts "5. Save to file"
    puts "6. Load from file"
    puts "7. Exit"
    print "Choose: "
    choice = gets.chomp.strip
    case choice
    when '1'
      print "Enter note (e.g., C4, D#4): "
      note = gets.chomp.strip
      unless note.empty?
        notes << note
        puts "Added: #{note}"
      else
        puts "Invalid note."
      end
    when '2'
      if notes.empty?
        puts "No notes to remove."
        next
      end
      print "Index to remove: "
      idx = gets.chomp.to_i
      if idx >= 1 && idx <= notes.size
        removed = notes.delete_at(idx - 1)
        puts "Removed: #{removed}"
      else
        puts "Invalid index."
      end
    when '3'
      if notes.empty?
        puts "No notes."
      else
        notes.each_with_index { |n, i| puts "[#{i+1}] #{n}" }
      end
    when '4'
      play_notes(notes)
    when '5'
      print "Filename: "
      fname = gets.chomp.strip
      unless fname.empty?
        File.open(fname, 'w') { |f| notes.each { |n| f.puts n } }
        puts "Saved to #{fname}"
      end
    when '6'
      print "Filename: "
      fname = gets.chomp.strip
      if File.exist?(fname)
        loaded = File.readlines(fname).map(&:chomp).reject(&:empty?)
        notes = loaded
        puts "Loaded #{notes.size} notes from #{fname}"
      else
        puts "File not found."
      end
    when '7'
      puts "Goodbye!"
      break
    else
      puts "Invalid choice."
    end
  end
end

main if __FILE__ == $0
