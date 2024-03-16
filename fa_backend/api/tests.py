import math
import json
from django.urls import reverse
from django.contrib.auth.models import User
from django.core.files.uploadedfile import SimpleUploadedFile
from rest_framework import status
from rest_framework.test import APITestCase, APIRequestFactory, force_authenticate
from rest_framework.authtoken.models import Token

from .models import Customer, Record, RecordDP, Log
from .views import (
    FA_MODEL,
    Login,
    Register,
    Data,
    DataDP,
    Logout,
    saveLogFile,
    Status,
    Average,
    Rank,
)


class UserTestCase(APITestCase):
    """TestCase where a User and its respective Customer need to be created."""

    def setUpUser(self):
        self.user_data = {
            "username": "test@duke.edu",
            "password": "password",
        }
        self.user = User.objects.create_user(
            username=self.user_data["username"],
            password=self.user_data["password"],
            email=self.user_data["username"],
        )
        netid = "ts123"
        self.customer = Customer.objects.create(
            user=self.user, nickname=netid, netid=netid
        )


class LoginTestCase(UserTestCase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.view = Login.as_view()
        self.uri = "/login/"
        self.setUpUser()

    def test_valid(self):
        request = self.factory.post(self.uri, self.user_data, format="json")
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.assertEqual(response.data["nickname"], self.user.customer.nickname)
        self.assertEqual(response.data["email"], self.user.email)
        self.assertEqual(
            response.data["auth_token"],
            Token.objects.get_or_create(user=self.user)[0].key,
        )

    def test_wrong_password(self):
        invalid_data = {
            "username": "test@duke.edu",
            "password": "badpassword",
        }
        request = self.factory.post(self.uri, invalid_data, format="json")
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(
            str(response.data["non_field_errors"][0]),
            "Unable to log in with provided credentials.",
        )

    def test_missing_field(self):
        del self.user_data["password"]
        request = self.factory.post(self.uri, self.user_data, format="json")
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(str(response.data["password"][0]), "This field is required.")

    def test_inactive_user(self):
        self.user.is_active = False
        self.user.save()
        request = self.factory.post(self.uri, self.user_data, format="json")
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(
            str(response.data["non_field_errors"][0]),
            "Unable to log in with provided credentials.",
        )


class RegisterTestCase(APITestCase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.view = Register.as_view()
        self.uri = "/register/"
        self.user_data = {
            "email": "test@duke.edu",
            "password": "password",
            "netid": "ts123",
        }

    def test_valid(self):
        request = self.factory.post(self.uri, self.user_data, format="json")
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        user = User.objects.get(username=self.user_data["email"])
        token = Token.objects.get(user=user)
        self.assertEqual(response.data["auth_token"], token.key)

    def test_missing_field(self):
        del self.user_data["email"]
        request = self.factory.post(self.uri, self.user_data, format="json")
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(str(response.data["email"][0]), "This field is required.")

    def test_user_already_exists_correct_password(self):
        User.objects.create_user(
            username=self.user_data["email"],
            password=self.user_data["password"],
            email=self.user_data["email"],
        )
        request = self.factory.post(self.uri, self.user_data, format="json")
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(str(response.data["error"][0]), "user already exists")

    def test_user_already_exists_incorrect_password(self):
        User.objects.create_user(
            username=self.user_data["email"],
            password="badpassword",
            email=self.user_data["email"],
        )
        request = self.factory.post(self.uri, self.user_data, format="json")
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(str(response.data["error"][0]), "user already exists")


class DataTestCaseBase(UserTestCase):
    "Base TestCase that contains all tests shared by Data and DataDP."

    def create_sleep_time_valid(self):
        old_record = self.Model.objects.create(
            user=self.user,
            startTime=0,
            endTime=1,
            dataType="sleep_time",
            value=887.0,
        )

        data = {
            "version": "1.0",
            "data": json.dumps(
                [
                    {
                        "startTime": 1,
                        "endTime": 2,
                        "name": "sleep_time",
                        "value": 888.0,
                    },
                ]
            ),
        }
        request = self.factory.post(self.uri, data, format="json")
        force_authenticate(request, user=self.user)
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.customer.refresh_from_db()
        self.assertEqual(self.customer.version, data["version"])

        self.assertTrue(self.Model.objects.filter(id=old_record.id).exists())
        record = self.Model.objects.get(
            user=self.user, dataType="sleep_time", startTime=1
        )
        self.assertEqual(record.value, 888.0)

    def update_sleep_time_valid(self):
        self.Model.objects.create(
            user=self.user,
            startTime=0,
            endTime=1,
            dataType="sleep_time",
            value=887.0,
        )

        data = {
            "version": "1.0",
            "data": json.dumps(
                [
                    {
                        "startTime": 0,
                        "endTime": 1,
                        "name": "sleep_time",
                        "value": 888.0,
                    },
                ]
            ),
        }
        request = self.factory.post(self.uri, data, format="json")
        force_authenticate(request, user=self.user)
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.customer.refresh_from_db()
        self.assertEqual(self.customer.version, data["version"])

        record = self.Model.objects.get(
            user=self.user, dataType="sleep_time", startTime=0
        )
        self.assertEqual(record.value, 888.0)

    def create_sleep_time_invalid(self):
        data = {
            "version": "1.0",
            "data": json.dumps(
                [
                    {
                        "startTime": 1,
                        "endTime": 2,
                        "name": "sleep_time",
                        "value": 120.0,
                    },
                ]
            ),
        }
        request = self.factory.post(self.uri, data, format="json")
        force_authenticate(request, user=self.user)
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.customer.refresh_from_db()
        self.assertEqual(self.customer.version, data["version"])

        self.assertFalse(
            self.Model.objects.filter(user=self.user, dataType="sleep_time").exists()
        )

    def create_sleep_duration_greater_than_1200(self):
        data = {
            "version": "1.0",
            "data": json.dumps(
                [
                    {
                        "startTime": 1,
                        "endTime": 2,
                        "name": "sleep_duration",
                        "value": 12019999.0,
                    },
                ]
            ),
        }
        request = self.factory.post(self.uri, data, format="json")
        force_authenticate(request, user=self.user)
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.customer.refresh_from_db()
        self.assertEqual(self.customer.version, data["version"])

        record = self.Model.objects.get(user=self.user, dataType="sleep_duration")
        self.assertEqual(record.value, 1.0)

    def create_sleep_duration_less_than_or_equal_to_1200(self):
        data = {
            "version": "1.0",
            "data": json.dumps(
                [
                    {
                        "startTime": 1,
                        "endTime": 2,
                        "name": "sleep_duration",
                        "value": 12009999.0,
                    },
                ]
            ),
        }
        request = self.factory.post(self.uri, data, format="json")
        force_authenticate(request, user=self.user)
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.customer.refresh_from_db()
        self.assertEqual(self.customer.version, data["version"])

        record = self.Model.objects.get(user=self.user, dataType="sleep_duration")
        self.assertEqual(record.value, 1440.0)


class DataTestCase(DataTestCaseBase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.setUpUser()
        self.view = Data.as_view()
        self.uri = "/data/"
        self.Model = Record

    def test_create_sleep_time_valid(self):
        self.create_sleep_time_valid()

    def test_update_sleep_time_valid(self):
        self.update_sleep_time_valid()

    def test_create_sleep_time_invalid(self):
        self.create_sleep_time_invalid()

    def test_create_sleep_duration_greater_than_1200(self):
        self.create_sleep_duration_greater_than_1200()

    def test_create_sleep_duration_less_than_or_equal_to_1200(self):
        self.create_sleep_duration_less_than_or_equal_to_1200()


class DataDPTestCase(DataTestCaseBase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.setUpUser()
        self.view = DataDP.as_view()
        self.uri = "/data_dp/"
        self.Model = RecordDP

    def test_create_sleep_time_valid(self):
        self.create_sleep_time_valid()

    def test_update_sleep_time_valid(self):
        self.update_sleep_time_valid()

    def test_create_sleep_time_invalid(self):
        self.create_sleep_time_invalid()

    def test_create_sleep_duration_greater_than_1200(self):
        self.create_sleep_duration_greater_than_1200()

    def test_create_sleep_duration_less_than_or_equal_to_1200(self):
        self.create_sleep_duration_less_than_or_equal_to_1200()


class LogoutTestCase(UserTestCase):
    def setUp(self):
        self.view = Logout.as_view()
        self.uri = reverse("api:logout")
        self.setUpUser()

    def test_logout(self):
        self.client.login(**self.user_data)
        response = self.client.get(self.uri)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.assertNotIn("_auth_user_id", self.client.session)


class SaveLogFileTestCase(UserTestCase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.view = saveLogFile.as_view()
        self.uri = "/log/"
        self.setUpUser()

    def test_save_log_file(self):
        file_content = b"Test log content"
        file = SimpleUploadedFile("test_log.txt", file_content)
        data = {"log": file}
        request = self.factory.post(self.uri, data, format="multipart")
        force_authenticate(request, user=self.user)
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.assertTrue(Log.objects.filter(user=self.user).exists())


class StatusTestCase(UserTestCase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.view = Status.as_view()
        self.uri = "/status/"
        self.setUpUser()

    def test_status(self):
        request = self.factory.get(self.uri)
        force_authenticate(request, user=self.user)
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.assertIn("faculty", response.data)
        self.assertIn("student", response.data)
        self.assertIn("male", response.data)


class AverageTestCase(UserTestCase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.view = Average.as_view()
        self.uri = "/average/"
        self.setUpUser()

        alice = User.objects.create_user(
            username="alice", password="password", email="test@duke.edu"
        )
        Customer.objects.create(
            user=alice, nickname="a123", netid="a123", male=False, faculty=True
        )
        FA_MODEL.objects.create(
            user=alice, startTime=0, endTime=1, dataType="distance", value=-1
        )
        FA_MODEL.objects.create(
            user=alice, startTime=0, endTime=1, dataType="distance", value=0
        )
        FA_MODEL.objects.create(
            user=alice, startTime=0, endTime=1, dataType="sleep_time", value=119
        )
        FA_MODEL.objects.create(
            user=alice, startTime=0, endTime=1, dataType="sleep_time", value=120
        )
        FA_MODEL.objects.create(
            user=alice, startTime=0, endTime=1, dataType="sleep_duration", value=241
        )
        FA_MODEL.objects.create(
            user=alice, startTime=1, endTime=2, dataType="sleep_time", value=888
        )
        FA_MODEL.objects.create(
            user=alice, startTime=1, endTime=2, dataType="sleep_duration", value=888
        )

        bob = User.objects.create_user(
            username="bob", password="password", email="test@duke.edu"
        )
        Customer.objects.create(
            user=bob, nickname="b123", netid="b123", male=True, faculty=False, student=0
        )
        FA_MODEL.objects.create(
            user=bob, startTime=0, endTime=1, dataType="sleep_time", value=240
        )
        FA_MODEL.objects.create(
            user=bob, startTime=0, endTime=1, dataType="sleep_duration", value=1
        )

        eve = User.objects.create_user(
            username="eve", password="password", email="test@duke.edu"
        )
        Customer.objects.create(
            user=eve,
            nickname="e123",
            netid="e123",
            male=False,
            faculty=False,
            student=1,
        )
        FA_MODEL.objects.create(
            user=eve, startTime=0, endTime=1, dataType="sleep_time", value=300
        )
        FA_MODEL.objects.create(
            user=eve, startTime=0, endTime=1, dataType="sleep_duration", value=1440
        )

    def test_time_0_all(self):
        data = {"time": 0, "filter": {"status": "all"}}
        request = self.factory.post(self.uri, data, format="json")
        force_authenticate(request, user=self.user)
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.assertAlmostEqual(response.data["distance"], 0.0)
        self.assertAlmostEqual(response.data["sleep_time"], 220.0)
        self.assertAlmostEqual(response.data["sleep_duration"], 320.66666666666663)

    def test_time_1_all(self):
        data = {"time": 1, "filter": {"status": "all"}}
        request = self.factory.post(self.uri, data, format="json")
        force_authenticate(request, user=self.user)
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.assertAlmostEqual(response.data["sleep_time"], 888.0)
        self.assertAlmostEqual(response.data["sleep_duration"], 648.0)

    def test_male_student(self):
        data = {"time": 0, "filter": {"gender": "male", "status": "student"}}
        request = self.factory.post(self.uri, data, format="json")
        force_authenticate(request, user=self.user)
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.assertAlmostEqual(response.data["sleep_time"], 240.0)
        self.assertAlmostEqual(response.data["sleep_duration"], 1201.0)

    def test_female_faculty(self):
        data = {"time": 0, "filter": {"gender": "female", "status": "faculty"}}
        request = self.factory.post(self.uri, data, format="json")
        force_authenticate(request, user=self.user)
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.assertAlmostEqual(response.data["distance"], 0.0)
        self.assertAlmostEqual(response.data["sleep_time"], 120.0)
        self.assertAlmostEqual(response.data["sleep_duration"], 1.0)

    def test_all_student_1(self):
        data = {"time": 0, "filter": {"status": "1"}}
        request = self.factory.post(self.uri, data, format="json")
        force_authenticate(request, user=self.user)
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.assertAlmostEqual(response.data["sleep_time"], 300.0)
        self.assertAlmostEqual(response.data["sleep_duration"], 1200.0)


class RankTestCase(APITestCase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.view = Rank.as_view()
        self.uri = "/rank/"

        self.user_num = 25
        self.users = []
        for i in range(self.user_num):
            self.users.append(
                User.objects.create_user(
                    username=str(i), password="password", email="test@duke.edu"
                )
            )
            Customer.objects.create(user=self.users[-1], nickname=str(i), netid=str(i))

            FA_MODEL.objects.create(
                user=self.users[-1],
                startTime=0,
                endTime=1,
                dataType="distance",
                value=i + 1,
            )
            FA_MODEL.objects.create(
                user=self.users[-1],
                startTime=0,
                endTime=1,
                dataType="sleep_duration",
                value=i + 1,
            )

    def test_distance(self):
        data = {"time": 0, "filter": {"status": "all"}}

        for i, user in enumerate(self.users):
            request = self.factory.post(self.uri, data, format="json")
            force_authenticate(request, user=user)
            response = self.view(request)
            self.assertEqual(response.status_code, status.HTTP_200_OK)

            self.assertEqual(
                response.data["distance"],
                math.ceil((self.user_num - i) / self.user_num / 0.05) * 5,
            )

    def test_sleep_duration(self):
        data = {"time": 0, "filter": {"status": "all"}}

        for i, user in enumerate(self.users):
            request = self.factory.post(self.uri, data, format="json")
            force_authenticate(request, user=user)
            response = self.view(request)
            self.assertEqual(response.status_code, status.HTTP_200_OK)

            self.assertEqual(
                response.data["sleep_duration"],
                math.ceil((i + 1) / self.user_num / 0.05) * 5,
            )
