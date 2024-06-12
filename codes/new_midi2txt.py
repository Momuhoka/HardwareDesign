import os

with open("1.mid", "rb") as f:
    bytes = f.read()

for b in bytes:
    print(format(b, '02X'), end='\n')

with open("midi2txt_out.txt", "w") as f:
    f.write('#File_format=Hex\n')
    f.write('#Address_depth=4096\n')
    f.write('#Data_width=8\n')
    for b in bytes:
        f.write(format(b, '02X') + '\n')
    f.write('FF\n')
