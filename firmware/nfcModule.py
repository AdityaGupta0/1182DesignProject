import time
import board
import busio
from adafruit_pn532.i2c import PN532_I2C

# I2C connection setup
i2c = busio.I2C(board.SCL, board.SDA)

# Initialize the PN532 module
pn532 = PN532_I2C(i2c, debug=False)

# Configure the PN532 to read MiFare cards
pn532.SAM_configuration()

print("Waiting for an NFC tag...")

try:
    while True:
        # Check if a card is available to read
        uid = pn532.read_passive_target(timeout=0.5)
        if uid is not None:
            print(f"Found an NFC tag with UID: {uid.hex()}")
        else:
            print("No NFC tag detected.")
        time.sleep(0.5)  # Adjust the delay as needed
except KeyboardInterrupt:
    print("\nExiting...")