"""
Defines the Celery application for the registrar project.
"""

from celery import Celery


app = Celery('registrar')

app.conf.task_protocol = 1
app.config_from_object('django.conf:settings', namespace="CELERY")
app.autodiscover_tasks()


if __name__ == '__main__':
    app.start()
