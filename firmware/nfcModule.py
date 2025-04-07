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


# Configure to read MiFare cards
pn532.SAM_configuration()

print("Waiting for an NFC tag...")

def extractId(payload):
    payload_str = str(payload)
    xfe_pos = payload_str.find('\\xfe')  # Find the position of '\xfe'


    if xfe_pos >= 13:  # Make sure there are at least 13 characters before '\xfe'
        # Extract characters before '\xfe'
        raw_section = payload_str[xfe_pos-13:xfe_pos]
        
        # Filter only digits from this section
        digits_only = ''.join(c for c in raw_section if c.isdigit())
        
        # If we have exactly 13 digits, return them
        if len(digits_only) == 13:
            return digits_only
    
    return None

try:
    while True:
        # Check if a card is available to read
        uid = pn532.read_passive_target(timeout=0.5)
        if uid is not None:
            print(f"Found an NFC tag with UID: {uid.hex()}")

            # Attempt to read 16 bytes of data (4 pages, 4 bytes each)
            try:
                payload = b""  # Initialize an empty byte string to store the payload
                for page in range(4, 8):  # reads 20 bytes of data (4 pages, 4 bytes each)
                    data = pn532.mifare_classic_read_block(page)
                    if data:
                        payload += data  # Append the 4 bytes from the page to the payload
                    else:
                        print(f"Failed to read data from page {page}.")
                        break

                # Decode the payload as UTF-8
                if payload:
                    id_number = extractId(payload)
                    if id_number:
                        print(id_number)
                    else:
                        print("Could not extract ID number")
                        print(f"Raw data: {payload}")
            except Exception as e:
                print(f"Error reading data: {e}")
        else:
            print("No NFC tag detected.")
except KeyboardInterrupt:
    print("\nExiting...")