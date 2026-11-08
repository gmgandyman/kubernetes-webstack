#!/usr/bin/bash

# You must have a toolbox/.env for this to work. See toolbox/.env.example
if [ ! -f "toolbox/.env" ]; then
    echo "Error: File 'toolbox/.env' not found. Please copy toolbox/.env.example to toolbox/.env"
    return 1
fi

# Our .env file exists in toolbox/, but our compose file is a layer up, so load it's data into the shell
# before compose runs
set -a
source toolbox/.env
set +a

start-toolbox() {
  (docker compose run --rm --build toolbox bash) || (podman compose run --rm --build toolbox bash)
}
