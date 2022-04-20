FROM ubuntu:focal as app

# System requirements.
RUN apt-get update && apt-get upgrade -qy
RUN apt-get install -qy \
	git-core \
	language-pack-en \
	python3.8 \
	python3-pip \
	python3.8-dev \
	libmysqlclient-dev \
	libssl-dev
RUN pip3 install --upgrade pip setuptools
# delete apt package lists because we do not need them inflating our image
RUN rm -rf /var/lib/apt/lists/*

# Python is Python3.
ENV VIRTUAL_ENV=/edx/app/registrar/venvs/registrar
RUN python3.8 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Use UTF-8.
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


ENV DJANGO_SETTINGS_MODULE registrar.settings.production

RUN mkdir -p /edx/app/registrar

# Expose ports.
EXPOSE 18734
EXPOSE 18735

RUN useradd -m --shell /bin/false app

# Working directory will be root of repo.
WORKDIR /edx/app/registrar

# Copy just Python requirements & install them.
COPY requirements/ /edx/app/registrar/requirements/
RUN pip install -r requirements/pip.txt
RUN pip install -r requirements/production.txt

USER app

# Gunicorn 19 does not log to stdout or stderr by default. Once we are past gunicorn 19, the logging to STDOUT need not be specified.
CMD ["gunicorn", "--workers=2", "--name", "registrar", "-c", "/edx/app/registrar/registrar/docker_gunicorn_configuration.py", "--log-file", "-", "--max-requests=1000", "registrar.wsgi:application"]

# After the requirements so changes to the code will not bust the image cache
COPY . /edx/app/registrar
