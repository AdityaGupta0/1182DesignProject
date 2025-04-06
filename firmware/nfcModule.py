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

            # Attempt to read 16 bytes of data (4 pages, 4 bytes each)
            try:
                payload = b""  # Initialize an empty byte string to store the payload
                for page in range(4, 8):  # Read pages 4 to 7 (16 bytes total)
                    data = pn532.mifare_classic_read_block(page)
                    if data:
                        payload += data  # Append the 4 bytes from the page to the payload
                    else:
                        print(f"Failed to read data from page {page}.")
                        break

                # Parse the NDEF message
                if payload:
                    try:
                        # NDEF parsing
                        if payload[0] == 0x03:  # NDEF message starts with 0x03
                            ndef_length = payload[1]  # Length of the NDEF message
                            ndef_message = payload[2:2 + ndef_length]  # Extract the NDEF message
                            if ndef_message[0] == 0xD1:  # Check for a well-known text record
                                language_code_length = ndef_message[4] & 0x3F  # Length of the language code
                                text_start = 5 + language_code_length  # Start of the actual text
                                text_length = ndef_message[3] - language_code_length  # Length of the text
                                text = ndef_message[text_start:text_start + text_length].decode('utf-8')  # Extract and decode the text
                                print(f"Payload: {text}")
                            else:
                                print(f"Unsupported NDEF message format. Raw data: {payload}")
                        else:
                            print(f"Invalid NDEF message. Raw data: {payload}")
                    except Exception as e:
                        print(f"Error parsing NDEF message: {e}")
            except Exception as e:
                print(f"Error reading data: {e}")
        else:
            print("No NFC tag detected.")
except KeyboardInterrupt:
    print("\nExiting...")