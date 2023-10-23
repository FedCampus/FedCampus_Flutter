from django.urls import path
from . import views

app_name = "api"


urlpatterns = [
    path("login", views.Login.as_view(), name="login"),
    path("register", views.Register.as_view(), name="register"),
    path("data", views.Data.as_view(), name="exercisedata"),
    path("data_dp", views.DataDP.as_view(), name="exercisedata_dp"),
    path("health_data", views.HealthData.as_view(), name="healthdata"),
    path("test", views.TestView.as_view(), name="test"),
    path("logout", views.Logout.as_view(), name="logout"),
    path("account", views.Account.as_view(), name="account"),
    path("fedanalysis", views.FedAnalysis.as_view(), name="fedanalysis"),
    path("log", views.saveLogFile.as_view(), name="saveLogFile"),
    path("account", views.AccountSettings.as_view(), name="account"),
    path("status", views.Status.as_view(), name="status"),
]
