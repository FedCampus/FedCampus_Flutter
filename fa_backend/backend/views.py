from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.db.models import Q

from api.models import Customer
from api.models import Record


@api_view(["GET"])
def getActive(request, startTime, endTime):
    r = Record.objects.filter(Q(startTime__gte=startTime) & Q(startTime__lte=endTime))
    return Response({"msg": startTime, "end": endTime, "r": r})
