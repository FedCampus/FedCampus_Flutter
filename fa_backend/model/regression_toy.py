# Generate the toy regression model
# y = k*x + b
# x is the [step,calorie]
# y is the distance

#### Environment Setup (Dont need to change)
import os
import sys
import django
sys.path.append(os.path.abspath(os.path.pardir))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'fedapp.settings')
django.setup()
####

import csv
from api.models import Record
from django.db.models import Q


def getData():
    
    step = Record.objects.filter(dataType = "steps").order_by("startTime")

    calorie = Record.objects.filter(dataType="calories").order_by("startTime")

    distance = Record.objects.filter(dataType="distance").order_by("startTime")

    ## make sure their number is the same
    return step, calorie, distance

def toExcel(step,calorie,distance):


    with open('data.csv', 'w') as file:
        title = ['step','calorie','distance']
        writer = csv.writer(file)
        writer.writerow(title)
        for i in range(0,step.count()):
            writer.writerow([step[i].data.get("value"),calorie[i].data.get("value"),distance[i].data.get("value")])
            pass

    pass

if __name__=="__main__":
    step, calorie, distance = getData()
    toExcel(step,calorie,distance)

    pass