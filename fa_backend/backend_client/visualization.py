import requests

endpoint = "http://10.201.8.29:8085/backend/visualization"
headers = {'content-type': 'application/json'}
response = requests.get(endpoint, headers=headers)
print(response.content)
datatypes = []
for item in response:
    if item["dataType"] not in datatypes:
        datatypes.append(item["dataType"])

print(datatypes)