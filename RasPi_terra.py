#!/usr/bin/python3

import Adafruit_DHT
import time
import subprocess
import sys 
import datetime
import os.path
import os
from gpiozero import OutputDevice

                         

#specify sensor attributes
measurement = "DHT22"
sensortype = Adafruit_DHT.DHT22

#GPIO sensors (which gpio pin is connected to which terrarium?)
Top = 18
Mid = 24
Bottom = 20
Room = 21 
sensors=[Top, Mid, Bottom, Room]

#GPIO fan
fangpio = 23
fan = OutputDevice(fangpio)

#set monthly fan parameters (fan starts above high threshold and stops below lower threshold)
myMonths = { "January" : [20,22],
             "February" : [20,22],
             "March" : [20,22],
             "April" : [21,23],
             "May" : [21,23],
             "June" : [22, 24],
             "July" : [23,25],
             "August" : [23,25],
             "September" : [23,25],
             "October" : [21,23],
             "November" : [20,22],
             "December" : [20,22],}


running = True

if os.path.exists("sensor_readings.txt"):
    file = open("sensor_readings.txt", "a")
else:
    file = open("sensor_readings.txt", "w")
    file.write("time, date, pin, temperature(C), humidity(%)\n")

#loops through sensors to get readings (prints readings in terminal and writes them to a .txt file which can be processed using the .R code)
while running:
    #read sensors
    try:
        for sensor in sensors:
            humidity, temperature = Adafruit_DHT.read_retry(sensortype, sensor)
            iso = datetime.datetime.utcnow().isoformat()
            if humidity is not None and temperature is not None:
                #print to screen
                print(iso,str(sensor),u"Temperature (℃) =",str(temperature),"Humidity (%) =",str(humidity))
                #write local file
                file.write(time.strftime("%H:%M:%S"+", "+"%d/%m/%Y")+", "+str(sensor)+", "+str(temperature)+", "+str(humidity)+'\n')
            else:
                print('Failed to get reading. Try again!')
                time.sleep(30)        
    except KeyboardInterrupt:
        print ('Program stopped')
        running = False
        file.close()

    #control the fan    
    try:
        currentMonth = datetime.datetime.now().strftime("%B")
        upper = myMonths[currentMonth][1]
        lower = myMonths[currentMonth][0]
        bottom = 20
        print("The upper temperature limit for ", currentMonth, "is ", upper)
        print("The lower temperature limit for ", currentMonth, "is ", lower)

        humidity, temperature = Adafruit_DHT.read_retry(sensortype, bottom)
        if temperature > upper and not fan.value:
            fan.on()
        elif temperature < lower and fan.value:
            fan.off()
        time.sleep(5) 
    except KeyboardInterrupt:
        print ('Program stopped')
        running = False

    time.sleep(30)   




