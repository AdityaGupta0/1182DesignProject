import time
from hx711 import HX711  # Ensure you have the HX711 library installed

# Define GPIO pins for the HX711
DT = 5  # Data pin (DT)
SCK = 6  # Clock pin (SCK)

def setup_hx711():
    """
    Initialize the HX711 module.
    """
    hx = HX711(dout_pin=DT, pd_sck_pin=SCK)
    hx.set_reading_format("MSB", "MSB")  # Set the byte order
    hx.set_reference_unit(1)  # Set the reference unit (calibrate as needed)
    hx.reset()
    hx.tare()  # Tare the scale to zero
    return hx

def main():
    """
    Continuously read data from the HX711 and print it to the terminal.
    """
    hx = setup_hx711()
    print("Reading data from HX711. Press Ctrl+C to stop.")
    
    try:
        while True:
            # Read the weight value
            weight = hx.get_weight(5)  # Average over 5 readings
            print(f"Weight: {weight:.2f} grams")
            hx.power_down()
            hx.power_up()
            time.sleep(0.1)  # Adjust the delay as needed
    except KeyboardInterrupt:
        print("\nExiting...")
    finally:
        hx.power_down()

if __name__ == "__main__":
    main()