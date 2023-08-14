import logging

from django.db import models
from django.db.models import Q
from django.contrib.auth.models import User
import djoser

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create your models here.


## The record without any DP applied, merely data
class Record(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    startTime = models.IntegerField(null=True, blank=True)
    endTime = models.IntegerField(null=True, blank=True)
    # data = models.JSONField(null=True, blank=True)
    dataType = models.CharField(max_length=10, null=True, blank=True)
    value = models.FloatField(null=True, blank=True)

    def saveRecord(user, startTime, endTime, dataType, data):
        try:
            record = Record.objects.filter(
                Q(user=user)
                & Q(startTime=startTime)
                & Q(endTime=endTime)
                & Q(dataType=dataType)
            )[0]
            value = record.value
            if not value == float(data.get("value")):
                # record.data = data
                record.value = float(data.get("value"))
                record.save()
        except:
            record = Record.objects.create(
                user=user,
                startTime=startTime,
                endTime=endTime,
                # data=data,
                dataType=dataType,
                value=data.get("value"),
            )
            logger.info(f"record created {data}")

    def __str__(self):
        return str(self.startTime)[0:9] + " " + str(self.dataType)


## This record adds some white noise
class RecordDP(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    startTime = models.IntegerField(null=True, blank=True)
    endTime = models.IntegerField(null=True, blank=True)
    # data = models.JSONField(null=True, blank=True)
    dataType = models.CharField(max_length=10, null=True, blank=True)
    value = models.FloatField(null=True, blank=True)

    def saveRecord(user, startTime, endTime, dataType, data):
        try:
            record = RecordDP.objects.filter(
                Q(user=user)
                & Q(startTime=startTime)
                & Q(endTime=endTime)
                & Q(dataType=dataType)
            )[0]
            value = record.data.get("value")
            if not value == data.get("value"):
                # record.data = data
                record.value = float(data.get("value"))
                record.save()
        except:
            record = RecordDP.objects.create(
                user=user,
                startTime=startTime,
                endTime=endTime,
                # data=data,
                dataType=dataType,
                value=data.get("value"),
            )
            logger.info(f"record created {data}")

    def __str__(self):
        return (
            str(self.startTime)[0:8] + " " + str(self.dataType) + " " + str(self.user)
        )


def saveRecord(Data, user, startTime, endTime, dataType, data):
    ## judge if it is sleep efficiency?

    if dataType == "sleep_efficiency":
        # deal with sleep effieicny
        startTime = startTime // 1000000 * 1000000
        endTime = endTime // 1000000 * 1000000
        pass

    try:
        record = Data.objects.filter(
            Q(user=user)
            & Q(startTime=startTime)
            & Q(endTime=endTime)
            & Q(dataType=dataType)
        )[0]
        value = record.value
        if not value == float(data.get("value")):
            record.value = float(data.get("value"))
            record.save()
    except:
        record = Data.objects.create(
            user=user,
            startTime=startTime,
            endTime=endTime,
            dataType=dataType,
            value=data.get("value"),
        )
        logger.info(f"record created {data}")
    pass


class SleepTime(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    startTime = models.IntegerField()
    endTime = models.IntegerField()
    data = models.JSONField(null=True, blank=True)

    def saveRecord(user, startTime, endTime, data):
        try:
            record = SleepTime.objects.filter(
                Q(user=user) & Q(startTime=startTime) & Q(endTime=endTime)
            )[0]
        except:
            sleepTime = SleepTime.objects.create(
                user=user, startTime=startTime, endTime=endTime, data=data
            )
            logger.info("sleep Time data created")
            pass


class Customer(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    avator = models.ImageField(null=True, blank=True)
    nickname = models.CharField(max_length=30)
    netid = models.CharField(max_length=20, null=True, blank=True)

    def __str__(self):
        return self.nickname
