import logging
import json
import time
import os

from .models import Record
from .models import Customer
from .models import SleepTime
from .models import RecordDP
from .models import saveRecord
from .models import Log

from django.contrib.auth import logout
from django.db.models import Q
from django.db.models import Avg
from django.contrib.auth.models import User

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
        logger.info(f"received data: from user {request.user} " + str(request.data))

        [saveRecord(Record, request.user, data) for data in request.data]

        return Response(None)


# Exercise Data with DP
class DataDP(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        logger.info("received data dp: " + str(request.data))

        [saveRecord(RecordDP, request.user, data) for data in request.data]

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


class saveLogFile(APIView):
    def post(self, request):
        file = request.data.get("log")

        ## TODO : change the max count of the log file for each user
        temp_max_count = 2

        if (
            Log.objects.filter(user=request.user).exists()
            and Log.objects.filter(user=request.user).count() >= temp_max_count
        ):
            log = Log.objects.filter(user=request.user).order_by("time")
            os.remove(log[0].file.path)
            log[0].delete()
            pass
        Log.objects.create(user=request.user, file=file)
        return Response(None)
        pass

    pass


FA_MODEL = Record


class FedAnalysis(APIView):
    # authentication_classes = [SessionAuthenticataion]
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        startTime = 0
        filtering = None
        for data in request.data:
            if data.get("time"):
                startTime = data.get("time")
                continue
            if data.get("filter"):
                filtering = data.get("filter")
                continue
            (saveRecord(FA_MODEL, request.user, data)) if not data.get(
                "name"
            ) is None else None
        return Response(self.calculateAverageAndRanking(request, startTime, filtering))

    def calculateAverageAndRanking(self, request, dateTime, filtering):
        resultJson = {}
        # filter querySet accroding to the filtering
        querySet = FA_MODEL.objects.all()
        if not filtering == None:
            if filtering.get("gender") == "male":
                querySet = querySet.filter(user__customer__male=True)
            elif filtering.get("gender") == "female":
                querySet = querySet.filter(user__customer__male=False)
            if filtering.get("status") == "all":
                pass
            elif filtering.get("status") == "student":
                querySet = querySet.filter(user__customer__faculty=False)
            elif filtering.get("status") == "faculty":
                querySet = querySet.filter(user__customer__faculty=True)
            else:
                querySet = querySet.filter(
                    user__customer__student=int(filtering.get("student"))
                )

        for dataType in FA_DATA:
            querySet = querySet.filter(
                Q(dataType=dataType) & Q(startTime=dateTime)
            ).order_by("-value")
            if not querySet.filter(user=request.user).exists():
                continue
            query = querySet.get(user=request.user)
            avg = querySet.aggregate(Avg("value")).get("value__avg")
            percentage = self.calculatePercentage(querySet, query)
            resultJson[dataType] = {"avg": avg, "ranking": percentage}

        return resultJson

    def checkAndSend(self, dateTime, request):
        dateTime = dateTime * 1000000
        result = FA_MODEL.objects.filter(
            Q(startTime=dateTime) & Q(user=request.user) & Q(dataType__in=FA_DATA)
        )
        avgJson = {}

        # TODO : change this to ==
        if result.count() < len(FA_DATA):
            return Response(None, status=452)
        else:
            for dataType in FA_DATA:
                querySet = FA_MODEL.objects.filter(
                    Q(dataType=dataType) & Q(startTime=dateTime)
                ).order_by("-value")
                avg = querySet.aggregate(Avg("value")).get("value__avg")
                percentage = self.calculatePercentage(querySet, request)
                avgJson[dataType] = {"avg": avg, "ranking": percentage}
            return Response(avgJson)

    def calculatePercentage(self, querySet, query):
        ranking = (
            querySet.filter(value__gt=query.value).count() + 1
        )  # ranking = index + 1
        totalLength = querySet.count()
        realPercentage = ranking / totalLength * 100
        for i in range(1, 21):
            i = i * 5
            if i >= realPercentage:
                return i
        raise Exception(
            f"The real Percentage is {realPercentage}, and it is not in range 0-100"
        )


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


class AccountSettings(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        customer = request.user.customer
        data = request.data
        if data.get("faculty") == True:
            customer.faculty = True
        else:
            customer.faculty = False
            customer.student = int(data.get("student"))
        customer.male = data.get("male")
        customer.save()
        return Response(None)

    pass
