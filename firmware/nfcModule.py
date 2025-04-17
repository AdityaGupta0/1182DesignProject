import board
import busio
import time
from adafruit_pn532.i2c import PN532_I2C
import adafruit_tca9548a

# --- Define your extractId function here ---
def extractId(payload):
    payload_str = str(payload)
    xfe_pos = payload_str.find('\\xfe')  # Find the position of '\xfe'

    if xfe_pos >= 13:  # Make sure there are at least 13 characters before '\xfe'
        raw_section = payload_str[xfe_pos-13:xfe_pos]
        digits_only = ''.join(c for c in raw_section if c.isdigit())
        if len(digits_only) == 13:
            return digits_only
    return None
# --- End of extractId function ---

# Create I2C bus as normal
i2c = busio.I2C(board.SCL, board.SDA)

# Create the TCA9548A object and give it the I2C bus
# Default address is 0x70, change if you configured yours differently
try:
    tca = adafruit_tca9548a.TCA9548A(i2c)
except ValueError as e:
    print(f"Error initializing TCA9548A: {e}")
    print("Check wiring and ensure multiplexer is detected at address 0x70.")
    exit()


# List to hold the PN532 objects for each channel
pn532_modules = []
num_modules = 8 # TCA9548A has 8 channels (0-7)

print("Initializing PN532 modules via TCA9548A...")

for i in range(num_modules):
    print(f"Checking channel {i}...")
    try:
        # Select the channel on the multiplexer.
        # tca[i] returns an I2C bus object for that specific channel.
        channel_i2c = tca[i]

        # Attempt to initialize PN532 on this channel's I2C bus
        # Add a short delay and potentially retry logic if needed
        time.sleep(0.1)
        pn532 = PN532_I2C(channel_i2c, debug=False)

        # Try to communicate (e.g., get firmware version)
        version = pn532.firmware_version
        if version:
            print(f"  Found PN532 on channel {i} with firmware version: {version[0]}.{version[1]}")
            pn532.SAM_configuration() # Configure the found module
            pn532_modules.append({"channel": i, "instance": pn532})
        else:
            # This case might not be reached if PN532_I2C throws an error on init
            print(f"  No PN532 detected on channel {i} (firmware check failed).")

    except ValueError as e:
        # This error often occurs if no device responds at the PN532 address (0x24) on the selected channel
        print(f"  No I2C device found on channel {i}. Error: {e}")
    except Exception as e:
        # Catch other potential errors during initialization
        print(f"  Error initializing PN532 on channel {i}: {e}")

if not pn532_modules:
    print("\nNo PN532 modules found on any channel. Exiting.")
    exit()

print(f"\nFound {len(pn532_modules)} PN532 module(s). Waiting for tags...")

try:
    while True:
        # Loop through each detected PN532 module
        for module_info in pn532_modules:
            channel = module_info["channel"]
            pn532 = module_info["instance"]

            # The library handles selecting the channel implicitly when using the
            # 'pn532' instance associated with tca[channel]
            # print(f"Checking module on channel {channel}...") # Optional: for debugging

            uid = None
            try:
                # Check if a card is available to read on this specific module
                uid = pn532.read_passive_target(timeout=0.1) # Use a short timeout
            except OSError as e:
                # Sometimes communication errors can occur, especially with multiple devices
                print(f"Error communicating with module on channel {channel}: {e}")
                # Optional: try re-initializing or skipping this module for a cycle
                continue # Skip to the next module

            if uid is not None:
                print(f"\nFound tag on channel {channel} with UID: {uid.hex()}")

                # Attempt to read data from this tag
                try:
                    payload = b""
                    # Adjust page range if needed for your specific tag type/data
                    for page in range(4, 8):
                        data = pn532.mifare_classic_read_block(page)
                        if data:
                            payload += data
                        else:
                            print(f"  Failed to read data from page {page} on channel {channel}.")
                            payload = None # Indicate failure
                            break

                    if payload:
                        id_number = extractId(payload)
                        if id_number:
                            print(f"  Extracted ID: {id_number}")
                        else:
                            print("  Could not extract ID number")
                            print(f"  Raw data: {payload}")
                except Exception as e:
                    # Catch errors specific to reading the tag data
                    print(f"  Error reading data from tag on channel {channel}: {e}")

            # No need to print "No tag detected" for every module every time,
            # it makes the output noisy. Only print when a tag IS found.

        # Add a small delay to prevent high CPU usage
        time.sleep(0.1)

except KeyboardInterrupt:
    print("\nExiting...")
# No finally block needed here as GPIO cleanup isn't used directly
