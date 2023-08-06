import random
from rest_framework.views import APIView
from rest_framework.response import Response
import json

# Test both json response and single number response


class Distance(APIView):
    def get(self, request):
        print(request.user)
        print(request.META)

        return Response({"distance": str(int(random.randint(0, 20000))), "unit": "m"})


class HeartRate(APIView):
    def get(self, request):
        print(request.user)
        print(request.META)

        return Response({"high": "120", "low": "60"})


class IntenseExercise(APIView):
    def get(self, request):
        print(request.user)
        print(request.META)

        return Response(78)


class Activity(APIView):
    def get(self, request):
        print(request.user)
        print(request.META)

        res = []

        for i in range(100):
            single_day_res = {}
            single_day_res["date"] = "1/{day}".format(day=i)
            single_day_res["step"] = str(random.randint(0, 20000))
            res.append(single_day_res)

        return Response(res)
