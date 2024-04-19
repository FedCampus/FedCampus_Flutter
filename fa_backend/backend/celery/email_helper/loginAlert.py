import time
from email_helper import app
from send_email.main import *

@app.task()
def loginAlert():
    print("Sending reminder emails...")
    time.sleep(5)
    return True