from django.conf import settings



def append_slash(complete_url: str) -> str:
    if settings.APPEND_SLASH and not complete_url.endswith('/'):
        complete_url = complete_url + '/'  # Required for consistency
    return complete_url