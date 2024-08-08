#!/bin/bash

# CONFIG_ENV_VARS is a space separated list of environment variables. i.e. "ENV_VAR1 ENV_VAR2 ENV_VAR3"

if [ -z "$CONFIG_ENV_VARS" ]; then
    echo "No environment variables to set."
    echo "Moving on..."
    exit 0
fi

echo "Setting config from environment variables..."

# Function to handle setting the environment variables
set_env_var() {
    local source=$1

    echo "Updating $source"
    defang config set -e $source
}

# Split the CONFIG_ENV_VARS string by whitespace
IFS=' ' read -r -a sources <<< "$CONFIG_ENV_VARS"

# Iterate over the sources and set the environment variables
for source in "${sources[@]}"; do
    set_env_var "$source"
done