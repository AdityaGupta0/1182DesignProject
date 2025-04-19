#python3 -m venv .venv
#source .venv/bin/activate

import time
from hx711 import HX711  
import RPi.GPIO as GPIO  
import board
import busio
import time
from adafruit_pn532.i2c import PN532_I2C
import adafruit_tca9548a
#import statistics
import requests

# --- I2C and Multiplexer Setup ---
try:
    i2c = busio.I2C(board.SCL, board.SDA)
    tca = adafruit_tca9548a.TCA9548A(i2c)
except ValueError as e:
    print(f"Error initializing I2C or TCA9548A: {e}")
    exit()
except Exception as e:
    print(f"An unexpected error occurred during I2C setup: {e}")
    exit()


GPIO.setmode(GPIO.BCM)
# Define GPIO pins for the HX711
LC2 = HX711(dout_pin=19, pd_sck_pin=13)
LC3 = HX711(dout_pin=5, pd_sck_pin=6)
LC4 = HX711(dout_pin=9, pd_sck_pin=10)

print("Resetting HX711...")
LC2.reset()
LC3.reset()
LC4.reset()
time.sleep(0.5)
print("Zeroing scale...")
LC2.zero(30)
LC3.zero(30)
LC4.zero(30)
#EDIT RATIOS LATER !!!!!!!
print("Setting scale ratios...")
LC2.set_scale_ratio(-1060)
LC3.set_scale_ratio(1027)
LC4.set_scale_ratio(1080)
time.sleep(0.1)

# --- Firebase REST API Setup ---
DATABASE_URL = 'https://inventory-tracker-1182-default-rtdb.firebaseio.com'
DB_ITEMS_PATH = '/items'
print(f"Firebase Database URL: {DATABASE_URL}")
# --- End Firebase REST API Setup ---

def extractId(payload):
    payload_str = str(payload)
    xfe_pos = payload_str.find('\\xfe')  # Find the position of '\xfe'

    if xfe_pos >= 13:  # Make sure there are at least 13 characters before '\xfe'
        raw_section = payload_str[xfe_pos-13:xfe_pos]
        digits_only = ''.join(c for c in raw_section if c.isdigit())
        if len(digits_only) == 13:
            return digits_only
    return None


PN532_CHANNELS = [0, 1, 3] 
pn532_modules = {}

print("Initializing PN532 modules via TCA9548A...")
for i in PN532_CHANNELS:
    print(f"Checking channel {i}...")
    try:
        channel_i2c = tca[i]
        time.sleep(0.1) # Short delay before init
        pn532 = PN532_I2C(channel_i2c, debug=False)
        version = pn532.firmware_version
        if version:
            print(f"  Found PN532 on channel {i} with firmware version: {version[0]}.{version[1]}")
            pn532.SAM_configuration()
            pn532_modules[i] = pn532 # Store using channel number as key
        else:
            print(f"  No PN532 detected on channel {i} (firmware check failed).")
    except ValueError:
        # Error often means no device responded at the PN532 address (0x24)
        print(f"  No I2C device found at PN532 address on channel {i}.")
    except Exception as e:
        print(f"  Error initializing PN532 on channel {i}: {e}")

if not pn532_modules:
    print("\nNo PN532 modules successfully initialized. Exiting.")
    GPIO.cleanup()
    exit()

print(f"\nSuccessfully initialized {len(pn532_modules)} PN532 module(s). Starting main loop...")


# --- Main Loop ---
try:
    while True:
        # Iterate through the initialized PN532 modules by channel
        for channel, pn532 in pn532_modules.items():
            uid = None
            try:
                # Check for a tag on the current module's channel
                uid = pn532.read_passive_target(timeout=0.1) # Short timeout
            except OSError as e:
                print(f"Warning: Communication error with PN532 on channel {channel}: {e}")
                # Optional: Add logic to attempt re-initialization if errors persist
                time.sleep(0.5) # Wait a bit before retrying
                continue # Skip to next module for this iteration

            if uid is not None:
                print(f"\nTag found on channel {channel} with UID: {uid.hex()}")

                # --- Read Tag Data ---
                tag_id = None
                try:
                    payload = b""
                    # Read relevant pages (e.g., 4 to 7 for MIFARE Classic)
                    # Adjust page range based on your tag type and data structure
                    for page in range(4, 8):
                        data = pn532.mifare_classic_read_block(page)
                        if data:
                            payload += data
                        else:
                            print(f"  Warning: Failed to read page {page} from tag on channel {channel}.")
                            payload = None # Mark payload as invalid
                            break
                        
                    if payload:
                        # print(f"  Raw Payload: {payload}") # Uncomment for debugging
                        tag_id = extractId(payload)
                        if tag_id:
                            print(f"  Extracted ID: {tag_id}")
                        else:
                            print(f"  Could not extract valid ID from payload: {payload}")
                    else:
                         print("  Payload reading failed.")

                except Exception as e:
                    print(f"  Error reading data from tag on channel {channel}: {e}")

                # --- Measure Weight and Update Firebase ---
                if tag_id and channel in load_cells:
                    lc = load_cells[channel]
                    try:
                        print(f"  Measuring weight from LC on channel {channel}...")
                        # Get multiple readings for stability
                        weight = lc.get_weight_mean(20)
                        if weight is not False:
                            # Round to nearest integer for quantity
                            quantity = int(round(weight))
                            # Ensure quantity is not negative (or handle as needed)
                            quantity = max(0, quantity)
                            print(f"  Measured weight: {weight:.2f}g, Rounded Quantity: {quantity}")

                            # Construct Firebase URL for this specific item ID
                            item_db_path = f"{DB_ITEMS_PATH}/{tag_id}/currQuant.json"
                            firebase_url = f"{DATABASE_URL}{item_db_path}"

                            # Send data to Firebase via REST API
                            try:
                                print(f"  Uploading quantity {quantity} to {firebase_url}")
                                response = requests.put(firebase_url, json=quantity, timeout=5)
                                response.raise_for_status() # Check for HTTP errors
                                print("  Upload successful.")
                            except requests.exceptions.RequestException as e:
                                print(f"  Error sending data to Firebase: {e}")
                            except Exception as e:
                                print(f"  An unexpected error occurred during Firebase upload: {e}")

                        else:
                            print("  Invalid reading from load cell.")
                    except Exception as e:
                        print(f"  Error getting weight from LC on channel {channel}: {e}")
                elif tag_id:
                    print(f"  Warning: No load cell configured for channel {channel} to measure weight.")

                # Optional: Add a small delay after processing a tag to avoid re-reading immediately
                time.sleep(1.0)

            # No need to print "No tag" for every channel every loop, keep output clean

        # Small delay in the main loop to prevent high CPU usage
        time.sleep(0.1)

except KeyboardInterrupt:
    print("\nExiting program...")
except Exception as e:
    print(f"\nAn unexpected error occurred in the main loop: {e}")
finally:
    print("Cleaning up GPIO...")
    GPIO.cleanup()
    print("GPIO cleaned up. Exiting.")