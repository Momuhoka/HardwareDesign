import mido

# MIDI 音符到文本表示的映射
note_to_text = {
    # 低音域
    48: '1',  # C3
    50: '2',  # D3
    52: '3',  # E3
    53: '4',  # F3
    55: '5',  # G3
    57: '6',  # A3
    59: '7',  # B3
    # 中音域
    60: '1',  # C4
    62: '2',  # D4
    64: '3',  # E4
    65: '4',  # F4
    67: '5',  # G4
    69: '6',  # A4 440Hz标准音
    71: '7',  # B4
    # 高音域
    72: '1',  # C5
    74: '2',  # D5
    76: '3',  # E5
    77: '4',  # F5
    79: '5',  # G5
    81: '6',  # A5
    83: '7',  # B5
    84: '1',  # C6

}

def midi_to_text(midi_file):
    mid = mido.MidiFile(midi_file)
    result = []
    
    min = 999
    max = 0
    for msg in mid:
        if msg.type == 'note_on' and msg.velocity > 0:
            note = msg.note
            if note > max:
                max = note
            if note < min:
                min = note
            result.append(str(note))
#            if note in note_to_text:
#                result.append(note_to_text[note])
#            else:
#                result.append('0')  # 未定义的音符作为 0

    return ','.join(result)
#    return f"min:{min}, max{max}"

# 示例使用
midi_file = '1.mid'  # 替换为你的 MIDI 文件路径
text_representation = midi_to_text(midi_file)
print(text_representation)
print(f"Length:{len(text_representation.split(','))}")
