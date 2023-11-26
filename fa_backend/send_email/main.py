import pandas as pd
import os
from django.core.mail import send_mass_mail

base_path = os.path.join(os.getcwd(), "send_email")


def sendmail(
    content, netid, subject, from_email="fedcampus@dukekunshan.edu.cn", test=False
):
    if test:
        # netid = ["bt132", "sh623", "qz150", "lw337", "bz106", "bl291"]
        netid = ["bt132"]
        content = content[3:4]
    assert len(content) == len(netid)
    send_mass_mail(
        ((subject, c, from_email, [n + "@duke.edu"]) for c, n in zip(content, netid))
    )
    pass


def main():
    f = open(os.path.join(base_path, "box.txt"), "r").read()
    p = pd.read_excel(os.path.join(base_path, "FecCampus Watches.xlsx"))
    p = p[p["Watch Serial Number"].notnull()]
    name = p["name"]
    serial = p["Watch Serial Number"]
    netid = p["NetID"]
    messages = [f % (n, s) for n, s in zip(name, serial)]
    sendmail(
        messages, netid, "Congratulations of being a Fedcampus Test users!", test=False
    )


if __name__ == "__main__":
    main()
    pass
