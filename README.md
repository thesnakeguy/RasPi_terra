# RasPi_terra

RasPi_terra is a tool for monitoring and controlling environmental conditions in terrariums using a Raspberry Pi. This repository contains the code for:

1. Reading temperature and humidity data from multiple DHT22 sensors.
2. Automatically controlling a fan based on predefined thresholds.
3. Visualizing the data on an interactive dashboard created with R and Shiny.

---

## Features

- **Sensor Monitoring**: Continuously reads temperature and humidity data from up to four DHT22 sensors.
- **Fan Control**: Automatically manages fan operation based on monthly temperature thresholds.
- **Interactive Dashboard**: Displays real-time and historical data trends in an R Shiny application with multiple tabs for detailed analysis.

---

## Setup Instructions

### Hardware Requirements

- Raspberry Pi with GPIO pins.
- Up to four DHT22 sensors. (easily expandable with additional code)
- A fan connected to a GPIO pin.
- Required libraries installed on the Raspberry Pi (`Adafruit_DHT`, `gpiozero`, etc.).

### Software Prerequisites

1. Install Python 3 and required Python libraries:
   ```bash
   pip3 install Adafruit_DHT gpiozero
2. R with following packages: shiny, shinyWidgets, stringr, lubridate, dplyr, ggplot2.
3. Command line software such as "Ubuntu for windows" to run the .sh wrapper script.
