import requests
from email_helper import app

import sys
sys.path.append("/root/program/FedCampus_Flutter/fa_backend/send_email")
sys.path.append("/root/program/FedCampus_Flutter/fa_backend")
import main as email #Import the sendemail func


@app.task()
def loginAlert():
    #Put the current emailing function here
    pass