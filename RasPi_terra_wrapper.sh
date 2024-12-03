#!/bin/bash

cd $(dirname $0)

python3 RasPi_terra.py
Rscript -e 'library(methods); shiny::runApp("Raspi_terra_dashboard_code.R", launch.browser = TRUE)'