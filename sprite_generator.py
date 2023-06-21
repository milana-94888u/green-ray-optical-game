from PIL import Image


size = 128
white_img = Image.new("RGB", (size, size), (255, 255, 255))
white_img.save("white_tile.png")
red_img = Image.new("RGB", (size, size), (255, 0, 0))
red_img.save("red_tile.png")
