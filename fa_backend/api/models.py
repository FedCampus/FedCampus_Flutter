import logging

from django.db import models
from django.db.models import Q
from django.contrib.auth.models import User

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create your models here.


## The record without any DP applied, merely data
class Record(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    startTime = models.IntegerField(null=True, blank=True)
    endTime = models.IntegerField(null=True, blank=True)
    dataType = models.CharField(max_length=10, null=True, blank=True)
    value = models.FloatField(null=True, blank=True)
    update = models.DateTimeField(auto_now=True)

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
    update = models.DateTimeField(auto_now=True)

    def __str__(self):
        return (
            str(self.startTime)[0:8] + " " + str(self.dataType) + " " + str(self.user)
        )


def saveRecord(Model, user, data):
    ## judge if it is sleep efficiency?

    if float(data.get("value")) < 0:
        logger.info(f"getting value -1 from {data}")
        return

    try:
        record = Model.objects.filter(
            Q(user=user)
            & Q(startTime=data.get("startTime"))
            & Q(dataType=data.get("name"))
        )[0]
        record.value = float(data.get("value"))
        record.save()
        logger.info(f"rewrite record {data} for {Model}")
    except:
        record = Model.objects.create(
            user=user,
            startTime=data.get("startTime"),
            endTime=data.get("endTime"),
            dataType=data.get("name"),
            value=data.get("value"),
        )
        logger.info(f"record created {data}")
    pass


class SleepTime(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    startTime = models.IntegerField()
    endTime = models.IntegerField()
    data = models.JSONField(null=True, blank=True)


class Customer(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    avator = models.ImageField(null=True, blank=True)
    nickname = models.CharField(max_length=30)
    netid = models.CharField(max_length=20, null=True, blank=True)
    faculty = models.BooleanField(null=True, blank=True)
    student = models.SmallIntegerField(null=True, blank=True)
    male = models.BooleanField(null=True, blank=True)

    def __str__(self):
        return self.nickname


class Log(models.Model):
    def filename(instance, filename):
        return "logs/" + instance.user.__str__() + "-" + instance.time.__str__()
        pass

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    time = models.DateTimeField(auto_created=True, auto_now_add=True)
    file = models.FileField(upload_to=filename)

    def __str__(self) -> str:
        return self.user.__str__() + " " + self.time.__str__()
