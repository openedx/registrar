.DEFAULT_GOAL := test
TOX=''

.PHONY: help clean static upgrade piptools requirements production-requirements \
        prod-requirements devstack-requirements local-requirements run-local \
        dbshell-local shell coverage test quality pii_check validate migrate \
        createsuperuser html_coverage extract_translations dummy_translations \
        fake_translations pull_translations push_translations \
        detect_changed_source_translations validate_translations api_generated \
        validate_api_committed

define BROWSER_PYSCRIPT
import os, webbrowser, sys
try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT
BROWSER := python -c "$$BROWSER_PYSCRIPT"

ifdef TOXENV
TOX := tox -- #to isolate each tox environment if TOXENV is defined
endif


# Generates a help message. Borrowed from https://github.com/pydanny/cookiecutter-djangopackage.
help: ## display this help message
	@echo "Please use \`make <target>\` where <target> is one of"
	@perl -nle'print $& if m{^[\.a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-25s\033[0m %s\n", $$1, $$2}'

clean: ## delete generated byte code and coverage reports
	find . -name '*.pyc' -delete
	find . -name '__pycache__' -type d -exec rm -rf {} ';' || true
	coverage erase
	rm -rf assets
	rm -rf pii_report

full_clean: clean ## clean byte code, reports, and uploaded media
	rm -rf registrar/media

static: ## generate static files
	$(TOX)python manage.py collectstatic --noinput

upgrade: piptools  ## re-compile requirements .txt files from .in files
	pip-compile --upgrade -o requirements/pip-tools.txt requirements/pip-tools.in
	pip-compile --upgrade -o requirements/production.txt requirements/production.in
	pip-compile --upgrade -o requirements/devstack.txt requirements/devstack.in
	pip-compile --upgrade -o requirements/local.txt requirements/local.in
	pip-compile --upgrade -o requirements/test.txt requirements/test.in
	pip-compile --upgrade -o requirements/monitoring/requirements.txt requirements/monitoring/requirements.in

	# Let tox control the Django version for tests
	grep -e "^django==" requirements/production.txt > requirements/django.txt
	sed '/^[dD]jango==/d' requirements/test.txt > requirements/test.tmp
	mv requirements/test.tmp requirements/test.txt

piptools:
	pip install -r requirements/pip-tools.txt

requirements: devstack-requirements ## alias to make devstack-requirements

production-requirements: piptools ## install requirements for production
	pip-sync -q requirements/production.txt

prod-requirements: production-requirements ## synonymous to 'production-requirements'

devstack-requirements: piptools ## install requirements for devstack development
	pip-sync requirements/devstack.txt

local-requirements: piptools ## install requirements for local development
	pip-sync -q requirements/local.txt

run-local: ## Run local (non-devstack) development server on port 8000
	python manage.py runserver 0.0.0.0:8000 --settings=registrar.settings.local

dbshell-local: ## Run local (non-devstack) database shell
	python manage.py dbshell --settings=registrar.settings.local

shell: ## Run Python shell with devstack settings
	python manage.py shell

coverage: clean
	$(TOX)pytest --cov-report html

test: clean ## run tests and generate coverage report
	$(TOX)pytest

quality: pycodestyle pylint yamllint isort_check ## run all code quality checks

pycodestyle:  # run pycodestyle
	$(TOX)pycodestyle registrar/ scripts/

pylint:  # run pylint
	$(TOX)pylint --rcfile=pylintrc registrar scripts

yamllint:  # run yamlint
	$(TOX)yamllint *.yaml

isort_check: ## check that isort has been run
	$(TOX)isort --check-only -rc registrar/ scripts/

isort: ## run isort to sort imports in all Python files
	$(TOX)isort --recursive --atomic registrar scripts

pii_check: ## check for PII annotations on all Django models
	DJANGO_SETTINGS_MODULE=registrar.settings.test \
	$(TOX)code_annotations django_find_annotations --config_file .pii_annotations.yml --lint --report --coverage

validate: coverage quality pii_check validate_api_committed  ## run all tests and quality checks

migrate: ## apply database migrations
	python manage.py migrate

createsuperuser:  ## create a super user with username and password 'edx'
	echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser(\"edx\", \"edx@example.com\",\"edx\") if not User.objects.filter(username=\"edx\").exists() else None" | python manage.py shell

html_coverage: coverage ## generate and view HTML coverage report
	$(BROWSER) htmlcov/index.html

extract_translations: ## extract strings to be translated, outputting .mo files
	$(TOX)python manage.py makemessages -l en -v1 -d django
	$(TOX)python manage.py makemessages -l en -v1 -d djangojs

dummy_translations: ## generate dummy translation (.po) files
	cd registrar && i18n_tool dummy

compile_translations:
	$(TOX)python manage.py compilemessages

fake_translations: extract_translations dummy_translations compile_translations ## generate and compile dummy translation files

pull_translations: ## pull translations from Transifex
	tx pull -af --mode reviewed

push_translations: ## push source translation files (.po) from Transifex
	tx push -s

detect_changed_source_translations: ## check if translation files are up-to-date
	cd registrar && i18n_tool changed

validate_translations: fake_translations detect_changed_source_translations ## install fake translations and check if translation files are up-to-date

api_generated: ## generates an expanded verison of api.yaml for consuming tools that cannot read yaml anchors
	python scripts/yaml_merge.py api.yaml .api-generated.yaml

validate_api_committed: ## check to make sure any api.yaml changes have been committed to the expanded document
	$(TOX)bash -c "diff .api-generated.yaml <(python scripts/yaml_merge.py api.yaml -)"
