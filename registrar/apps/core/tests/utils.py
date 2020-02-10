""" General utilities for unit tests. """

import json
from functools import wraps

import responses
from django.conf import settings
from mock import patch

from ..proxies import DiscoveryProgram


def mock_oauth_login(fn):
    """
    Mock request to authenticate registrar as a backend client
    """
    # pylint: disable=missing-docstring
    @wraps(fn)
    def inner(self, *args, **kwargs):
        responses.add(
            responses.POST,
            settings.LMS_BASE_URL + '/oauth2/access_token',
            body=json.dumps({'access_token': 'abcd', 'expires_in': 60}),
            status=200
        )
        return fn(self, *args, **kwargs)
    return inner


def patch_discovery_data(disco_program_data):
    """
    Return a decorator that mocks the return value of DiscoveryProgram.discovery_data.
    """
    return patch.object(
        DiscoveryProgram,
        'get_program_data',
        lambda *_, **__: disco_program_data,
    )
