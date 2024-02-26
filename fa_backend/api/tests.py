from django.contrib.auth.models import User
from rest_framework import status
from rest_framework.test import APITestCase, APIRequestFactory
from rest_framework.authtoken.models import Token

from .models import Customer
from .views import Login, Register


class LoginTestCase(APITestCase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.view = Login.as_view()
        self.uri = "/login"
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
        Customer.objects.create(user=self.user, nickname=netid, netid=netid)

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
        self.uri = "/register"
        self.user_data = {
            "email": "test@duke.edu",
            "password": "password",
            "netid": "ts123",
        }
        pass

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
