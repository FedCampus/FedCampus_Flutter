import requests

endpoint = "http://localhost/backend/visualization"
response = requests.get(endpoint)
print(response.content)
datatypes = []
for item in response:
    if item["dataType"] not in datatypes:
        datatypes.append(item["dataType"])

print(datatypes)