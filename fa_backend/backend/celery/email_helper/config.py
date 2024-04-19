from datetime import timedelta
from celery.schedules import crontab

BROKER_URL = 'redis://localhost:6379/1'
CELERY_RESULT_BACKEND = 'redis://localhost:6379/2'

CELERY_TIMEZONE = 'Asia/Shanghai'

CELERY_TASK_SERIALIZER='json'
CELERY_RESULT_SERIALIZER='json'

#Setting up the timed tasks
CELERYBEAT_SCHEDULE = {
    'loginAlert1':{
        'task':'email_helper.loginAlert.loginAlert',
        'schedule': crontab(hour=17, minute=30)
    },
    'loginAlert2':{
        'task':'email_helper.loginAlert.loginAlert',
        'schedule': crontab(hour=22, minute=30)
    },
    'creditAlert':{
        'task':'email_helper.creditAlert.creditAlert',
        'schedule': timedelta(seconds=60),
        #'args': ('50000')
    },
}