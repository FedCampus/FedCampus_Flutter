from django.urls import path
from . import views

app_name = "api"


urlpatterns = [
    path("login", views.Login.as_view(), name="login"),
    path("register", views.Register.as_view(), name="register"),
    path("data", views.Data.as_view(), name="exercisedata"),
    path("data_dp", views.DataDP.as_view(), name="exercisedata_dp"),
    path("logout", views.Logout.as_view(), name="logout"),
    path("log", views.saveLogFile.as_view(), name="saveLogFile"),
    path("account", views.AccountSettings.as_view(), name="account"),
    path("status", views.Status.as_view(), name="status"),
    path("avg", views.Average.as_view(), name="average"),
    path("rank", views.Rank.as_view(), name="rank"),
    path("dp_datapoints", views.DPDataPoints.as_view(), name="dp_datapoints"),
    path("version_check", views.VersionCheck.as_view(), name="version_check"),
]
