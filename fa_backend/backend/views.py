import logging

from rest_framework.decorators import api_view
from rest_framework.response import Response
from backend.serializers import CreditSerializer
from rest_framework import generics
from rest_framework import mixins
from django.db.models import Q
from django.shortcuts import render

from api.models import Customer
from api.models import Record

from datetime import datetime, timedelta

from collections import OrderedDict

import pandas as pd  # Creating visualizations
from plotly.offline import plot
import plotly.express as px

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@api_view(["GET"])
def getActive(request, startTime: int, endTime: int):
    """
    startTime: int
    endTime: int
    """
    ## TODO: add whitelist
    whitelist = request.query_params.get("whitelist")
    r = Record.objects.filter(Q(startTime__gte=startTime) & Q(startTime__lte=endTime))

    res = {}
    for c in Customer.objects.all():
        # logger.info(r.filter(user=c.user).count())
        res[c.netid] = [
            i["startTime"]
            for i in list(r.filter(user=c.user).values("startTime").distinct())
        ]
        pass

    return Response(
        {
            "msg": startTime,
            "end": endTime,
            "res": res,
        }
    )


@api_view(["GET"])
def getRecentInactive(request):
    # Get the start/stop timestamp for the recent 14 days
    current_dt = datetime(
        (datetime.now().year), datetime.now().month, datetime.now().day, 0, 0, 0, 0
    )
    endTime = current_dt.strftime("%Y%m%d")
    start_dt = current_dt - timedelta(days=14)  # 14days earlier
    startTime = start_dt.strftime("%Y%m%d")

    # Fliter all records within the time period
    r = Record.objects.filter(Q(startTime__gte=startTime) & Q(startTime__lte=endTime))

    res = {}
    for c in Customer.objects.all():
        res[c.netid] = [
            i["startTime"]
            for i in list(r.filter(user=c.user).values("startTime").distinct())
        ]

    inactive_users = {}
    for user, record in res.items():
        logins = len(record)
        if logins <= 10:
            inactive_users[
                user
            ] = logins  # A dictionary with inactive users and total uploads

    return Response(
        {
            "res": inactive_users,
        }
    )


# A django view for rendering the mainpage/use this instead
def mainPage(request):
    # Get the start/stop timestamp for the recent 14 days
    tempCurrent = datetime.now()
    end_dt = tempCurrent - timedelta(days=1)  # Counting from yesterday
    endTime = end_dt.strftime("%Y%m%d")
    start_dt = tempCurrent - timedelta(days=14)  # 14days earlier
    startTime = start_dt.strftime("%Y%m%d")

    # generate a list of the date/timestamps
    timeList = []
    for i in range(14, 0, -1):
        temp_dt = tempCurrent - timedelta(days=i)
        timeList.append(temp_dt.strftime("%Y%m%d"))
    # print(timeList, startTime, endTime) - OK

    # Fliter all records within the time period
    r = Record.objects.filter(Q(startTime__gte=startTime) & Q(startTime__lte=endTime))

    # Get total user count
    userCount = {
        "number": Customer.objects.count(),
    }

    # Raw login data for last 14 days
    res = {}
    for c in Customer.objects.all():
        res[c.netid] = [
            i["startTime"]
            for i in list(r.filter(user=c.user).values("startTime").distinct())
        ]

    # Get problematic users(1)/daily active user count(2) based on raw data
    inactive_users = {}
    active_users = {date: 0 for date in timeList}  # Fix datastructure
    for user, record in res.items():
        # 1
        logins = len(record)
        if logins < 10:
            inactive_users[
                user
            ] = logins  # A dictionary with inactive users and total uploads
        # 2
        for date in record:
            active_users[date] += 1

    # Create visualizations
    df = pd.DataFrame(
        {"Date": active_users.keys(), "activeUsers": active_users.values()}
    )
    activeUserFig = px.bar(
        df, x="Date", y="activeUsers", title="Active Users in recent 14 days"
    )
    template_activeUserFig = plot(activeUserFig, output_type="div")

    # The context dictionary to pass in
    context = {
        "userCount": userCount,
        "warningList": OrderedDict(
            sorted(inactive_users.items(), key=lambda x: x[1])
        ),  # Organized the increasing
        "activeUsers": active_users,
        "activeUsersFig": template_activeUserFig,
    }
    return render(request, "main.html", context)

class CreditManagementView(mixins.ListModelMixin, 
                           mixins.UpdateModelMixin, 
                           generics.GenericAPIView):
    queryset = Customer.objects.all()
    serializer_class = CreditSerializer
    lookup_field = "netid"
    
    def get(self, request, *args, **kwargs):
        return self.list(request, *args, **kwargs)
    
    def put(self, request, *args, **kwargs):
        return self.put(request, *args, **kwargs)
