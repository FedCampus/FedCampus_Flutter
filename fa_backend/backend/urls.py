from django.urls import path
from . import views

app_name = "backend"

urlpatterns = [
    path(
        "active/<int:startTime>/<int:endTime>",
        views.getActive,
        name="status",
    ),
    path("active/recents", views.getRecentActive, name="inactive_status"),
    path("home", views.mainPage, name="backend_mainpage"),
    path("credit", views.CreditManagementView.as_view(), name="credit_management"),
    path(
        "credit/<str:netid>",
        views.CreditManagementView.as_view(),
        name="credit_management",
    ),
    path(
        "credit/<str:netid>/update",
        views.CreditManagementView.as_view(),
        name="credit_management",
    ),
    path("visualization", views.VisualizationView.as_view(), name="visualization")
]
