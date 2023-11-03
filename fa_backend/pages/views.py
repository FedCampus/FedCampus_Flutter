import json
from django.http import HttpResponse
from django.shortcuts import render
from django.template import loader
from django.core import serializers
from api.models import Customer

# Create your views here.


def pages(request):
    template = loader.get_template("backend_vis.html")
    customers = Customer.objects.all()
    queryset_data = serializers.serialize('python', customers)
    queryset_list = [item['fields'] for item in queryset_data]
    context = {
        "customers": json.dumps(queryset_list),
    }
    return HttpResponse(template.render(context, request))
