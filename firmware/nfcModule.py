import board
import busio
from adafruit_pn532.i2c import PN532_I2C

i2c = busio.I2C(board.SCL, board.SDA)
pn532 = PN532_I2C(i2c, debug=False)

version = pn532.firmware_version
if version:
    print(f"Found PN532 with firmware version: {version[0]}.{version[1]}")
else:
    print("Failed to detect PN532. Check wiring and connections.")