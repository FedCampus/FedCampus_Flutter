from .models import Record
from .models import SleepTime
from .models import Customer
from .models import RecordDP
from .models import Log

from django.contrib import admin


# Register your models here.

admin.site.register(Record)
admin.site.register(RecordDP)
admin.site.register(SleepTime)
admin.site.register(Customer)
admin.site.register(Log)
