import time
from hx711 import HX711  # Ensure you have the HX711 library installed
import RPi.GPIO as GPIO  # Ensure you have the RPi.GPIO library installed

# Define GPIO pins for the HX711
DT = 5  # Data pin (DT)
SCK = 6  # Clock pin (SCK)



def main():
    """
    Continuously read data from the HX711 and print it to the terminal.
    """
    try:
        # Initialize GPIO pins
        GPIO.setmode(GPIO.BCM)  # Use BCM pin numbering
        # GPIO.setup(DT, GPIO.IN)  # Set DT pin as input
        # GPIO.setup(SCK, GPIO.OUT)  # Set SCK pin as output

        # Initialize the HX711 object
        hx = HX711(
            dout_pin=DT,
            pd_sck_pin=SCK,
        )
        hx.zero()  # Zero the scale
    except ImportError:
        print("HX711 library not found. Please install it using 'pip install hx711'")
        return
    except Exception as e:
        print(f"Error initializing HX711: {e}")
        return

    print("Reading data from HX711. Press Ctrl+C to stop.")
    
    try:
        while True:
            weight = hx.get_data_mean() 
            print(f"Weight: {weight} grams")
            time.sleep(0.1)  # Adjust the delay as needed
    except KeyboardInterrupt:
        print("\nExiting...")
    finally:
        hx.power_down()
        GPIO.cleanup()  # Clean up GPIO settings if using RPi.GPIO

if __name__ == "__main__":
    main()