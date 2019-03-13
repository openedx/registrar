# -*- coding: utf-8 -*-
# Generated by Django 1.11.18 on 2019-03-14 14:20
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0003_pendingorganizationuserrole'),
        ('guardian', '0001_initial'),
        ('waffle', '0003_update_strings_for_i18n'),
        ('enrollments', '0004_prepare_remove_organization'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='organizationgroup',
            name='group_ptr',
        ),
        migrations.RemoveField(
            model_name='organizationgroup',
            name='organization',
        ),
        migrations.DeleteModel(
            name='Organization',
        ),
        migrations.DeleteModel(
            name='OrganizationGroup',
        ),
    ]
