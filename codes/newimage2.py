from PIL import Image

def rgb565(r, g, b):
    r_16bit = (r >> 3) & 0x1F
    g_16bit = (g >> 2) & 0x3F
    b_16bit = (b >> 3) & 0x1F
    return (r_16bit << 11) | (g_16bit << 5) | b_16bit

def is_in_music_note_shape(x, y):
    # 定义音乐符号的形状
    # 这里我们绘制一个简单的八分音符
    
    # 音符的杆
    if 60 <= x <= 62 and 30 <= y <= 90:
        return True
    
    # 音符的头部（圆形）
    if (x - 55) ** 2 + (y - 90) ** 2 <= 15 ** 2:
        return True
    
    return False

def generate_image(width, height):
    image = Image.new('RGB', (width, height))
    pixels = image.load()

    for i in range(width * height):
        x = i % width
        y = i // width

        # 计算从蓝色到青色的渐变
        r = 0
        g = int(255 * (x / width))
        b = 255

        # 检查像素是否在音乐符号形状内
        if is_in_music_note_shape(x, y):
            r, g, b = 0, 0, 0  # 音符使用黑色

        rgb_16bit = rgb565(r, g, b)
        pixels[x, y] = (r, g, b)

    return image

# 屏幕尺寸
width = 160
height = 128

# 生成图像
image = generate_image(width, height)

# 保存图像
image.save('output.png')

# 显示图像
image.show()
