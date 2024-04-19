from celery import Celery

app = Celery(
    'email_helper',
    include=[
        'email_helper.creditAlert',
        'email_helper.loginAlert',
    ]
)

app.config_from_object(
    'email_helper.config'
)