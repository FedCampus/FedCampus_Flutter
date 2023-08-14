import logging
import json
import time
import datetime

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
from .serializers import RegisterSerializer

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions
from rest_framework.authentication import SessionAuthentication


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


FA_DATA = [
    "step_time",
    "distance",
    "calorie",
    "intensity",
    "stress",
    "step",
    "sleep_efficiency",
]


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


class Register(APIView):
    authentication_classes = []
    permission_classes = (permissions.AllowAny,)

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        return Response(
            {
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
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        logger.info("received data: " + str(request.data))

        for i in request.data:
            data = i
            saveRecord(
                Record,
                user=request.user,
                data=data,
                startTime=int(
                    time.strftime(
                        "%Y%m%d%H%M%S", time.localtime(data.get("startTime") + 28800)
                    )
                ),
                endTime=int(
                    time.strftime(
                        "%Y%m%d%H%M%S", time.localtime(data.get("startTime") + 28800)
                    )
                ),
                dataType=data.get("name"),
            )
        return Response(None)


# Exercise Data with DP
class DataDP(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        logger.info("received data dp: " + str(request.data))

        for i in request.data:
            data = i
            saveRecord(
                RecordDP,
                user=request.user,
                data=data,
                startTime=int(
                    time.strftime(
                        "%Y%m%d%H%M%S", time.localtime(data.get("startTime") + 28800)
                    )
                ),
                endTime=int(
                    time.strftime(
                        "%Y%m%d%H%M%S", time.localtime(data.get("startTime") + 28800)
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
    # authentication_classes = [SessionAuthenticataion]
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        # timeDate = 0
        # for data in request.data:
        #     timeDate = 0 if data.get("time") is None else data.get("time")
        startTime = int(
            time.strftime(
                "%Y%m%d%H%M%S",
                time.localtime(request.data[0].get("startTime") + 28800),
            )
        )
        print(startTime)
        now = datetime.datetime.now()
        currentDate = now.year * 10000 + now.month * 100 + now.day

        for data in request.data:
            timeDate = data.get("time")
            if timeDate:
                # check if it is current day
                now = datetime.datetime.now()
                currentDate = now.year * 10000 + now.month * 100 + now.day
                if currentDate == timeDate:
                    # same day, continue
                    continue
                else:
                    # check the result and give the result back to user
                    return self.checkAndSend(timeDate, request)
                    pass
                pass
            else:
                saveRecord(
                    Data=RecordDP,
                    user=request.user,
                    dataType=data.get("name"),
                    startTime=int(
                        time.strftime(
                            "%Y%m%d%H%M%S",
                            time.localtime(data.get("startTime") + 28800),
                        )
                    ),
                    endTime=int(
                        time.strftime(
                            "%Y%m%d%H%M%S",
                            time.localtime(data.get("startTime") + 28800),
                        )
                    ),
                    data=data,
                )
                pass
        return Response(None)

    def checkAndSend(self, dateTime, request):
        dateTime = dateTime * 1000000
        result = RecordDP.objects.filter(
            Q(startTime=dateTime) & Q(user=request.user) & Q(dataType__in=FA_DATA)
        )
        avgJson = {}

        # TODO : change this to ==
        if result.count() < len(FA_DATA):
            return Response(None, status=452)
        else:
            for dataType in FA_DATA:
                querySet = RecordDP.objects.filter(
                    Q(dataType=dataType) & Q(startTime=dateTime)
                ).order_by("-value")
                avg = querySet.aggregate(Avg("value")).get("value__avg")
                percentage = self.calculatePercentage(querySet, request)
                avgJson[dataType] = {"avg": avg, "ranking": percentage}
            return Response(avgJson)

    def sendToday(self, dateTime, request):
        dateTime = dateTime * 1000000
        result = RecordDP.objects.filter(
            Q(startTime=dateTime) & Q(user=request.user) & Q(dataType__in=FA_DATA)
        )
        avgJson = {}

    def calculatePercentage(self, querySet, request):
        query = querySet.get(user=request.user)
        ranking = (
            querySet.filter(value__gt=query.value).count() + 1
        )  # ranking = index + 1
        totalLength = querySet.count()
        realPercentage = ranking / totalLength * 100
        for i in range(1, 21):
            # print(i * 5)
            i = i * 5
            if i >= realPercentage:
                return i
        raise Exception(
            f"The real Percentage is {realPercentage}, and it is not in range 0-100"
        )
        # exerciseType = request.data.get("type")
        # dateTime = int(request.data.get("date")) * 1000000
        # logger.info(f"get {exerciseType} and {dateTime}")

        # ## TODO: check if the current user is in the list or not
        # if not RecordDP.objects.filter(
        #     Q(startTime=dateTime) & Q(user=request.user) & Q(dataType=exerciseType)
        # ).exists():
        #     ## let the user send the data to the backend server
        #     return Response(None, status=452)

        # querySet = RecordDP.objects.filter(
        #     Q(startTime=dateTime) & Q(dataType=exerciseType)
        # ).order_by("-value")
        # avg = querySet.aggregate(Avg("value")).get("value__avg")
        # query = querySet.get(user=request.user)
        # index = querySet.filter(value__gt=query.value).count()  # ranking = index + 1
        # similarUsers = getSimilarUser(querySet, index, 1)

        # return Response({"avg": avg, "rank": index + 1, "similar_user": similarUsers})


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
