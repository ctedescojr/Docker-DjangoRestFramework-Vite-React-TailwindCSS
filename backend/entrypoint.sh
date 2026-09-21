#!/bin/sh
set -e

# --- User and Permission Management ---
PUID=${HOST_UID:-1000}
PGID=${HOST_GID:-1000}

CURRENT_UID=$(id -u appuser)
CURRENT_GID=$(id -g appuser)

if [ "$CURRENT_UID" != "$PUID" ] || [ "$CURRENT_GID" != "$PGID" ]; then
    echo "---> Updating appuser UID to $PUID and GID to $PGID..."
    groupmod -o -g "$PGID" appuser
    usermod -o -u "$PUID" appuser
fi

# --- Project Initialization (Boilerplate) ---
if [ ! -f "manage.py" ]; then
    echo "---> manage.py not found. Running boilerplate bootstrap..."
    sh /app/scripts/init_project.sh
fi

# --- Runtime Operations ---
echo "---> Setting permissions..."
chown -R appuser:appuser /app

if [ -d "/app/locale" ]; then
    chown -R appuser:appuser /app/locale
fi

if [ -z "$DJANGO_SETTINGS_MODULE" ]; then
    echo "Error: DJANGO_SETTINGS_MODULE is not set."
    exit 1
fi

# Run migrations and initialization only for web server (avoids concurrency issues with Celery)
case "$1" in
    celery)
        echo "---> Celery process detected. Skipping database migrations and static collection."
        ;;
    *)
        echo "Waiting for the database..."
        gosu appuser python manage.py wait_for_db

        echo "Applying database migrations..."
        gosu appuser python manage.py migrate

        echo "Checking superuser..."
        gosu appuser python manage.py init_superuser

        echo "Collecting static files..."
        gosu appuser python manage.py collectstatic --noinput
        ;;
esac

echo "---> Starting application..."
exec gosu appuser "$@"
