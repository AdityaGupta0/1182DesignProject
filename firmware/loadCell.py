import time
from hx711 import HX711  # Ensure you have the HX711 library installed
import RPi.GPIO as GPIO  # Ensure you have the RPi.GPIO library installed
#import firebase_admin # Import Firebase library
#from firebase_admin import credentials, db # Import specific modules
import requests

# --- Firebase REST API Setup ---
# Replace with your Firebase Realtime Database URL
DATABASE_URL = 'https://inventory-tracker-1182-default-rtdb.firebaseio.com'
# Define the path in your database where you want to store the weight, MUST end with .json for REST API
DB_WEIGHT_PATH = '/items/1744822927569/currQuant.json'
# Construct the full REST API endpoint URL
FIREBASE_REST_URL = f"{DATABASE_URL}{DB_WEIGHT_PATH}"
print(f"Firebase REST endpoint: {FIREBASE_REST_URL}")
# --- End Firebase REST API Setup ---

# Define GPIO pins for the HX711
DT = 19  # Data pin (DT)
SCK = 13  # Clock pin (SCK)

def main():
    hx = None # Initialize hx to None
    try:
        GPIO.setmode(GPIO.BCM)
        hx = HX711(dout_pin=DT, pd_sck_pin=SCK)
        print("Resetting HX711...")
        hx.reset()
        time.sleep(0.5)
        print("Zeroing scale...")
        # Check if zeroing was successful
        if not hx.zero(30):
             print("Warning: Tare/Zeroing failed.")
        else:
             print("Scale zeroed successfully.")

        # --- Set Scale Ratio ---
        # !! IMPORTANT !! Replace -1060 with the ratio you determined
        # using your calibration script (loadCellZeroScript.py)
        calibration_ratio = -1060 # <<<--- REPLACE THIS VALUE
        if calibration_ratio == -1060: # Add a check for the default value
             print("WARNING: Using default calibration ratio. Please calibrate!")
        hx.set_scale_ratio(calibration_ratio)
        print(f"Scale ratio set to: {calibration_ratio}")
        # --- End Scale Ratio ---

    except ImportError:
        print("HX711 or RPi.GPIO library not found.")
        return
    except Exception as e:
        print(f"Error initializing HX711: {e}")
        GPIO.cleanup() # Cleanup GPIO if init fails
        return
    print("Reading data from HX711. Press Ctrl+C to stop.")
    
    try:
        while True:
            weight = hx.get_weight_mean(20)
            if weight is not False:
                # Format weight to 2 decimal places
                formatted_weight = round(weight, 2)
                print(f"Weight: {formatted_weight} grams")

                # --- Send data to Firebase via REST API ---
                try:
                    # Use requests.put to overwrite data at the specified URL
                    # The data needs to be JSON encoded
                    response = requests.put(FIREBASE_REST_URL, json=formatted_weight, timeout=5) # Added timeout
                    response.raise_for_status() # Raise an exception for bad status codes (4xx or 5xx)
                    # print("Weight sent to Firebase.") # Optional: uncomment for confirmation
                except requests.exceptions.RequestException as e:
                    print(f"Error sending data to Firebase via REST: {e}")
                # --- End Send data to Firebase ---


            else:
                print("Invalid reading from HX711.")

            time.sleep(1) # Increased sleep time slightly

    except KeyboardInterrupt:
        print("\nExiting...")
    except Exception as e:
        print(f"An error occurred during reading loop: {e}")
    finally:
        if hx:
            hx.power_down()
        GPIO.cleanup()
        print("GPIO cleaned up.")

if __name__ == "__main__":
    main()