# Send notification to users that have not signed to the app

import django
import os
import datetime
import utility.timer as tim
import pytz
import argparse

from django.db.models import Q

## Environment Setup
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "fedapp.settings")
django.setup()

from django.core.mail import send_mass_mail
from django.conf import settings
from django.contrib.auth.models import User

## Email Settings

## TODO: Whitelist users
whitelist = ["js1139@duke.edu", "tl357@duke.edu", "bt132@duke.edu"]


def getTimeCST(record):
    """
    Input a record. Return a CST time of datetimefield's datetime without timezone information
    """
    return record.update.replace(tzinfo=None) + datetime.timedelta(hours=8)


def sendReminderEmail(*timeTuple):
    """
    send a reminder email, the argument timeTuple is a tuple consists of (hour,minute,second)
    """
    now = tim.cstNow()
    time = datetime.datetime(
        now.year,
        now.month,
        now.day,
        timeTuple[0],
        timeTuple[1],
        timeTuple[2],
        tzinfo=pytz.timezone("Asia/Shanghai"),
    )
    start = datetime.datetime(
        now.year,
        now.month,
        now.day,
        0,
        1,
        0,
        tzinfo=pytz.timezone("Asia/Shanghai"),
    )
    user = list(
        (
            User.objects.all()
            .exclude((Q(recorddp__update__gte=start) & Q(recorddp__update__lte=time)))
            .exclude(username__in=whitelist)
        ).values_list("username", flat=True)
    )

    if len(user) == 0:
        return

    ## send email
    send_mass_mail(
        (
            (settings.SUBJECT, settings.MESSAGE, settings.EMAIL_HOST_USER, [u])
            for u in user
        ),
        fail_silently=True,
    )


def test():
    send_mass_mail(
        [
            (
                settings.SUBJECT,
                settings.MESSAGE,
                settings.EMAIL_HOST_USER,
                ["bt132@duke.edu"],
            )
        ],
    )
    pass


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--test", action="store_true")
    args = parser.parse_args()
    if args.test:
        test()
    else:
        alarm = tim.Alarm()
        taskList = [
            (sendReminderEmail, (17, 30, 0), (17, 30, 0)),
            (sendReminderEmail, (22, 30, 0), (22, 30, 0)),
        ]
        alarm.prepare(taskList)
        alarm.run()
    pass
