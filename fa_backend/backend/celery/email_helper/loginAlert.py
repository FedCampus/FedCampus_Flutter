import time
from email_helper import app

@app.task()
def loginAlert():
    print("Sending reminder emails...")
    time.sleep(5)
    return True