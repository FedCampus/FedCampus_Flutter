import logging

from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from django.utils.translation import gettext_lazy as _
from django.db.utils import IntegrityError

from rest_framework import serializers
from rest_framework.authtoken.models import Token

from .models import Customer

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class CustomerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Customer
        fields = ["faculty", "student", "male"]


class LoginSerializer(serializers.Serializer):
    username = serializers.CharField(label=_("Username"), write_only=True)
    password = serializers.CharField(
        label=_("Password"),
        style={"input_type": "password"},
        trim_whitespace=False,
        write_only=True,
    )
    token = serializers.CharField(label=_("Token"), read_only=True)

    def validate(self, attrs):
        username = attrs.get("username")
        password = attrs.get("password")

        if username and password:
            user = authenticate(
                request=self.context.get("request"),
                username=username,
                password=password,
            )

            # The authenticate call simply returns None for is_active=False
            # users. (Assuming the default ModelBackend authentication
            # backend.)
            if not user:
                msg = _("Unable to log in with provided credentials.")
                raise serializers.ValidationError(msg, code="authorization")
        else:
            msg = _('Must include "username" and "password".')
            raise serializers.ValidationError(msg, code="authorization")

        token = Token.objects.get_or_create(user=user)
        attrs["auth_token"] = token[0].key
        attrs["user"] = user
        return attrs


class RegisterSerializer(serializers.Serializer):
    email = serializers.CharField(label="email")
    password = serializers.CharField(label="password")
    netid = serializers.CharField(label="netid")

    def validate(self, data):
        email = data.get("email")
        password = data.get("password")
        netid = data.get("netid")

        if email is None or password is None or netid is None:
            raise serializers.ValidationError({"error": "missing field"})

        user = authenticate(username=email, password=password)
        if user is None:
            # create a new user
            try:
                user = User.objects.create_user(
                    username=email, password=password, email=email
                )
            except IntegrityError:
                raise serializers.ValidationError({"error": "user already exists"})

            Customer.objects.create(user=user, nickname=netid, netid=netid)
            token = Token.objects.get_or_create(user=user)
            data["auth_token"] = token[0].key
            return data
        else:
            raise serializers.ValidationError({"error": "user already exists!"})

        pass
