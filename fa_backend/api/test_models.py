from django.test import TestCase
from django.contrib.auth.models import User
from .models import Record, RecordDP, Customer, Log, SleepTime, saveRecord
from django.utils import timezone
from django.core.files.uploadedfile import SimpleUploadedFile

class ModelCreationTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user('TestGuy', 'TG123@dkue.edu', 'password')
        
    def test_record_creation(self):
        record = Record.objects.create(user=self.user, startTime=123456789, endTime=123456999, dataType="testType", value=1.23)
        self.assertEqual(str(record), "123456789 testType TestGuy")

    def test_record_dp_creation(self):
        record_dp = RecordDP.objects.create(user=self.user, startTime=123456789, endTime=123456999, dataType="testTypeDP", value=1.23)
        self.assertEqual(str(record_dp), "12345678 testTypeDP TestGuy")

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
        data = {"name": "sleep_duration", "value": 12100000, "startTime": 3000, "endTime": 3100} # 1210 as start time in minutes
        saveRecord(Record, self.user, data)
        record = Record.objects.first()
        self.assertIsNotNone(record)
        expected_value = 10 
        self.assertEqual(record.value, expected_value)

class CustomerLogModelTest(TestCase):

    def setUp(self):
        self.user = User.objects.create_user(username='TestGuy', password='password')
        self.customer = Customer.objects.create(
            user=self.user,
            nickname='TestNickname',
            netid='TestNetID',
            faculty=True,
            student=1,
            male=True,
            version='1.0',
            credit=5
        )
        
        dummy_file = SimpleUploadedFile("file.txt", b"file_content")
        self.log = Log.objects.create(
            user=self.user,
            file=dummy_file
        )

    def test_customer_creation(self):
        self.assertEqual(self.customer.user.username, 'TestGuy')
        self.assertEqual(self.customer.nickname, 'TestNickname')
        self.assertEqual(self.customer.netid, 'TestNetID')
        self.assertTrue(self.customer.faculty)
        self.assertEqual(self.customer.student, 1)
        self.assertTrue(self.customer.male)
        self.assertEqual(self.customer.version, '1.0')
        self.assertEqual(self.customer.credit, 5)

    def test_customer_str(self):
        self.assertEqual(self.customer.__str__(), 'TestNickname')

    def test_log_creation(self):
        self.assertEqual(self.log.user.username, 'TestGuy')
        self.assertTrue(self.log.file.name.startswith('logs/TestGuy-'))

    def test_log_str(self):
        self.assertIn('TestGuy', self.log.__str__())
        self.assertIn(timezone.localtime(self.log.time).strftime('%Y-%m-%d %H:%M:%S'), self.log.__str__())

