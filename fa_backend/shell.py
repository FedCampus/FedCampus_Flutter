from api.models import *

query = RecordDP.objects.all()

for i in query:
    i.value = i.data.get("value")
    i.save()
