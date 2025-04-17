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

class Module:
    def __init__(self,DT,SCK,nfc):
        self.DT = DT
        self.SCK = SCK
        self.CHANNEL = CHANNEL
        self.hx = HX711(dout_pin=DT, pd_sck_pin=SCK);
        self.nfc = nfc
        self.nfc.SAM_configuration()
