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
whitelist = ["js1139@duke.edu"]


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


def test(users):
    message = """Come get the watch at the corridor outside CCT East Performance Cafe, today (Friday) 12:00 - 13:00.

Dear FedCampus participant,

Congratulations!

Please come to sign the research agreement and receive your watch.

Before you come, please finish the following:

Please install the FedCampus app:
iOS User Guide: https://docs.google.com/document/d/16OosGfHNS69ckl2hmclyRPo8ug6wXdqy0JSiOjB54gc/edit?usp=sharing
(All other users) Android User Guide: https://docs.google.com/document/d/1tIAnfdNrsLij-7I3Wybz8Kip8ddZWxetK0vebB4MgPM/edit?usp=sharing

Please preview the research agreement for you to sign today: https://drive.google.com/file/d/1rPYjC0e_-_q7yUkHufKRzOlNN2U1hm-V/view

If you could not come today, but still wish to participate, please reply to us and we will schedule for another time.

We look forward to seeing you today.


Sincerely,
The FedCampus Team"""

    send_mass_mail(
        (
            (
                "You are accepted to participate in FedCampus",
                message,
                "fedcampus@dukekunshan.edu.cn",
                [u + "@duke.edu"],
            )
            for u in users
        ),
    )
    pass


def test1(users):
    message = """Come sign the agreement regarding the ￥100 gift at the corridor outside CCT East Performance Cafe, today(Friday) 11:30 - 12:00.

Dear FedCampus participant,

Before you come, please finish the following:

Please install the FedCampus app:
iOS User Guide: https://docs.google.com/document/d/16OosGfHNS69ckl2hmclyRPo8ug6wXdqy0JSiOjB54gc/edit?usp=sharing
(All other users) Android User Guide: https://docs.google.com/document/d/1tIAnfdNrsLij-7I3Wybz8Kip8ddZWxetK0vebB4MgPM/edit?usp=sharing

Please preview the research agreement for you to sign today: https://drive.google.com/file/d/1FoZup5JWbtXHf7SGxFymyWBCuy62LPYR/view

If you could not come today, but still wish to participate, please reply to us and we will schedule for another time.

We look forward to seeing you today.


Sincerely,
The FedCampus Team"""

    send_mass_mail(
        (
            (
                "You are accepted to participate in FedCampus",
                message,
                "fedcampus@dukekunshan.edu.cn",
                [u + "@duke.edu"],
            )
            for u in users
        ),
    )

    user_test = ["bt132", "sh623", "qz150", "lw337", "bz106", "bl291"]
    send_mass_mail(
        (
            (
                "You are accepted to participate in FedCampus",
                message,
                "fedcampus@dukekunshan.edu.cn",
                [u + "@duke.edu"],
            )
            for u in user_test
        ),
    )
    pass


def test2(users):
    message = """Dear FedCampus research applicant,


We sincerely appreciate your interest and willingness to participate in our research.

Due to high volumes of registration, our available participant slots have reached capacity. As a result, we regret to inform you that you have been placed on our waitlist.

Should a spot become available, we will notify you promptly.


Sincerely,
The FedCampus Team"""

    send_mass_mail(
        (
            (
                "You are in the waitlist to participate in FedCampus",
                message,
                "fedcampus@dukekunshan.edu.cn",
                [u + "@duke.edu"],
            )
            for u in users
        ),
    )

    user_test = ["bt132", "sh623", "qz150", "lw337", "bz106", "bl291"]
    send_mass_mail(
        (
            (
                "You are in the waitlist to participate in FedCampus",
                message,
                "fedcampus@dukekunshan.edu.cn",
                [u + "@duke.edu"],
            )
            for u in user_test
        ),
    )
    pass


if __name__ == "__main__":
    import pandas as pd

    ## watch1
    f = pd.read_excel("no_watches_final.xlsx")
    test(f["NetID"])
    ## withoutwatch
    f = pd.read_excel("has_watch_fianal.xlsx")
    # print(f["NetID"])
    test1(f["NetID"])
    ## waitlest
    # f = pd.read_excel("waitlist.xlsx")
    # print(f["NetID"])
    # test2(f["NetID"])
    pass
