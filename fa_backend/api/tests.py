from django.contrib.auth.models import User
from rest_framework import status
from rest_framework.test import APITestCase, APIRequestFactory
from rest_framework.authtoken.models import Token
from .views import Register


class RegisterTestCase(APITestCase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.view = Register.as_view()
        self.uri = "/register"
        self.user_data = {
            "email": "test@duke.edu",
            "password": "password",
            "netid": "ts123"
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
        del (self.user_data["email"])
        request = self.factory.post(self.uri, self.user_data, format="json")
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(
            str(response.data["email"][0]), "This field is required.")

    def test_user_already_exists_correct_password(self):
        User.objects.create_user(
            username=self.user_data["email"], password=self.user_data["password"], email=self.user_data["email"])
        request = self.factory.post(self.uri, self.user_data, format="json")
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(
            str(response.data["error"][0]), "user already exists")

    def test_user_already_exists_incorrect_password(self):
        User.objects.create_user(
            username=self.user_data["email"], password='badpassword', email=self.user_data["email"])
        request = self.factory.post(self.uri, self.user_data, format="json")
        response = self.view(request)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(str(response.data["error"][0]), "user already exists")
