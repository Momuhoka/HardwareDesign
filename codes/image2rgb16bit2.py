from PIL import Image

def convert_to_16bit_rgb(pixel):
    r, g, b = pixel
    r_16bit = (r >> 3) & 0x1F
    g_16bit = (g >> 2) & 0x3F
    b_16bit = (b >> 3) & 0x1F
    return (r_16bit << 11) | (g_16bit << 5) | b_16bit

def image_to_16bit_rgb_txt(image_path, output_txt_path):
    # 打开图像
    image = Image.open(image_path)
    image = image.convert('RGB')

    # 获取图像尺寸
    width, height = image.size

    with open(output_txt_path, 'w') as f:
        # 遍历每个像素点
        for y in range(height):
            for x in range(width):
                pixel = image.getpixel((x, y))
                rgb_16bit = convert_to_16bit_rgb(pixel)
                # 将16bit的RGB值格式化为4位十六进制字符串
                hex_value = f"{rgb_16bit:04X}"
                f.write(hex_value)

# 示例用法
image_path = '1.png'  # 输入图像路径
output_txt_path = 'newoutput.txt'  # 输出txt文件路径
image_to_16bit_rgb_txt(image_path, output_txt_path)
