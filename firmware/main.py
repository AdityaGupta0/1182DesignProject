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