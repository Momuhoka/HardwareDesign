midi_dict = {
	0:'17E4',
	1:'168C',
	2:'1548',
	3:'1417',
	4:'12F6',
	5:'11E6',
	6:'10E4',
	7:'0FF2',
	8:'0F0D',
	9:'0E34',
	10:'0D68',
	11:'0CA8',
	12:'0BF2',
	13:'0B46',
	14:'0AA4',
	15:'0A0B',
	16:'097B',
	17:'08F3',
	18:'0872',
	19:'07F9',
	20:'0786',
	21:'071A',
	22:'06B4',
	23:'0654',
	24:'05F9',
	25:'05A3',
	26:'0552',
	27:'0506',
	28:'04BD',
	29:'0479',
	30:'0439',
	31:'03FC',
	32:'03C3',
	33:'038D',
	34:'035A',
	35:'032A',
	36:'02FC',
	37:'02D2',
	38:'02A9',
	39:'0283',
	40:'025F',
	41:'023D',
	42:'021D',
	43:'01FE',
	44:'01E2',
	45:'01C7',
	46:'01AD',
	47:'0195',
	48:'017E',
	49:'0169',
	50:'0155',
	51:'0141',
	52:'012F',
	53:'011E',
	54:'010E',
	55:'00FF',
	56:'00F1',
	57:'00E3',
	58:'00D7',
	59:'00CA',
	60:'00BF',
	61:'00B4',
	62:'00AA',
	63:'00A1',
	64:'0098',
	65:'008F',
	66:'0087',
	67:'0080',
	68:'0078',
	69:'0072',
	70:'006B',
	71:'0065',
	72:'0060',
	73:'005A',
	74:'0055',
	75:'0050',
	76:'004C',
	77:'0048',
	78:'0044',
	79:'0040',
	80:'003C',
	81:'0039',
	82:'0036',
	83:'0033',
	84:'0030',
	85:'002D',
	86:'002B',
	87:'0028',
	88:'0026',
	89:'0024',
	90:'0022',
	91:'0020',
	92:'001E',
	93:'001C',
	94:'001B',
	95:'0019',
	96:'0018',
	97:'0017',
	98:'0015',
	99:'0014',
	100:'0013',
	101:'0012',
	102:'0011',
	103:'0010',
	104:'000F',
	105:'000E',
	106:'000D',
	107:'000D',
	108:'000C',
	109:'000B',
	110:'000B',
	111:'000A',
	112:'0009',
	113:'0009',
	114:'0008',
	115:'0008',
	116:'0008',
	117:'0007',
	118:'0007',
	119:'0006',
	120:'0006',
	121:'0006',
	122:'0005',
	123:'0005',
	124:'0005',
	125:'0004',
	126:'0004',
	127:'0004'
}

with open('1.txt', 'r') as f:
    values = f.readlines()

result = f"#File_format=Hex\n#Address_depth=4096\n#Data_width=16\n"
for value in values:
    try:
        temp = int(value, 16)
        result = result+midi_dict[temp]+'\n'
    except:
        pass
        
with open('2.txt', 'w') as f:
    f.write(result)
