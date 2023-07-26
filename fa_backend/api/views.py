import logging
import json
import time

from .models import Record
from .models import SleepTime
from .models import RecordDP

from django.contrib.auth import login
from django.contrib.auth import logout

# Create your views here.
from rest_framework.authtoken.serializers import AuthTokenSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions
from rest_framework.authentication import SessionAuthentication

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


EXERCISE_DATA = ["steps", "calories", "elevation","intensity","distance"]


class Login(APIView):

    permission_classes = (permissions.AllowAny,)

    def post(self, request, format=None):
        serializer = AuthTokenSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        login(request, user)

        nickname = user.customer.nickname
        email = user.email
        return Response({"nickname":nickname, "email":email})

class TestView(APIView):

    authentication_classes = [SessionAuthentication]
    permission_classes = (permissions.IsAuthenticated,)

    def get(self,request):
        print (request.user)
        print(request.META)

        return Response({"aa":11})


# Exercise Data without DP
class Data(APIView):

    authentication_classes=[SessionAuthentication]
    permission_classes = (permissions.IsAuthenticated,)

    def post(self,request):
        logger.info("received data: "+ str(request.data))
        
        for i in request.data.values():
            data = json.loads(i)
            Record.saveRecord(user = request.user,
                              data = data,
                              startTime= int (time.strftime("%Y%m%d%H%M%S",time.localtime(data.get('start')+28800))),
                              endTime = int (time.strftime("%Y%m%d%H%M%S",time.localtime(data.get('start')+28800))),
                              dataType = data.get("name")
                              )
        return Response(None)

# Exercise Data with DP
class DataDP(APIView):

    authentication_classes=[SessionAuthentication]
    permission_classes = (permissions.IsAuthenticated,)

    def post(self,request):
        logger.info("received data dp: "+ str(request.data))
        
        for i in request.data.values():
            data = json.loads(i)
            RecordDP.saveRecord(user = request.user,
                              data = data,
                              startTime= int (time.strftime("%Y%m%d%H%M%S",time.localtime(data.get('start')+28800))),
                              endTime = int (time.strftime("%Y%m%d%H%M%S",time.localtime(data.get('start')+28800))),
                              dataType = data.get("name")
                              )
        return Response(None)

# Health Data
class HealthData(APIView):

    authentication_classes=[SessionAuthentication]
    permission_classes = (permissions.IsAuthenticated,)

    def post(self,request):
        # logger.info("received data: "+ str(request.data))

        try:
            sleepData = request.data.get("sleep")
            sleepData =  json.loads(sleepData)

            for key,value in sleepData.items():
                logger.info(f"RECEIVED Sleep Data: {value}")

                SleepTime.saveRecord(user = request.user, 
                                     startTime= int (time.strftime("%Y%m%d%H%M%S",time.localtime(value.get('start')+28800))), 
                                     endTime= int (time.strftime("%Y%m%d%H%M%S",time.localtime(value.get('end')+28800))), 
                                     data = value)


        except:
            logger.warn("sleep data not found")
            pass

        return Response(None)
    pass

class Logout(APIView):
    authentication_classes=[SessionAuthentication]
    permission_classes = (permissions.IsAuthenticated,)

    def get(self,request):
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