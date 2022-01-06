from PIL import Image

dots = Image.new('RGBA', (1920, 15))
dot = Image.open('dot.png')
print(dot)
x = 0
while x < 1920:
    dots.paste(dot, (x, 0), dot)
    x += 20
dots.save('dots.png')
