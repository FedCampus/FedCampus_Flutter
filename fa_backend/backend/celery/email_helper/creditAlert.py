import time
import json
import os
import requests
from email_helper import app

import sys
sys.path.append("/root/program/FedCampus_Flutter/fa_backend/send_email")
import main as email #Import the sendemail func

#Issue: Authentication for /backend/credit endpoint
#Issue: How to access email services
@app.task()
def creditAlert(test=True):
    try:
        if test == False:
            # Get login data from backend api
            response = requests.get(f"http://0.0.0.0:50000/backend/active/recents")
            if response.status_code == 200:
                login_data = response.json()
                netid_list = list()
                content_list = list()
                for netid, value in login_data['res'].items():
                    if value < 9:
                        netid_list.append(netid)
                        content_list.append(f"<Testing>: {netid} have logged in {value} times in 14 days.")
                        email.sendmail(content, netid, "FedCampus Login Reminder")
                return "Task Completed"
            else:
                return f"Http Error: {response.status_code}"
        else:
            content = ["<Testing> Hello World"]
            email.sendmail(content, ["sc927"], "FedCampus Login Reminder")

    except:
        raise