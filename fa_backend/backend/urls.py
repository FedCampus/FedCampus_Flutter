from django.urls import path
from . import views

app_name = "backend"

urlpatterns = [
    path("active/<int:startTime>/<int:endTime>", views.getActive, name="status")
]
