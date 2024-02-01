from django.urls import path
from . import views

app_name = "backend"

urlpatterns = [
    path(
        "active/<int:startTime>/<int:endTime>",
        views.getActive,
        name="status",
    ),
    path("active/recents", views.getRecentInactive, name="inactive_status"),
    path("home", views.mainPage, name="backend_mainpage"),
    path("credit", views.CreditManagementView.as_view(), name="credit_management")
]
