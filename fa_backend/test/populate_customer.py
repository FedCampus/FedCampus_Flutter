import random
from api.models import Customer
from api.serializers import RegisterSerializer

for i in range(1, 21):
    serializer = RegisterSerializer(
        data={"email": f"user{i}@host.com", "password": "testtest", "netid": f"ab{i}"}
    )
    serializer.is_valid(raise_exception=True)
    customer = Customer.objects.all().filter(netid=f"ab{i}")[0]
    print(customer)
    customer.male = random.choice([True, False])
    is_faculty = True if random.random() > 0.9 else False
    customer.faculty = is_faculty
    if not is_faculty:
        customer.student = random.choice([2024, 2025, 2026, 2027])
    customer.save()
