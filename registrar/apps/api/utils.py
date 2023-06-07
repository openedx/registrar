""" Miscellaneous utilities for API. """

from django.conf import settings
from django.urls import reverse

from registrar.helpers import append_slash

def build_absolute_api_url(url_name, **kwargs):
    """
    Build a path to a Registrar API endpoint, and then make it into an
    absolute, externally-accessible API URL.

    Convenience wrapper around to_absolute_api_url.

    Arguments:
        url_name (str): name of URL as configured in urls.py.
        kwargs (dict): URL kwargs for call to `reverse`.

    Returns: str
    """
    return to_absolute_api_url(append_slash(reverse(url_name, kwargs=kwargs)))


def to_absolute_api_url(path, *more_paths):
    """
    Make a path into an absolute, externally-accessible API URL.

    Attempts to gracefully handle missing/duplicate forward slashes,
    while preserving whether or not there is a trailing slash.

    Arguments:
        path (str): Path root. Must begin with /api/
        more_paths (list[str]): Paths to be appended to `path`, in order.

    Example:
        to_absolute_api_url('api/v1', 'programs', 'abcd/enrollments/')
            => 'https://{API_ROOT}/v1/programs/abcd/enrollments/'
        to_absolute_api_url('api/', '/v1/programs/', '/123')
            => 'https://{API_ROOT}/v1/programs/123'

    Returns: str
    """
    PREFIX = '/api/'
    if not path.startswith(PREFIX):
        raise ValueError(
            'Cannot make API URL for raw URL that does not begin with ' + PREFIX
        )
    path_parts = [settings.API_ROOT, path[len(PREFIX):]] + list(more_paths)
    stripped_path_parts = [part.strip('/') for part in path_parts]
    result = '/'.join(part for part in stripped_path_parts if part)
    return result + ('/' if str(path_parts[-1]).endswith('/') else '')
