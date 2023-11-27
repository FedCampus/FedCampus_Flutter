import pandas as pd
import os
import argparse
import sys
from django.core.mail import send_mass_mail

##
sys.path.append(os.path.dirname(os.getcwd()))
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "fedapp.settings")


def sendmail(
    content, netid, subject, from_email="fedcampus@dukekunshan.edu.cn", test=False
):
    if test:
        # print("testing")
        netid = ["bt132", "sh623", "qz150", "lw337", "bz106", "bl291"]
        # netid = ["bt132"]
    assert len(content) == len(netid)
    send_mass_mail(
        ((subject, c, from_email, [n + "@duke.edu"]) for c, n in zip(content, netid))
    )
    pass


def main(args):
    f = open("reminder.txt", "r").read()

    p = pd.read_excel("FecCampus Watches.xlsx")
    p = p[p["Watch Serial Number"].isnull()]
    p = p[p["Checked"] != 0]
    p = p[p["Name"].notnull()]
    name = p["Name"]
    netid = p["NetID"]
    messages = [f % s for s in name]
    if args.email:
        send = True if args.email == "send" else False
        sendmail(
            messages,
            netid,
            "Last Chance to get your Huawei Watches!",
            test=not send,
        )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--email", default="test")
    args = parser.parse_args()
    main(args)
    pass
