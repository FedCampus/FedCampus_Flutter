from django.urls import path, include
from rest_framework.routers import DefaultRouter

from . import views

router = DefaultRouter()
# router.register('test', views.Test.as_view())

urlpatterns = [
    # path('', include(router.urls)),
    path("distance", views.Distance.as_view()),
    path("heartrate", views.HeartRate.as_view()),
    path("intenseexercise", views.IntenseExercise.as_view()),
    path("steps", views.Activity.as_view()),
]
