import json
import logging
import os
import re

from .models import Record
from .models import RecordDP
from .models import Customer
from .models import saveRecord
from .models import Log

from django.contrib.auth import logout
from django.db.models import Q
from django.db.models import Avg

# Create your views here.
from .serializers import LoginSerializer
from .serializers import RegisterSerializer
from .serializers import CustomerSerializer

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions, status
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
    "sleep_time",
    "sleep_duration",
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


def updateUserVersion(version, request):
    if version == None:
        pass
    else:
        c = Customer.objects.get(user=request.user)
        logger.info(f"getting version from {version} and {c.version} ")
        if c.version == version:
            return
        else:
            c.version = version
            c.save()
        pass


# Exercise Data without DP
class Data(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        updateUserVersion(request.data.get("version"), request)
        logger.info(f"received data: from user {request.user} " + str(request.data))
        [
            saveRecord(Record, request.user, data)
            for data in json.loads(request.data.get("data"))
        ]
        return Response(None)


# Exercise Data with DP
class DataDP(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        updateUserVersion(request.data.get("version"), request)
        logger.info("received data dp: " + str(request.data))
        [
            saveRecord(RecordDP, request.user, data)
            for data in json.loads(request.data.get("data"))
        ]
        return Response(None)


class Logout(APIView):
    authentication_classes = [SessionAuthentication]
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request):
        logout(request)
        return Response(None)
        pass


class saveLogFile(APIView):
    def post(self, request):
        file = request.data.get("log")

        # TODO : change the max count of the log file for each user
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


# For easily switching between Record and RecordDP since they share the same schema
FA_MODEL = RecordDP


class Status(APIView):
    permission_classes = [
        permissions.IsAuthenticated,
    ]

    def get(self, request):
        customer = request.user.customer
        cs = CustomerSerializer(customer)
        return Response(cs.data)


def getFilter(startTime, filtering=None):
    """
    Get the filtering querySet with respect to the filtering dictionary and the current day
    Filter value >= 0
    """
    queryAll = FA_MODEL.objects.filter(startTime=startTime).filter(value__gte=0)
    if not filtering == None:
        if filtering.get("gender") == "male":
            queryAll = queryAll.filter(user__customer__male=True)
        elif filtering.get("gender") == "female":
            queryAll = queryAll.filter(user__customer__male=False)
        if filtering.get("status") == "all":
            pass
        elif filtering.get("status") == "student":
            queryAll = queryAll.filter(user__customer__faculty=False)
        elif filtering.get("status") == "faculty":
            queryAll = queryAll.filter(user__customer__faculty=True)
        else:
            queryAll = queryAll.filter(
                user__customer__student=int(filtering.get("status"))
            )
    return queryAll


class Average(APIView):
    """
    Get average with respect to the date and filtering
    """

    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        logger.info(f"request data {request.data}")
        querySet = getFilter(request.data.get("time"), request.data.get("filter"))
        resArray = []
        for f in FA_DATA:
            if f == "sleep_time":
                # NOTE: sleep_time < 120 is excluded here, while sleep_time <= 120 is excluded in models.SaveRecord()
                res = (
                    querySet.filter(Q(dataType=f))
                    .exclude(value__lt=120)
                    .order_by("-value")
                    .aggregate(Avg("value"))
                    .get("value__avg")
                )
            else:
                res = (
                    querySet.filter(Q(dataType=f))
                    .order_by("-value")
                    .aggregate(Avg("value"))
                    .get("value__avg")
                )
            if res == None:
                continue
            if f == "sleep_duration":
                res = (res - 240) if res > 240 else (res + 1200)
            resArray.append((f, res))
        logger.info(f"[getAverage], res {resArray}")
        return Response(dict(resArray))


class Rank(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        querySet = getFilter(request.data.get("time"), request.data.get("filter"))
        return Response(
            dict(
                [
                    (f, self.getRankSingleField(querySet, f, request.user))
                    for f in FA_DATA
                ]
            )
        )

    def getRankSingleField(self, queryAll, field, user):
        """
        querySet: the querySet with the specific date after the filtering |
        field: fa data field to get rank |
        user: the user
        """
        querySet = queryAll.filter(dataType=field)
        if not querySet.filter(user=user).exists():
            return 0
        else:
            try:
                query = querySet.get(user=user)
            except:
                query = querySet.filter(user=user)
                logger.info(f"Exception Getting Two queries at the same time, {query}")
                query = query[0]
            return self.calculatePercentage(querySet, query)

    def calculatePercentage(self, querySet, query):
        # NOTE: `sleep_duration` (which in fact is the bedtime) is ranked from early to late,
        # while the other metrics are ranked from high to low,
        # which might not make sense, for example, for `stress`,
        # as I suppose that higher rank means healthier?
        ranking = (
            querySet.filter(value__lt=query.value).count() + 1
            if query.dataType == "sleep_duration"
            else querySet.filter(value__gt=query.value).count() + 1
        )

        totalLength = querySet.count()
        realPercentage = ranking / totalLength * 100
        for i in range(1, 21):
            i = i * 5
            if i >= realPercentage:
                return i
        raise Exception(
            f"The real Percentage is {realPercentage}, and it is not in range 0-100"
        )


class DPDataPoints(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        start_time = request.data.get("time", "20240110")
        result = {}
        for data_type in FA_DATA:
            data_points = (
                FA_MODEL.objects.filter(startTime=start_time)
                .filter(dataType=data_type)
                .values_list("value", flat=True)
            )
            result[data_type] = list(data_points)

        return Response(result)


MIN_VERSION = "1.1.1"


class VersionCheck(APIView):
    def post(self, request):
        version_string = request.data.get("version")
        if not version_string:
            return Response(
                "No version number provided.", status=status.HTTP_400_BAD_REQUEST
            )

        # NOTE: this means that `1.0` is not valid, while `v1.0` is valid,
        # and it would simply fail if you pass in goofy things like `v1v`
        match = re.search(r"\b([a-zA-Z]+)(.*)$", version_string)
        if not match:
            return Response(
                "Invalid version number format.", status=status.HTTP_400_BAD_REQUEST
            )

        version_number = match.group(2)
        if compare_versions(version_number, MIN_VERSION) >= 0:
            return Response("Client valid version")
        else:
            # NOTE: I do not think having an outdated version means the request itself is bad,
            # but this is just how it goes...
            return Response("Outdated version.", status=status.HTTP_400_BAD_REQUEST)


def compare_versions(version1, version2):
    v1_components = list(map(int, version1.split(".")))
    v2_components = list(map(int, version2.split(".")))

    while len(v1_components) < len(v2_components):
        v1_components.append(0)
    while len(v2_components) < len(v1_components):
        v2_components.append(0)

    for i in range(len(v1_components)):
        if v1_components[i] > v2_components[i]:
            return 1
        elif v1_components[i] < v2_components[i]:
            return -1

    return 0


class VersionCheckLoggedIn(APIView):
    pass


def getSimilarUser(querySet, index, length=1):
    # get the similar user that is similar to the current user
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
