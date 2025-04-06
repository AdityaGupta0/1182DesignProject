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


# Configure the PN532 to read MiFare cards
pn532.SAM_configuration()

print("Waiting for an NFC tag...")

try:
    while True:
        # Check if a card is available to read
        uid = pn532.read_passive_target(timeout=0.5)
        if uid is not None:
            print(f"Found an NFC tag with UID: {uid.hex()}")

            # Attempt to read data from the tag
            try:
                # Read 4-byte pages starting from page 4 (user data typically starts here)
                for page in range(4, 8):  # Adjust the range as needed
                    data = pn532.ntag2xx_read_page(page)
                    if data:
                        print(f"Data on page {page}: {data.decode('utf-8').strip()}")
                    else:
                        print(f"Failed to read data from page {page}.")
            except Exception as e:
                print(f"Error reading data: {e}")
        else:
            print("No NFC tag detected.")
except KeyboardInterrupt:
    print("\nExiting...")