import mido

# Load MIDI file
mid = mido.MidiFile('1.mid')

# List to store note values
note_values = []

# Iterate through each track in the MIDI file
for i, track in enumerate(mid.tracks):
    print(f'Track {i}: {track.name}')
    
    # Iterate through each message in the track
    for msg in track:
        if msg.type == 'note_on' and msg.velocity > 0:
            note_number = msg.note
            note_values.append(f"{note_number:02X}")

# Print all note values
print("Note values (0-127):")
print('\n'.join(note_values))
