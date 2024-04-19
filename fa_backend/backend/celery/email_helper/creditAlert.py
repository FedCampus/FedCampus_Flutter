import time
import json
import requests
from email_helper import app
from send_email import main as email

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
                for netid, value in login_data['res'].items():
                    if value < 9:
                        content = f"<Testing>: {netid} have logged in {value} times in 14 days."
                        email.sendmail(content, netid, "FedCampus Login Reminder")
                return "Task Completed"
            else:
                return f"Http Error: {response.status_code}"
        else:
            content = "<Testing> Hello World"
            email.sendmail(content, "sc927", "FedCampus Login Reminder")

    except:
        return "Unknown Error"