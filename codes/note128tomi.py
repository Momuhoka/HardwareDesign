FREQ = 100_000_000

def note_to_dict(note_file):
	result = {}
	with open(note_file, 'r', encoding='utf-8') as notef:
		notes = notef.readlines()
		for note in notes:
			text = note.split(' ')
			result.update({text[1]:round(FREQ/1000/float(text[3])/2)})
	return result

note_file = 'notes.txt'
notes = note_to_dict(note_file)

values = ''
for index, value in enumerate(notes.values()):
	values = values + f"{index}:'{value:04X}',\n"
	
#head = f"#File_format=Hex\n#Address_depth={len(notes)}\n#Data_width=16\n"
#result = head + values
#print(result)
print(values)

