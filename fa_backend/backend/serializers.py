from rest_framework import serializers
from api.models import Customer


class CreditSerializer(serializers.ModelSerializer):
    class Meta:
        model = Customer
        fields = ["netid", "credit"]
