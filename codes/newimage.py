from PIL import Image

def rgb565(r, g, b):
    r_16bit = (r >> 3) & 0x1F
    g_16bit = (g >> 2) & 0x3F
    b_16bit = (b >> 3) & 0x1F
    return (r_16bit << 11) | (g_16bit << 5) | b_16bit

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
