import os
import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "fedapp.settings")
django.setup()

## test the
from api.models import *
from django.contrib.auth.models import User

u = User.objects.all()[0]
print(u)
c = Customer.objects.get(user=u)
print(c)

r = Record.objects.filter(startTime=20231212).filter(dataType="sleep_duration")
