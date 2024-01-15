import logging

from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.db.models import Q

from api.models import Customer
from api.models import Record

from datetime import datetime, timedelta

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
    current_dt = datetime((datetime.now().year),datetime.now().month,datetime.now().day,0,0,0,0)
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
