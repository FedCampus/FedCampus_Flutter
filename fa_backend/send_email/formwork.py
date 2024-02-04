import pandas as pd
import os
import argparse
import sys
from django.core.mail import send_mass_mail

# Ensure the Django settings are configured
sys.path.append(os.path.dirname(os.getcwd()))
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "fedapp.settings")


def filter_users(excel_file, grade_exclusion, status_required):
    """
    Filters users from the Excel file based on the specified criteria.

    Args:
    - excel_file: The path to the Excel file.
    - grade_exclusion: A grade to exclude from the selection.
    - status_required: Required status for the users.

    Returns:
    - A filtered DataFrame with users meeting the criteria.
    """
    df = pd.read_excel(excel_file, sheet_name="waitlist")
    df_filtered = df  # to be modified
    return df_filtered


def sendmail(
    content, netid, subject, from_email="fedcampus@dukekunshan.edu.cn", test=False
):
    """
    Sends an email to each user in the netid list with their corresponding content.

    Args:
    - content: A list of message contents for each user.
    - netid: A list of user netids.
    - subject: The subject of the email.
    - from_email: The email address sending the emails.
    - test: If True, prints the emails instead of sending them.
    """
    if test:
        print("testing")
        netid = test
        content = content[: len(netid)]
    assert len(content) == len(netid), "The length of content and netid must match."
    send_mass_mail(
        ((subject, c, from_email, [n + "@duke.edu"]) for c, n in zip(content, netid))
    )


def main(args):
    # Read the waitlist text content
    with open(args.text_file, "r") as file:
        waitlist_content = file.read()

    # Filter users based on criteria
    users_df = filter_users(
        args.excel_file, grade_exclusion=2024, status_required="student"
    )
    messages = [waitlist_content % s for s in users_df["Name"]]
    netids = users_df["NetID"]

    assert len(netids) == len(messages), "The number of messages and netids must match."
    subject = ""

    # Send emails
    if args.email_action:
        send = True if args.email_action == "send" else False
        sendmail(messages, netids, subject, test=not send)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Send emails to filtered users from an Excel file."
    )
    parser.add_argument(
        "--excel_file", required=True, help="The path to the Excel file."
    )
    parser.add_argument(
        "--text_file",
        required=True,
        help="The path to the text file with the email content.",
    )
    parser.add_argument(
        "--email_action",
        choices=["test", "send"],
        default="test",
        help="Whether to test or send emails.",
    )
    args = parser.parse_args()
    main(args)
