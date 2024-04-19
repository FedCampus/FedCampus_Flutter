import time
import json
import os
import requests
from email_helper import app

import sys
sys.path.append("/root/program/FedCampus_Flutter/fa_backend/send_email")
sys.path.append("/root/program/FedCampus_Flutter/fa_backend")
import main as email #Import the sendemail func

#Issue: Authentication for /backend/credit endpoint
#Issue: How to access email services
@app.task()
def creditAlert(test=False):
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
                        netid_list.append(netid) #for testing only, replace with var: netid
                        #Deduct the credit
                        content_list.append(f"""<Login Reminder>: You ({netid}) have logged in {value} times in 14 days, while the minimun according to the agreement is 9 \n
                                            If you have encountered any technical difficulty, please reach out for support in the FedCampus user wechat group \n
                                            Please be reminded that your watch will be retrieved for continuous violation of policy.""")
                        email.sendmail(content_list, netid_list, "FedCampus Login Reminder")
                return "Task Completed"
            else:
                return f"Http Error: {response.status_code}"
        else:
            content = ["<Testing> Hello World"]
            email.sendmail(content, ["sc927"], "FedCampus Login Reminder")
            return "Task Completed"
    except:
        raise