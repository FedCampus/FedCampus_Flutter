# Generated by Django 4.1.7 on 2023-07-26 07:28

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("api", "0010_record_value"),
    ]

    operations = [
        migrations.AddField(
            model_name="recorddp",
            name="value",
            field=models.FloatField(blank=True, null=True),
        ),
    ]
