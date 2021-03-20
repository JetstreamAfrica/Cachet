#!/bin/bash

chmod -R 777 storage/
chmod -R 777 bootstrap/cachet

php artisan storage:link

php artisan migrate --force

echo "trying to exec $@"
exec "$@"
