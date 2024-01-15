from api.models import *
import pandas as pd

# start_times = [20231210, 20231211, 20231212]

from datetime import datetime, timedelta

# Get current date
today = datetime.now().date()

# Create a list to store the dates
past_30_days = []

# Generate the past 30 days
for i in range(30):
    # Subtract i days from the current date
    date = today - timedelta(days=i)
    # Format the date as 'yyyyMMdd'
    formatted_date = date.strftime("%Y%m%d")
    # Append the formatted date to the list
    past_30_days.append(formatted_date)

# Print the list of past 30 days
print(past_30_days)

records = RecordDP.objects.values("user", "startTime", "dataType", "value").filter(
    startTime__in=past_30_days
)
df = pd.DataFrame(records)

df.to_excel("output.xlsx")
