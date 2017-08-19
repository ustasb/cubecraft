#!/usr/bin/env bash

COFFEE_CMD="coffee --output lib --compile src"

docker run -v $(pwd):/srv/www/cubecraft cubecraft $COFFEE_CMD
