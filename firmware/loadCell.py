import time
from hx711 import HX711  # Ensure you have the HX711 library installed
import RPi.GPIO as GPIO  # Ensure you have the RPi.GPIO library installed
import firebase_admin # Import Firebase library
from firebase_admin import credentials, db # Import specific modules

# --- Firebase Setup ---
# Replace with the path to your downloaded service account key JSON file
CRED_PATH = '/home/adi/1182DesignProject/firmware/inventory-tracker-1182-firebase-adminsdk-fbsvc-4b8886cd39.json'
# Replace with your Firebase Realtime Database URL
DATABASE_URL = 'https://inventory-tracker-1182-default-rtdb.firebaseio.com'
# Define the path in your database where you want to store the weight
DB_WEIGHT_PATH = '/items/1744822927569/currQuant'

try:
    cred = credentials.Certificate(CRED_PATH)
    firebase_admin.initialize_app(cred, {
        'databaseURL': DATABASE_URL
    })
    # Get a reference to the database path
    db_ref = db.reference(DB_WEIGHT_PATH)
    print("Firebase Admin SDK initialized successfully.")
except Exception as e:
    print(f"Error initializing Firebase Admin SDK: {e}")
    print("Firebase functionality will be disabled.")
    db_ref = None # Set db_ref to None if initialization fails
# --- End Firebase Setup ---

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

                # --- Send data to Firebase ---
                if db_ref: # Check if Firebase was initialized successfully
                    try:
                        db_ref.set(formatted_weight)
                        # print("Weight sent to Firebase.") # Optional: uncomment for confirmation
                    except Exception as e:
                        print(f"Error sending data to Firebase: {e}")
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