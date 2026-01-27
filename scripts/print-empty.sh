#!/bin/bash
set -e

# Check for empty environment variables (only for regular config vars)
empty=()
for source in $CONFIG_ENV_VARS; do
    if [ -z "${!source}" ]; then
        empty+=("$source")
    fi
done

# If there are empty variables, print instructions
if [ ${#empty[@]} -gt 0 ]; then
    echo "Some Defang config vars do not have values. To use Github Secrets, add"
    echo "these variables to your environment:"
    for source in "${empty[@]}"; do
        echo "- $source"
    done
    echo "Here is a link to your repository environments settings:"
    echo "https://github.com/${GITHUB_REPOSITORY}/settings/environments"
fi
