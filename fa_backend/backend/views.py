import logging

from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import permissions
from rest_framework.authentication import SessionAuthentication, TokenAuthentication
from backend.serializers import CreditSerializer
from rest_framework import generics
from rest_framework import mixins
from django.db.models import Q
from django.shortcuts import render

from api.models import Customer
from api.models import Record, RecordDP

from datetime import datetime, timedelta

from collections import OrderedDict

import pandas as pd  # Creating visualizations
from plotly.offline import plot
import plotly.express as px

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

FA_MODEL = RecordDP

FA_DATA = [
    "step_time",
    "distance",
    "calorie",
    "intensity",
    "stress",
    "step",
    "sleep_efficiency",
    "sleep_time",
    "sleep_duration",
]

CUSTOMER_TYPE = [
    "Faculty",
    "2023",
    "2024",
    "2025",
    "2026",
    "2027",
    "Male",
    "Female",
]

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
def getRecentActive(request):
    # Get the start/stop timestamp for the recent 14 days
    tempCurrent = datetime.now()
    end_dt = tempCurrent - timedelta(days=1)  # Counting from yesterday
    endTime = end_dt.strftime("%Y%m%d")
    start_dt = tempCurrent - timedelta(days=14)  # 14days earlier
    startTime = start_dt.strftime("%Y%m%d")
    # Fliter all records within the time period

    r = Record.objects.filter(Q(startTime__gte=startTime) & Q(startTime__lte=endTime))

    res = {}
    for c in Customer.objects.all():
        res[c.netid] = [
            i["startTime"]
            for i in list(r.filter(user=c.user).values("startTime").distinct())
        ]

    active_users = {}
    for user, record in res.items():
        logins = len(record)
        active_users[user] = (
            logins  # A dictionary with inactive users and total uploads
        )

    return Response(
        {
            "res": active_users,
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
            inactive_users[user] = (
                logins  # A dictionary with inactive users and total uploads
            )
        # 2
        for date in record:
            active_users[str(date)] += 1

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


# /backend/credit - view and update credit for users
class CreditManagementView(
    mixins.ListModelMixin,
    mixins.RetrieveModelMixin,
    mixins.UpdateModelMixin,
    generics.GenericAPIView,
):
    queryset = Customer.objects.all()
    serializer_class = CreditSerializer
    lookup_field = "netid"
    # TODO: Fix authentication
    permission_classes = (permissions.IsAuthenticated,)
    authentication_classes = [SessionAuthentication, TokenAuthentication]

    def get(self, request, *args, **kwargs):
        if "netid" in kwargs:
            return self.retrieve(request, *args, **kwargs)
        return self.list(request, *args, **kwargs)

    def put(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)

class VisualsView(APIView):
    #Returns all data points for visualization

    def post(self, request):
        start_time = request.data.get("date") # pass in a date string("20240110")
        customer_type = request.data.get("customer_type") # pass in customer type(list)
        print(customer_type)
        if not start_time:
            start_time = (datetime.now() - timedelta(days=1)).strftime("%Y%m%d")
        if not customer_type:
            customer_type = list() #TODO：Add classification
            customer_type.append("all")
        else:
            customer_type = [item for item in customer_type if item in CUSTOMER_TYPE]
            if not customer_type:
                customer_type = list()
                customer_type.append("all")

        result = {"filter": customer_type, "date": start_time}
        if customer_type[0] == "all":
            for data_type in FA_DATA:
                data_points = (
                    FA_MODEL.objects.filter(startTime=start_time)
                    .filter(dataType=data_type)
                    .values_list("value", flat=True)
                )
                result[data_type] = list(data_points)
            
            return Response(result)
        else:
            #TODO: Return data in accordance with filters
            return Response(result)