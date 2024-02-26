import json

from django.urls import reverse
from django.contrib.auth.models import User
from django.core.files.uploadedfile import SimpleUploadedFile
from rest_framework import status
from rest_framework.test import APITestCase, APIRequestFactory, force_authenticate
from rest_framework.authtoken.models import Token

from .models import Customer, Record, RecordDP, Log
from .views import Login, Register, Data, DataDP, Logout, saveLogFile, Status


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
