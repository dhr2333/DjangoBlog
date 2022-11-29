#!/usr/bin/env bash
NAME="djangoblog" # Name of the application
APP_NAME01="djangoblog"
APP_NAME02="beancount"
DJANGODIR=/code/djangoblog # Django project directory
USER=root # the user to run as
GROUP=root # the group to run as
NUM_WORKERS=1 # how many worker processes should Gunicorn spawn
#DJANGO_SETTINGS_MODULE=djangoblog.settings # which settings file should Django use
DJANGO_WSGI_MODULE=djangoblog.wsgi # WSGI module name


echo "Starting $APP_NAME01 as `whoami`"
echo "Starting $APP_NAME02 as `whoami`"

# Activate the virtual environment
cd $DJANGODIR

export PYTHONPATH=$DJANGODIR:$PYTHONPATH
fava &
#pip install -Ur requirements.txt -i http://pypi.douban.com/simple/  --trusted-host pypi.douban.com && \
#        pip install gunicorn  -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com
python manage.py makemigrations && \
  python manage.py migrate && \
  python manage.py collectstatic --noinput  && \
  python manage.py compress --force && \
  python manage.py build_index && \
# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)
exec gunicorn ${DJANGO_WSGI_MODULE}:application \
--name $NAME \
--workers $NUM_WORKERS \
--user=$USER --group=$GROUP \
--bind 0.0.0.0:8000 \
--log-level=debug \
--log-file=- \
--worker-class gevent \
--threads 4
