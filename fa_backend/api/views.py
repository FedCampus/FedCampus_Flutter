import logging
import json
import time

from .models import Record
from .models import SleepTime
from .models import RecordDP
from .models import saveRecord

from django.contrib.auth import login
from django.contrib.auth import logout
from django.db.models import Q
from django.db.models import Avg

# Create your views here.
from .serializers import LoginSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions
from rest_framework.authentication import SessionAuthentication


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


EXERCISE_DATA = ["steps", "calories", "elevation", "intensity", "distance"]


class Login(APIView):
    permission_classes = (permissions.AllowAny,)
    authentication_classes = []

    def post(self, request, format=None):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data["user"]

        nickname = user.customer.nickname
        email = user.email
        return Response(
            {
                "nickname": nickname,
                "email": email,
                "auth_token": serializer.validated_data["auth_token"],
            }
        )


class TestView(APIView):
    authentication_classes = [SessionAuthentication]
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request):
        print(request.user)
        print(request.META)

        return Response({"aa": 11})


# Exercise Data without DP
class Data(APIView):
    authentication_classes = [SessionAuthentication]
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        logger.info("received data: " + str(request.data))

        for i in request.data.values():
            data = json.loads(i)
            saveRecord(
                Record,
                user=request.user,
                data=data,
                startTime=int(
                    time.strftime(
                        "%Y%m%d%H%M%S", time.localtime(data.get("start") + 28800)
                    )
                ),
                endTime=int(
                    time.strftime(
                        "%Y%m%d%H%M%S", time.localtime(data.get("start") + 28800)
                    )
                ),
                dataType=data.get("name"),
            )
        return Response(None)


# Exercise Data with DP
class DataDP(APIView):
    authentication_classes = [SessionAuthentication]
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        logger.info("received data dp: " + str(request.data))

        for i in request.data.values():
            data = json.loads(i)
            saveRecord(
                RecordDP,
                user=request.user,
                data=data,
                startTime=int(
                    time.strftime(
                        "%Y%m%d%H%M%S", time.localtime(data.get("start") + 28800)
                    )
                ),
                endTime=int(
                    time.strftime(
                        "%Y%m%d%H%M%S", time.localtime(data.get("start") + 28800)
                    )
                ),
                dataType=data.get("name"),
            )
        return Response(None)


# Health Data
class HealthData(APIView):
    authentication_classes = [SessionAuthentication]
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        # logger.info("received data: "+ str(request.data))

        try:
            sleepData = request.data.get("sleep")
            sleepData = json.loads(sleepData)

            for key, value in sleepData.items():
                logger.info(f"RECEIVED Sleep Data: {value}")

                SleepTime.saveRecord(
                    user=request.user,
                    startTime=int(
                        time.strftime(
                            "%Y%m%d%H%M%S", time.localtime(value.get("start") + 28800)
                        )
                    ),
                    endTime=int(
                        time.strftime(
                            "%Y%m%d%H%M%S", time.localtime(value.get("end") + 28800)
                        )
                    ),
                    data=value,
                )

        except:
            logger.warn("sleep data not found")
            pass

        return Response(None)

    pass


class Logout(APIView):
    authentication_classes = [SessionAuthentication]
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request):
        logout(request)
        return Response(None)
        pass


class Account(APIView):
    authentication_classes = [SessionAuthentication]
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        nickname = request.data.get("nickname")
        email = request.data.get("email")
        logger.info(f"account received {nickname} , {email}")

        user = request.user

        # username is email
        user.email = email
        user.username = email

        user.save()

        customer = user.customer
        customer.nickname = nickname
        customer.save()

        logger.info("change account information successfully")

        return Response(None)


class FedAnalysis(APIView):
    authentication_classes = [SessionAuthentication]
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        exerciseType = request.data.get("type")
        dateTime = int(request.data.get("date")) * 1000000
        logger.info(f"get {exerciseType} and {dateTime}")

        ## TODO: check if the current user is in the list or not
        if not RecordDP.objects.filter(
            Q(startTime=dateTime) & Q(user=request.user) & Q(dataType=exerciseType)
        ).exists():
            ## let the user send the data to the backend server
            return Response(None, status=452)

        querySet = RecordDP.objects.filter(
            Q(startTime=dateTime) & Q(dataType=exerciseType)
        ).order_by("-value")
        avg = querySet.aggregate(Avg("value")).get("value__avg")
        query = querySet.get(user=request.user)
        index = querySet.filter(value__gt=query.value).count()  # ranking = index + 1
        similarUsers = getSimilarUser(querySet, index, 1)

        return Response({"avg": avg, "rank": index + 1, "similar_user": similarUsers})


def getSimilarUser(querySet, index, length=1):
    ## get the similar user that is similar to the current user
    result = []
    indexLength = querySet.count() - 1
    lowerBound = max(index - length, 0)
    upperBound = min(index + length, indexLength)

    for i in range(lowerBound, upperBound + 1):
        if i == index:
            continue
        user = querySet[i].user
        result.append(f"{user.customer.nickname}, {user.email}")

    return result
    pass
