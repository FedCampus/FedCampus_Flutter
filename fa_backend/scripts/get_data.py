from api.models import *
import pandas as pd

start_times = [20231210, 20231211, 20231212]
records = RecordDP.objects.values("user", "startTime", "dataType", "value").filter(
    startTime__in=start_times
)
df = pd.DataFrame(records)

df.to_excel("output.xlsx")
