import time
#import board
#import busio
from pn532pi import Pn532I2c, Pn532

i2c = Pn532I2c(1)
nfc = Pn532(i2c)

if not nfc.begin():
    print("Failed to initialize PN532 module. Check wiring and connections.")
    exit()


version = nfc.getFirmwareVersion()
if not version:
    print("Failed to detect PN532. Check wiring and connections.")
    exit()
print(f"Found PN532 with firmware version: {hex(version)}")


nfc.SAMConfig()  # Configure the PN532 for NFC tag reading

print("Waiting for an NFC tag...")

try:
    while True:
        # Check if a card is available to read
        success, uid = nfc.readPassiveTargetID(Pn532.MIFARE_ISO14443A)
        if success:
            print(f"Found an NFC tag with UID: {''.join([hex(i)[2:].zfill(2) for i in uid])}")
        else:
            print("No NFC tag detected.")
        time.sleep(0.5)  # Adjust the delay as needed
except KeyboardInterrupt:
    print("\nExiting...")