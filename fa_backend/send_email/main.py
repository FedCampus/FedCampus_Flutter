import pandas as pd
import os
import argparse
import sys
from django.core.mail import send_mass_mail

##
sys.path.append(os.path.dirname(os.getcwd()))
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "fedapp.settings")

test = ["bt132", "sh623", "qz150", "lw337", "bz106", "bl291"]  ## fedcampus core members


def sendmail(
    content, netid, subject, from_email="fedcampus@dukekunshan.edu.cn", test=False
):
    if test:
        print("testing")
        netid = test
        content = content[: len(netid)]
    assert len(content) == len(netid)
    send_mass_mail(
        ((subject, c, from_email, [n + "@duke.edu"]) for c, n in zip(content, netid))
    )
    pass


def main(args):
    ####### change the content here #######
    f = open("waitlist.txt", "r").read()
    p = pd.read_excel("FecCampus Watches.xlsx", sheet_name="waitlist")
    p = p[p["Grade"] != 2024]
    p = p[p["Status"] == "student"]
    name = p["Name"]

    # p = p[p["Watch Serial Number"].isnull()]
    # p = p[p["Checked"] != 0]
    # p = p[p["Name"].notnull()]
    # name = p["Name"]
    netid = p["NetID"]
    messages = [f % s for s in name]
    assert len(netid) == len(messages)
    subject = "You are accepted to participate in FedCampus"
    ##########################################
    if args.email:
        send = True if args.email == "send" else False
        sendmail(
            messages,
            netid,
            subject,
            test=not send,
        )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--email", default="test")
    args = parser.parse_args()
    main(args)
    pass
