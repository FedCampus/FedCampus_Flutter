from django.test import TestCase
from django.contrib.auth.models import User
from .models import Record, RecordDP, Customer, Log, SleepTime
from django.utils import timezone

class ModelCreationTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user('TestGuy', 'TG123@dkue.edu', 'password')
        
    def test_record_creation(self):
        record = Record.objects.create(user=self.user, startTime=123456789, endTime=123456999, dataType="testType", value=1.23)
        self.assertEqual(str(record), "123456789 testType john")

    def test_record_dp_creation(self):
        record_dp = RecordDP.objects.create(user=self.user, startTime=123456789, endTime=123456999, dataType="testTypeDP", value=1.23)
        self.assertEqual(str(record_dp), "12345678 testTypeDP john")

class SaveRecordTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user('TestGuy', 'TG123@dkue.edu', 'password')

    def test_negative_value(self):
        data = {"name": "test_negative", "value": -1, "startTime": 1000, "endTime": 1100}
        saveRecord(Record, self.user, data)
        self.assertEqual(Record.objects.count(), 0)

    def test_sleep_time_abnormal(self):
        data = {"name": "sleep_time", "value": 100, "startTime": 2000, "endTime": 2100} # 100 minutes, less than 2 hours
        saveRecord(Record, self.user, data)
        self.assertEqual(Record.objects.count(), 0)

    def test_sleep_duration_conversion(self):
        data = {"name": "sleep_duration", "value": 121000, "startTime": 3000, "endTime": 3100} # 1210 as start time in minutes
        saveRecord(Record, self.user, data)
        record = Record.objects.first()
        self.assertIsNotNone(record)
        expected_value = 10 # Calculated based on your conversion logic
        self.assertEqual(record.value, expected_value)

