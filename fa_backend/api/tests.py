from django.test import TestCase
from .serializers import RegisterSerializer


class DummyTestCase(TestCase):
    def setUp(self):
        pass

    def test_dummy(self):
        self.assertEqual("Dummy Test", "Dummy Test")


class CustomerTestCase(TestCase):
    def setUp(self):
        pass

    def test_customer_serializer_01(self):
        serializer = RegisterSerializer(
            data={
                "email": "lw337@duke.edu",
                "password": "testpasswd",
                "netid": "lw337",
            }
        )
        self.assertEqual(serializer.is_valid(), True)
