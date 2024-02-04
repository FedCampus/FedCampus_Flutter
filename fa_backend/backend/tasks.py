import logging

from celery import shared_task


# Background tasks
@shared_task
def credit_management():
    return 1
