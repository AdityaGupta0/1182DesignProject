#python3 -m venv .venv
#source .venv/bin/activate

import time
from hx711 import HX711  
import RPi.GPIO as GPIO  
import firebase_admin 
from firebase_admin import credentials, db
import board
import busio
import time
from adafruit_pn532.i2c import PN532_I2C
import adafruit_tca9548a
import statistics

i2c = busio.I2C(board.SCL, board.SDA)
tca = adafruit_tca9548a.TCA9548A(i2c)


GPIO.setmode(GPIO.BCM)
# Define GPIO pins for the HX711
LC1 = HX711(dout_pin=20, pd_sck_pin=21)
LC2 = HX711(dout_pin=19, pd_sck_pin=13)
LC3 = HX711(dout_pin=5, pd_sck_pin=6)
LC4 = HX711(dout_pin=9, pd_sck_pin=10)

print("Resetting HX711...")
LC1.reset()
LC2.reset()
LC3.reset()
LC4.reset()
time.sleep(0.5)
print("Zeroing scale...")
LC1.zero(30)
LC2.zero(30)
LC3.zero(30)
LC4.zero(30)
#EDIT RATIOS LATER !!!!!!!
LC1.set_scale_ratio(-1060)
LC2.set_scale_ratio(-1060)
LC3.set_scale_ratio(-1060)
LC4.set_scale_ratio(-1060)

# --- Firebase REST API Setup ---
DATABASE_URL = 'https://inventory-tracker-1182-default-rtdb.firebaseio.com'
DB_WEIGHT_PATH = '/items/1744822927569/currQuant.json'
FIREBASE_REST_URL = f"{DATABASE_URL}{DB_WEIGHT_PATH}"
print(f"Firebase REST endpoint: {FIREBASE_REST_URL}")
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


pn532_modules = []
num_modules = 4
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
    except Exception as e:
        print(f"Error initializing PN532 on channel {i}: {e}")
print(f"\nFound {len(pn532_modules)} PN532 module(s). Waiting for tags...")

while True: