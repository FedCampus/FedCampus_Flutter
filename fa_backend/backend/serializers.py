from rest_framework import serializers
from api.models import Customer, RecordDP


class CreditSerializer(serializers.ModelSerializer):
    class Meta:
        model = Customer
        fields = ["netid", "credit"]

class VisualizationSerializer(serializers.ModelSerializer):
    class Meta:
        model = RecordDP
        fields = ["user", "startTime", "endTime", "dataType", "value"]