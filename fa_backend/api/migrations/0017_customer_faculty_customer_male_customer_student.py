# Generated by Django 4.2.3 on 2023-10-20 05:17

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("api", "0016_record_update_recorddp_update_alter_log_file"),
    ]

    operations = [
        migrations.AddField(
            model_name="customer",
            name="faculty",
            field=models.BooleanField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name="customer",
            name="male",
            field=models.BooleanField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name="customer",
            name="student",
            field=models.SmallIntegerField(blank=True, null=True),
        ),
    ]
